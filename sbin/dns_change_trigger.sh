#!/bin/sh

PWD=$(cd "$(dirname "$0")"; pwd)
ROOT="$PWD/.."

CUR_RESOLV="/etc/resolv.conf"
CONF_RESOLV="$ROOT/conf/resolv.conf"
CUR_DNS=`cat $CUR_RESOLV`
CONF_DNS=`cat $ROOT/conf/resolv.conf`

if [ "$CUR_DNS" == "$CONF_DNS" ] ; then
    logger -t "pptp" "resolv.conf has automatly set to $CUR_DNS"
else
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    cp -f $CONF_RESOLV $CUR_RESOLV
    logger -t "pptp" "resolv.conf has changed, i'll recover it"
fi


