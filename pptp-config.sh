#!/bin/sh

if [ $# != 3 ]; then
  echo "Usage: $0 <user> <password> <server_addr>"
  exit 1
fi

CUR_DIR=`pwd`
PPTP_FILE=$CUR_DIR/option.pptp

USER_NAME="$1"
PASSWORD="$2"
SERVER_IP="$3"

#todo 需要判断是域名还是IP，如果是域名，还需要转换成IP
#SERVER_IP=`nslookup $SERVER_IP | awk 'NR==5 { print $3 }'`

echo "nodeflate" > $PPTP_FILE
echo "nobsdcomp" >> $PPTP_FILE
echo "require-mppe-128" >> $PPTP_FILE
echo "noauth" >> $PPTP_FILE
echo "refuse-eap" >> $PPTP_FILE
echo "user \"$USER_NAME\"" >> $PPTP_FILE
echo "password \"$PASSWORD\"" >> $PPTP_FILE
echo "connect true" >> $PPTP_FILE
echo "pty '$CUR_DIR/pptp $SERVER_IP --nolaunchpppd'" >> $PPTP_FILE
echo "lock" >> $PPTP_FILE
echo "maxfail 0" >> $PPTP_FILE
echo "usepeerdns" >> $PPTP_FILE
#echo "persist" >> $PPTP_FILE
echo "holdoff 600" >> $PPTP_FILE
echo "ipcp-accept-remote ipcp-accept-local noipdefault" >> $PPTP_FILE
echo "ktune" >> $PPTP_FILE
echo "default-asyncmap nopcomp noaccomp" >> $PPTP_FILE
echo "novj nobsdcomp nodeflate" >> $PPTP_FILE
echo "lcp-echo-interval 10" >> $PPTP_FILE
echo "lcp-echo-failure 6" >> $PPTP_FILE
echo "unit 0" >> $PPTP_FILE
echo "defaultroute" >> $PPTP_FILE
