#!/bin/sh

PWD=$(cd "$(dirname "$0")"; pwd)

# 检测是否已经有VPN拨号配置
if [ ! -f $PWD/option.pptp ]; then
    messagebox PPTP-VPN 请先配置vpn信息 1 确定 ""
    exit 1
fi

# 添加拨号的hook脚本
rm -rf /etc/ppp
mkdir /etc/ppp
cp $PWD/ip-pre-up /etc/ppp/ip-pre-up
cp $PWD/ip-down /etc/ppp/ip-down
cp $PWD/ip-up /etc/ppp/ip-up

cp /etc/resolv.conf /var/run/pptp-old-dns




rm $PWD/loading.conf
updateconf $PWD/loading.conf -t Title -v "PPTP连接中"
#updateconf loading.conf -t ButtonText -v OK
updateconf $PWD/loading.conf -t State -v 0

loadingapp $PWD/loading.conf &

# 查询IP
SERVER=`cat $PWD/option.pptp | grep "pty" | awk '{print $3}'`
SERVER_IP=`nslookup $SERVER | awk 'NR==5 { print $3 }'`
echo "server ip : $SERVER_IP"

pppd file "$PWD/option.pptp" ipparam $SERVER_IP &

ret=$?

# 设置loading.conf，让菊花停下来
#rm $PWD/loading.conf
#updateconf $PWD/loading.conf -t Title -v "PPTP连接中"
#updateconf loading.conf -t ButtonText -v OK
updateconf $PWD/loading.conf -t State -v 2


if [ $ret == 0 ]; then
    cp -r $PWD/connected.conf /var/run/pptp.conf
    APP_PID=`cat /var/run/pptp.pid`
    kill -SIGUSR1 $APP_PID
else    
    $PWD/poff.sh
    messagebox PPTP-VPN "拨号失败(code:$ret)" 1 确定 ""
fi

exit $ret
