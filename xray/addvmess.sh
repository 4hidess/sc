#!/bin/bash
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
# Getting
MYIP=$(wget -qO- ipinfo.io/ip);
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
nsdomain=$(cat /etc/xray/dns)
key=$(cat /etc/slowdns/server.pub)
else
domain=$IP
fi
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		echo -e "===============================" | lolcat
		read -rp "Username : " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/xray/v2ray-tls.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo -e "===============================" | lolcat
			echo -e "Username ${RED}${CLIENT_NAME}${NC} Already On VPS Please Choose Another"
			echo -e "===============================" | lolcat
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (Days) : " masaaktif
echo -e "===============================" | lolcat
hariini=`date -d "0 days" +"%Y-%m-%d"`
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#xray-v2ray-tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/v2ray-tls.json
sed -i '/#xray-v2ray-nontls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/v2ray-nontls.json
cat>/etc/xray/v2ray-$user-tls.json<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${domain}",
      "tls": "tls"
}
EOF
cat>/etc/xray/v2ray-$user-nontls.json<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${domain}",
      "tls": "none"
}
EOF
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
xrayv2ray1="vmess://$(base64 -w 0 /etc/xray/v2ray-$user-tls.json)"
xrayv2ray2="vmess://$(base64 -w 0 /etc/xray/v2ray-$user-nontls.json)"
systemctl restart xray@v2ray-tls
systemctl restart xray@v2ray-nontls
service cron restart
clear
echo -e ""
echo -e "========={XRAYS/VMESS}=========" | lolcat
echo -e "Remarks     : ${user}"
echo -e "Address     : ${domain}"
echo -e "Nameserver  : ${nsdomain}"
echo -e "Pub Key     : $key"
echo -e "Port TLS    : 443 "
echo -e "Port No TLS : 80 "
echo -e "User ID     : ${uuid}"
echo -e "Alter ID    : 0"
echo -e "Security    : auto"
echo -e "Network     : ws"
echo -e "Path        : /vmess"
echo -e "Created     : $hariini"
echo -e "Expired     : $exp"
echo -e "===============================" | lolcat
echo -e " Link TLS    : ${xrayv2ray1}"
echo -e "===============================" | lolcat
echo -e " Link No TLS : ${xrayv2ray2}"
echo -e "===============================" | lolcat
echo -e "    Script By MakhlukVpn          "
echo -e "===============================" | lolcat
echo -e ""
echo -e "       Terimakasih Telah "
echo -e "   Menggunakan Layanan Kami "
echo -e ""
echo -e "===============================" | lolcat
echo -e ""
