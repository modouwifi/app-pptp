#!/bin/sh

PWD=$(cd "$(dirname "$0")"; pwd)

# 可能是pppoe拨号方式,所以不能KILLALL pppd
PID=`ps | grep $PWD/option.pptp | awk '$5=="pppd" {print $1}'`
kill $PID

killall pptp

#fix me /etc/resove.conf的恢复
#$PWD/ip-down

cp -r $PWD/not_connected.conf /var/run/pptp.conf
APP_PID=`cat /var/run/pptp.pid`
kill -SIGUSR1 $APP_PID
