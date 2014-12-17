#!/bin/sh

PWD=$(cd "$(dirname "$0")"; pwd)

VAR_CONF_FILE="/var/run/pptp.conf"
CUSTOM_PID_FILE="/var/run/pptp_custom"
AUTO_CONN_FILE="/var/run/pptp_auto"
UP_FILE="/var/run/pptp_on"
PPPD_PID_FILE="/var/run/pptp_pppd.pid"
SERVICE_LOCATION_FILE="/var/run/service_location_file"

ON_UP_CONF="$PWD/auto_on_up.conf"
ON_DOWN_CONF="$PWD/auto_on_down.conf"
OFF_CONF="$PWD/auto_off.conf"
SERVICE_FILE="$PWD/service.sh"


update_conf() {
    local auto=`cat $AUTO_CONN_FILE 2>/dev/null`
    local up=`cat $UP_FILE 2>/dev/null`

    if [ "$auto" == "1" ] ; then
        if [ "$up" == "1" ] ; then
            cp -r $ON_UP_CONF $VAR_CONF_FILE
        else
            cp -r $ON_DOWN_CONF $VAR_CONF_FILE
        fi
    else
        cp -r $OFF_CONF $VAR_CONF_FILE
    fi
}


#if [ "$STATE" == "1" ] ; then
#    cp -r $PWD/connected.conf /var/run/pptp.conf
#    APP_PID=`cat /var/run/pptp.pid`
#    kill -SIGUSR1 $APP_PID
#else    
#    $PWD/poff.sh
#    messagebox PPTP-VPN "" 1 确定 ""
#fi

run() {
    update_conf ;
    custom $VAR_CONF_FILE $PWD &
    echo $! > $CUSTOM_PID_FILE
}

update_ui() {
    update_conf ;
    local pid=`cat $CUSTOM_PID_FILE`
    kill -SIGUSR1 $pid
}

enable_auto_conn() {
    # 检测是否已经有VPN拨号配置
    if [ ! -f $PWD/option.pptp ]; then
        messagebox PPTP-VPN 请先配置vpn信息 1 确定 ""
        exit 1
    fi

    # 保存service脚本位置
    echo $SERVICE_FILE > $SERVICE_LOCATION_FILE

    # 添加拨号的hook脚本
    rm -rf /etc/ppp
    mkdir /etc/ppp
    cp $PWD/ip-pre-up /etc/ppp/ip-pre-up
    cp $PWD/ip-down /etc/ppp/ip-down
    cp $PWD/ip-up /etc/ppp/ip-up

    # 保存之前的DNS
    cp /etc/resolv.conf /var/run/pptp-old-dns
    
    # 查询IP
    SERVER=`cat $PWD/option.pptp | grep "pty" | awk '{print $3}'`
    SERVER_IP=`nslookup $SERVER | awk 'NR==5 { print $3 }'`

    pppd file "$PWD/option.pptp" ipparam $SERVER_IP &
    echo $! > $PPPD_PID_FILE

    echo 1 > $AUTO_CONN_FILE
    update_ui ;
}

disable_auto_conn() {
    kill `cat $PPPD_PID_FILE`
    killall pptp

    echo 0 > $AUTO_CONN_FILE
    update_ui ;

    # 恢复之前的DNS
    cp /var/run/pptp-old-dns /etc/resolv.conf
}

usage() {
    echo "ERROR: action missing"
    echo "syntax: $0 <on|off>"
}

# main
if [ $# -lt 1 ]; then
    usage
    exit 255
fi

case "$1" in
    "on" )
        enable_auto_conn;;
    "off" )
        disable_auto_conn;;
    "run" )
        run;;
    "update_ui" )
        update_ui;;
    * )
        usage ;;
esac
