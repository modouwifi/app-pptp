#!/bin/sh

. /usr/share/libubox/jshn.sh

PWD=$(cd "$(dirname "$0")"; pwd)
ROOT="$PWD/.."
PROFILE="$ROOT/data/profile"
OPTION_PPTP="$ROOT/data/option.pptp"
PPTP_SO="$ROOT/bin/pptp.so"
TEMPLATE="$ROOT/conf/option.template"
OPTION_CONF="$ROOT/conf/option.conf"

generate-config-file-2 $ $OPTION_CONF $PROFILE

if [ $? != 0 ]; then
    exit 1
fi



SERVER=`cat $PROFILE | awk '$1=="server"{print $2}'`
USERNAME=`cat $PROFILE | awk '$1=="username"{print $2}'`
PASSWORD=`cat $PROFILE | awk '$1=="password"{print $2}'`


#同步到data.json中
json4sh.sh set data.json server value $SERVER
json4sh.sh set data.json user value $USERNAME
json4sh.sh set data.json pass value $PASSWORD


rm $OPTION_PPTP
echo "plugin $PPTP_SO" > $OPTION_PPTP
cat $TEMPLATE >> $OPTION_PPTP
echo -e "\n" >> $OPTION_PPTP



echo "user \"$USERNAME\"" >> $OPTION_PPTP
echo "password \"$PASSWORD\"" >> $OPTION_PPTP
echo "pptp_server $SERVER" >> $OPTION_PPTP