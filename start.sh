#!/bin/sh

PWD=$(cd "$(dirname "$0")"; pwd)

PPTP_HAS_RUN=0

if [ -f /var/run/pptp-interface ]; then
    INTERFACE=`cat /var/run/pptp-interface`
    result=`ifconfig | grep $INTERFACE | wc -l`
    if [ $result -eq 1 ]; then
        PPTP_HAS_RUN=1
    fi
fi


#PPTP_PROC_NUM=`ps | grep pptp | wc -l`
if [ $PPTP_HAS_RUN == 1 ]; then    
    #echo "pptp has run, $PWD/connected.conf" >> /tmp/pptp    
    cp -r $PWD/connected.conf /var/run/pptp.conf
    #custom $PWD/connected.conf &
else
    #echo "pptp has not run, $PWD/not_connected.conf" >> /tmp/pptp
    cp -r $PWD/not_connected.conf /var/run/pptp.conf
    #custom $PWD/not_connected.conf &
fi

custom /var/run/pptp.conf &
echo $! > /var/run/pptp.pid
