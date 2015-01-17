#!/bin/sh

PWD=$(cd "$(dirname "$0")"; pwd)
VERSION=`cat manifest.json | jq .version | tr -d [\"]`

APP=`cat manifest.json | jq .name | tr -d [\"]`

PROFILE="$PWD/data/profile"
rm $PROFILE
echo "username username" > $PROFILE
echo "password password" >> $PROFILE
echo "server server" >> $PROFILE

tar -cvzf ../$APP.$VERSION.tar.gz . --exclude '.git' --exclude "publish.sh" --exclude "app-pptp.conf" --exclude "option.pptp" --exclude "*.mpk" --exclude "\#*"

mv -f ../$APP.$VERSION.tar.gz $APP.$VERSION.mpk
