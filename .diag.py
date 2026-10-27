# -*- coding: utf-8 -*-
"""诊断 wwan0 消失与服务失败原因（全部用系统命令，不触发 KYSEC 脚本管控）"""
import paramiko

cli = paramiko.SSHClient()
cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
cli.connect("192.168.0.94", username="test", password="Qwe12345", timeout=10, look_for_keys=False, allow_agent=False)

def run(cmd, timeout=30):
    _, stdout, stderr = cli.exec_command(cmd, timeout=timeout)
    out = stdout.read().decode("utf-8", "replace")
    err = stderr.read().decode("utf-8", "replace")
    return out + ("\n[stderr] " + err if err.strip() else "")

print("=== uptime（是否重启过）===\n" + run("uptime -s; uptime"))
print("=== 模块 USB 在位 ===\n" + run("lsusb | grep -i 2c7c || echo NO_MODULE"))
print("=== 网络接口 ===\n" + run("ls /sys/class/net"))
print("=== 串口/wdm 设备 ===\n" + run("ls /dev/ttyUSB* /dev/cdc-wdm* 2>&1"))
print("=== 内核驱动模块 ===\n" + run("lsmod | grep -E 'qmi_wwan|usb_wwan|^option|cdc_wdm' || echo NONE_LOADED"))
print("=== USB 设备树中的驱动绑定 ===\n" + run("for d in /sys/bus/usb/devices/*/interface; do echo \"$d -> $(readlink -f ${d%interface}/driver 2>/dev/null)\"; done 2>/dev/null | grep -iE '2-|qmi|option|cdc|qserial' | head -10"))
print("=== quectel-cm 服务状态 ===\n" + run("systemctl status quectel-cm --no-pager -n 5 2>&1 | head -25"))
print("=== 服务日志尾部 ===\n" + run("journalctl -u quectel-cm --no-pager 2>/dev/null | tail -15 || echo NO_JOURNAL"))
print("=== KYSEC 状态 ===\n" + run("sudo -n true 2>/dev/null && echo SUDO_OK; getstatus 2>/dev/null || cat /sys/kernel/security/kysec/status 2>/dev/null || echo UNKNOWN"))
cli.close()
