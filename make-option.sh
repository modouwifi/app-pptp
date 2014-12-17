#!/bin/sh

PWD=$(cd "$(dirname "$0")"; pwd)

generate-config-file $PWD/profile

if [ $? != 0 ]; then
    exit 1
fi

rm $PWD/option.pptp
cp $PWD/option.template $PWD/option.pptp

USERNAME=`cat $PWD/profile | awk '$1=="username"{print $2}'`
PASSWORD=`cat $PWD/profile | awk '$1=="password"{print $2}'`
SERVER=`cat $PWD/profile | awk '$1=="server"{print $2}'`

echo "user \"$USERNAME\"" >> $PWD/option.pptp
echo "password \"$PASSWORD\"" >> $PWD/option.pptp

# SERVER_IP=`nslookup $SERVER | awk 'NR==5 { print $3 }'`
echo "pty '$PWD/pptp $SERVER --nolaunchpppd'" >> $PWD/option.pptp
