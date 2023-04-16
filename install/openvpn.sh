A#!/bin/bash
clear
#color
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- ipinfo.io/ip);

clear
echo -e "===============================" | lolcat
echo -e "     Installing SSH OpenVpn    "
echo -e "===============================" | lolcat
sleep 1
echo -e "[ ${green}INFO${NC} ] Starting Install OpenVPN..
... " 
sleep 1
apt install openvpn easy-rsa unzip -y
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(cat /root/domain);
MYIP2="s/xxxxxxxxx/$MYIP/g";
apt-get install tmux -y
function ovpn_install() {
    rm -rf /etc/openvpn
    mkdir -p /etc/openvpn
    wget --output-document=/etc/openvpn/vpn.zip "https://raw.githubusercontent.com/Annnjayy/sc/main/service/vpn.zip" >/dev/null 2>&1 
    unzip -d /etc/openvpn/ /etc/openvpn/vpn.zip
    rm -f /etc/openvpn/vpn.zip
    chown -R root:root /etc/openvpn/server/easy-rsa/
}
function config_easy() {
    cd
    mkdir -p /usr/lib/openvpn/
    cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so /usr/lib/openvpn/openvpn-plugin-auth-pam.so
    sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn
    systemctl enable --now openvpn-server@server-tcp
    systemctl enable --now openvpn-server@server-udp
    /etc/init.d/openvpn restart
}

function make_follow() {
    echo 1 > /proc/sys/net/ipv4/ip_forward
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
cat > /etc/openvpn/tcp.ovpn <<-END
client
dev tun
proto tcp
remote xxxxxxxxx 1194
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
    
    sed -i $MYIP2 /etc/openvpn/tcp.ovpn;
cat > /etc/openvpn/udp.ovpn <<-END
client
dev tun
proto udp
remote xxxxxxxxx 2200
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
    
    sed -i $MYIP2 /etc/openvpn/udp.ovpn;
cat > /etc/openvpn/ssl.ovpn <<-END
client
dev tun
proto tcp
remote xxxxxxxxx 990
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
    sed -i $MYIP2 /etc/openvpn/ssl.ovpn;
}
function cert_ovpn() {
    echo '<ca>' >> /etc/openvpn/tcp.ovpn
    cat /etc/openvpn/server/ca.crt >> /etc/openvpn/tcp.ovpn
    echo '</ca>' >> /etc/openvpn/tcp.ovpn
    cp /etc/openvpn/tcp.ovpn /home/vps/public_html/tcp.ovpn
    
    echo '<ca>' >> /etc/openvpn/udp.ovpn   
    cat /etc/openvpn/server/ca.crt >> /etc/openvpn/udp.ovpn
    echo '</ca>' >> /etc/openvpn/udp.ovpn
    cp /etc/openvpn/udp.ovpn /home/vps/public_html/udp.ovpn
    
    echo '<ca>' >> /etc/openvpn/ssl.ovpn
    cat /etc/openvpn/server/ca.crt >> /etc/openvpn/ssl.ovpn
    echo '</ca>' >> /etc/openvpn/ssl.ovpn
    cp /etc/openvpn/ssl.ovpn /home/vps/public_html/ssl.ovpn
    cd /home/vps/public_html/
    zip OpenVPN.zip tcp.ovpn udp.ovpn ssl.ovpn
    cd
}

function install_ovpn() {
    ovpn_install
    config_easy
    make_follow
    make_follow
    cert_ovpn
    systemctl enable openvpn
    systemctl start openvpn
    /etc/init.d/openvpn restart
    
}
install_ovpn
echo -e "===============================" | lolcat
echo -e "      Done Install OpenVPN  "
echo -e "===============================" | lolcat
echo -e "  PORT OpenVPN UDP     : 2200     "
echo -e "  PORT OpenVPN TCP     : 1194      "
echo -e "  PORT OpenVPN SSL     : 990      "
echo -e "===============================" | lolcat
echo -e "      Script By MakhlukVpn     "
echo -e "===============================" | lolcat
#hapus sc
rm /root/openvpn.sh
sleep 2
