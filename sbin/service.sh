#!/bin/sh

PWD=$(cd "$(dirname "$0")"; pwd)
ROOT="$PWD/.."

VAR_CONF_FILE="/var/run/pptp.conf"
CUSTOM_PID_FILE="/var/run/pptp_custom"
AUTO_CONN_FILE="/var/run/pptp_auto"
UP_FILE="/var/run/pptp_on"
PPPD_PID_FILE="/var/run/pptp_pppd.pid"
SERVICE_LOCATION_FILE="/var/run/service_location_file"

ON_UP_CONF="$ROOT/conf/auto_on_up.conf"
ON_DOWN_CONF="$ROOT/conf/auto_on_down.conf"
OFF_CONF="$ROOT/conf/auto_off.conf"
SERVICE_FILE="$ROOT/sbin/service.sh"

IP_PRE_UP="$ROOT/sbin/ip-pre-up"
IP_DOWN="$ROOT/sbin/ip-down"
IP_UP="$ROOT/sbin/ip-up"

OPTION_PPTP="$ROOT/data/option.pptp"
OPTION_USER="$ROOT/data/option.user"
TEMPLATE="$ROOT/conf/option.template"
OPTION_CONF="$ROOT/conf/option.conf"

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


run() {
    update_conf ;
    custom $VAR_CONF_FILE $ROOT &
    echo $! > $CUSTOM_PID_FILE
}

update_ui() {
    update_conf ;
    local pid=`cat $CUSTOM_PID_FILE`
    kill -SIGUSR1 $pid
}

enable_auto_conn() {
    # 检测是否已经有VPN拨号配置
    if [ ! -f $OPTION_PPTP ]; then
        messagebox PPTP-VPN 请先配置vpn信息 1 确定 ""
        exit 1
    fi

    # 保存service脚本位置
    echo $SERVICE_FILE > $SERVICE_LOCATION_FILE

    # 添加拨号的hook脚本
    rm -rf /etc/ppp
    mkdir /etc/ppp
    cp $IP_PRE_UP /etc/ppp/ip-pre-up
    cp $IP_DOWN /etc/ppp/ip-down
    cp $IP_UP /etc/ppp/ip-up

    # 保存之前的DNS
    #cp /etc/resolv.conf /var/run/pptp-old-dns    
    
    # 查询IP
    #SERVER=`cat $PWD/option.pptp | grep "pty" | awk '{print $3}'`
    local SERVER=`cat $OPTION_PPTP | grep "pptp_server" | awk '{print $2}'`
    local SERVER_IP=`nslookup $SERVER | awk 'NR==5 { print $3 }'`

    pppd file "$OPTION_PPTP" ipparam $SERVER_IP &
    echo $! > $PPPD_PID_FILE

    echo 1 > $AUTO_CONN_FILE
    update_ui ;
}

disable_auto_conn() {
    kill `cat $PPPD_PID_FILE`

    echo 0 > $AUTO_CONN_FILE
    update_ui ;

    

    # 恢复之前的DNS
    #cp /var/run/pptp-old-dns /etc/resolv.conf
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
