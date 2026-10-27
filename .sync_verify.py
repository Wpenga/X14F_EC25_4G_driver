# -*- coding: utf-8 -*-
"""部署内联 unit 版脚本并全流程验证：lan -> 4G -> lan"""
import paramiko

HOST, USER, PWD = "192.168.0.94", "test", "Qwe12345"
REMOTE = "/usr/local/bin/deploy_4g.sh"

cli = paramiko.SSHClient()
cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
cli.connect(HOST, username=USER, password=PWD, timeout=10, look_for_keys=False, allow_agent=False)

def run(cmd, timeout):
    _, stdout, stderr = cli.exec_command(cmd, timeout=timeout)
    out = stdout.read().decode("utf-8", "replace")
    err = stderr.read().decode("utf-8", "replace")
    return out + ("\n[stderr] " + err if err.strip() else "")

sftp = cli.open_sftp()
sftp.put("deploy_4g.sh", "/tmp/deploy_4g.sh")
sftp.close()
print(run(f"echo '{PWD}' | sudo -S -p '' install -m 755 /tmp/deploy_4g.sh {REMOTE} && "
          f"rm -f /tmp/deploy_4g.sh && echo INSTALLED", 30))

for label, subcmd, tmo in [("1) lan 部署(恢复 4G + 有线优先)", "", 420),
                           ("2) 切 4G 优先", "4G", 180),
                           ("3) 切回 lan(最终状态)", "", 180)]:
    print(f"\n{'='*60}\n>>> {label}\n{'='*60}", flush=True)
    print(run(f"echo '{PWD}' | sudo -S -p '' timeout {tmo-30} bash {REMOTE} {subcmd} 2>&1", tmo))

print("\n>>> 服务与路由最终状态")
print(run(
    "timeout 10 systemctl is-active quectel-cm; "
    "timeout 10 systemctl show -p ExecStart --value quectel-cm.service | head -c 300; echo; echo ---; "
    "timeout 5 ip -4 route show default; timeout 5 ip route get 223.5.5.5; echo ---; "
    "timeout 5 cat /etc/quectel-cm/route-metric; timeout 5 ip -4 addr show wwan0 | grep inet", 40))
cli.close()
print(">>> 完成")
