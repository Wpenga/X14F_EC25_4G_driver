#!/usr/bin/env bash
#=============================================================================
# Quectel EM05-CN/EC25 系列 4G 模块部署与优先级管理脚本
# 适用于：银河麒麟 V10 SP1 / Ubuntu 20.04 等内核 5.x + systemd + NetworkManager
#
# 用法（目标设备上以 root 执行）:
#   sudo bash deploy_4g.sh            # QMI 模式完整部署，默认 有线优先(lan)，4G 备用
#   sudo bash deploy_4g.sh lan        # 同上；已部署时仅切优先级（不中断拨号）
#   sudo bash deploy_4g.sh 4G         # 4G 优先，有线备用；已部署时仅切优先级
#   sudo bash deploy_4g.sh ecm        # 切 ECM 模式(usbnet=1)：NM 接管，无需 quectel-CM/服务
#   sudo bash deploy_4g.sh ecm 4G     # ECM 模式 + 4G 优先
#
# 环境变量:
#   APN=ctnet        # 电信卡需指定 APN；联通/移动卡用默认 APN
#   ENABLE_SYSTEMD=0 # 不安装开机自启服务（仅 QMI 模式相关）
#
# 优先级实现（QMI 模式）:
#   quectel-CM 固定添加 metric 0 默认路由；由包装器 quectel-cm-wrapper.sh
#   按配置文件 /etc/quectel-cm/route-metric 动态改写 wwan0 默认路由 metric
#   （4G优先=0；lan优先=有线metric+100），3 秒自适应，切优先级无需重拨。
#=============================================================================
set -uo pipefail

APN="${APN:-}"
ENABLE_SYSTEMD="${ENABLE_SYSTEMD:-1}"
MODE="$(echo "${1:-lan}" | tr '[:upper:]' '[:lower:]')"
PRIO2="$(echo "${2:-lan}" | tr '[:upper:]' '[:lower:]')"
LOG=/var/log/quectel-CM.log
WRAPPER=/usr/local/bin/quectel-cm-wrapper.sh
METRIC_FILE=/etc/quectel-cm/route-metric

log()  { echo -e "\n[deploy] $*"; }
fail() { echo "[deploy][错误] $*"; exit 1; }
usage() {
    echo "用法: sudo bash $0 [lan|4G|qmi|ecm]   （无参数=lan）"
    echo "  lan/4G : QMI 模式，切换 有线优先/4G优先（已部署则秒切，不重拨）"
    echo "  qmi    : = lan"
    echo "  ecm    : 切 ECM 模式(usbnet=1)，NM 接管，无需 quectel-CM 服务；可加第二参数 lan|4G"
}

[ "$(id -u)" = 0 ] || fail "请用 root 执行：sudo bash $0"
command -v systemctl >/dev/null || fail "系统无 systemd"
lsusb | grep -qi "2c7c:" || fail "未检测到 Quectel 模块 (lsusb 无 2c7c:xx 设备)"

#-----------------------------------------------------------------------------
# AT 口工具
#-----------------------------------------------------------------------------
find_at_port() {
    local p r
    for p in /dev/ttyUSB3 /dev/ttyUSB2 /dev/ttyUSB1 /dev/ttyUSB0; do
        [ -e "$p" ] || continue
        stty -F "$p" 115200 raw -echo 2>/dev/null || true
        printf 'ATI\r' > "$p"
        sleep 1
        r=$(timeout 2 cat "$p" 2>/dev/null)
        echo "$r" | grep -q Quectel && { echo "$p"; return 0; }
    done
    return 1
}
at() {
    printf '%s\r' "$1" > "$ATPORT"
    sleep 1
    timeout 3 cat "$ATPORT" 2>/dev/null
}

# 切换 usbnet 模式: $1=0(QMI) / 1(ECM)；仅在实际发生切换后重新探测 AT 口
switch_usbnet() {
    local want=$1 marker=$2 name=$3 i ok=0
    local mode
    mode=$(at 'AT+QCFG="usbnet"' | grep -o '"usbnet",[0-9]*' | grep -o '[0-9]*$' || true)
    log "当前 usbnet 模式: ${mode:-未知}（0=QMI 1=ECM 2=RNDIS）"
    if [ "$mode" != "$want" ]; then
        log "切换到 $name 模式并重启模块（约 40 秒）..."
        at "AT+QCFG=\"usbnet\",$want" >/dev/null
        sleep 1
        at 'AT+CFUN=1,1' >/dev/null
        for i in $(seq 1 24); do
            sleep 5
            eval "$marker" && { ok=1; break; }
        done
        [ $ok = 1 ] || fail "切换后目标设备未出现（$name）"
        ATPORT=$(find_at_port) || fail "切换后 AT 口丢失"
        log "重启后 AT 口 = $ATPORT"
    fi
}

# 查找 ECM 网卡（cdc_ether 驱动）
find_ecm_nic() {
    local n d
    for n in /sys/class/net/*; do
        d=$(readlink "$n/device/driver" 2>/dev/null) || continue
        case "$d" in *cdc_ether) basename "$n"; return 0;; esac
    done
    return 1
}

wait_registration() {
    local i r
    log "等待网络注册（CEREG）..."
    for i in $(seq 1 24); do
        r=$(at 'AT+CEREG?')
        echo "$r" | grep -qE 'CEREG: *[0-9]+,(1|5)' && { at 'AT+CGATT?'; log "注册成功"; return 0; }
        sleep 5
    done
    at 'AT+QENG="servingcell"'; at 'AT+COPS=?'
    fail "模块未注册上网络：请检查天线是否接 MAIN(M) 口、卡是否可用/停机"
}

# 有线口当前默认路由 metric（供 lan 优先时抬高 4G 路由）
wired_metric() {
    local m
    m=$(ip -4 route show default 2>/dev/null | grep -v ' dev wwan0 ' | head -1 \
        | grep -oE 'metric [0-9]+' | awk '{print $2}')
    echo "${m:-100}"
}

config_dns() {
    log "配置全局 DNS"
    [ -f /etc/systemd/resolved.conf.bak ] || cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bak
    cat > /etc/systemd/resolved.conf <<'EOF'
[Resolve]
DNS=223.5.5.5 114.114.114.114
FallbackDNS=119.29.29.29
#LLMNR=no
#MulticastDNS=no
#DNSSEC=allow-downgrade
EOF
    systemctl restart systemd-resolved 2>/dev/null || true
}

verify() {
    sleep 4
    log "===== 验证结果 ====="
    ip -4 route show default
    echo "-- 出口: $(ip route get 223.5.5.5 2>/dev/null | head -1)"
    ping -c 3 -W 2 223.5.5.5 | tail -2
    ping -c 3 -W 2 www.baidu.com | sed -n '2p' || true
}

#-----------------------------------------------------------------------------
# QMI 路径
#-----------------------------------------------------------------------------
deploy_qmi() {
    local prio=$1 i got=0
    log "模式: QMI + ${prio} 优先"

    log "加载内核驱动模块"
    for m in usbserial option usb_wwan qmi_wwan cdc_wdm usbnet; do modprobe "$m" 2>/dev/null || true; done
    cat > /etc/modules-load.d/quectel-qmi.conf <<'EOF'
usbserial
option
usb_wwan
qmi_wwan
cdc_wdm
EOF

    ATPORT=$(find_at_port) || fail "没有任何 ttyUSB 口应答 ATI"
    switch_usbnet 0 "ls /dev/cdc-wdm0 >/dev/null 2>&1" "QMI"
    wait_registration

    # 优先级 metric：4G=0（抢过有线）；lan=有线metric+100（让位有线）
    local metric
    if [ "$prio" = "4G" ]; then metric=0; else metric=$(( $(wired_metric) + 100 )); fi
    log "wwan0 默认路由 metric = $metric（写入 $METRIC_FILE，包装器 3 秒自适应）"

    local apn_arg=""
    [ -n "$APN" ] && apn_arg="-s $APN"

    mkdir -p /etc/quectel-cm
    echo "$metric" > "$METRIC_FILE"

    cat > "$WRAPPER" <<'EOF'
#!/bin/bash
# quectel-CM 包装器：按 /etc/quectel-cm/route-metric 动态调整 wwan0 默认路由 metric
METRIC_FILE=/etc/quectel-cm/route-metric
IFACE=wwan0
/usr/bin/quectel-CM "$@" &
CM_PID=$!
while kill -0 "$CM_PID" 2>/dev/null; do
    M=$(cat "$METRIC_FILE" 2>/dev/null || echo 0)
    CUR=$(ip -4 route show default dev "$IFACE" 2>/dev/null | head -1)
    if [ -n "$CUR" ]; then
        CURM=$(echo "$CUR" | grep -oE 'metric [0-9]+' | awk '{print $2}'); CURM=${CURM:-0}
        if [ "$CURM" != "$M" ]; then
            GW=$(echo "$CUR" | awk '{for(i=1;i<=NF;i++) if($i=="via") print $(i+1)}')
            while ip route del default dev "$IFACE" 2>/dev/null; do :; done
            [ -n "$GW" ] && ip route add default via "$GW" dev "$IFACE" metric "$M"
        fi
    fi
    sleep 3
done
wait "$CM_PID"
EOF
    chmod +x "$WRAPPER"

    cat > /etc/systemd/system/quectel-cm.service <<EOF
[Unit]
Description=Quectel QMI Connection Manager (metric-aware wrapper)
After=network.target

[Service]
ExecStart=$WRAPPER ${apn_arg}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload

    if [ "$ENABLE_SYSTEMD" = 1 ]; then
        systemctl enable quectel-cm.service
        # 判定运行代际：进程里真的有 wrapper 才算新版在跑（unit 文件可能是刚写的新版）
        if pgrep -f "$WRAPPER" >/dev/null 2>&1 && systemctl is-active --quiet quectel-cm.service; then
            log "wrapper 版服务运行中，仅更新优先级（不重拨，3 秒自适应）"
        else
            log "重启 quectel-cm 服务（加载 wrapper）..."
            pkill -9 quectel-CM 2>/dev/null || true
            pkill -9 -f 'cat /dev/ttyUSB' 2>/dev/null || true
            sleep 1
            systemctl restart quectel-cm.service
            sleep 20
        fi
    else
        systemctl disable quectel-cm.service 2>/dev/null || true
        pgrep -x quectel-CM >/dev/null || {
            pkill -9 quectel-CM 2>/dev/null || true; sleep 1
            nohup "$WRAPPER" $apn_arg >"$LOG" 2>&1 & sleep 20
        }
    fi

    for i in $(seq 1 12); do
        ip -4 addr show wwan0 2>/dev/null | grep -q " inet " && { got=1; break; }
        sleep 5
    done
    [ $got = 1 ] || { tail -30 "$LOG"; fail "wwan0 未获取到 IP"; }

    config_dns
    verify
    log "完成：QMI 模式，${prio} 优先。切换优先级请执行 sudo bash $0 ${prio}（即时生效不重拨）"
}

#-----------------------------------------------------------------------------
# ECM 路径（模式1，usbnet=1）：NM 接管，无需 quectel-CM
#-----------------------------------------------------------------------------
deploy_ecm() {
    local prio=$1 i ok=0 NIC="" CON="" want
    log "模式: ECM(usbnet=1) + ${prio} 优先，NetworkManager 接管"

    systemctl disable --now quectel-cm.service 2>/dev/null || true
    pkill -9 quectel-CM 2>/dev/null || true

    for m in usbserial option cdc_ether usbnet; do modprobe "$m" 2>/dev/null || true; done

    ATPORT=$(find_at_port) || fail "没有任何 ttyUSB 口应答 ATI"
    switch_usbnet 1 "find_ecm_nic >/dev/null" "ECM"

    NIC=$(find_ecm_nic) || fail "未找到 ECM 网卡 (cdc_ether)"
    log "ECM 网卡 = $NIC，等待 NetworkManager 分配 IP..."
    for i in $(seq 1 24); do
        nmcli -g IP4.ADDRESS dev show "$NIC" 2>/dev/null | grep -q . && { ok=1; break; }
        sleep 5
    done
    [ $ok = 1 ] || fail "NM 未给 $NIC 分配 IP（检查 nmcli dev status）"

    CON=$(nmcli -g GENERAL.CONNECTION dev show "$NIC" 2>/dev/null)
    if [ -n "$CON" ] && [ "$CON" != "--" ]; then
        local wm metric
        wm=$(wired_metric)
        if [ "$prio" = "4G" ]; then
            if [ "$wm" -gt 50 ]; then metric=$((wm-50)); else metric=1; fi
        else
            metric=$((wm+100))
        fi
        log "设置 $NIC 路由 metric=$metric（有线 metric=$wm）"
        nmcli con mod "$CON" ipv4.route-metric "$metric"
        nmcli con up "$CON" >/dev/null 2>&1 || true
    else
        log "[警告] NM 未生成 $NIC 的连接配置，跳过 metric 设置"
    fi

    wait_registration
    config_dns
    verify
    log "完成：ECM 模式，${prio} 优先。设置界面里可直接看到该网卡；无需 quectel-CM/服务。"
    log "如需切回 QMI（quectel-CM 拨号 + 断线守护）：sudo bash $0 lan"
}

#-----------------------------------------------------------------------------
# 主流程
#-----------------------------------------------------------------------------
case "$MODE" in
    lan|qmi|"") deploy_qmi "lan" ;;
    4g)         deploy_qmi "4G" ;;
    ecm)        deploy_ecm "$PRIO2" ;;
    *)          usage; fail "未知模式: $MODE" ;;
esac
