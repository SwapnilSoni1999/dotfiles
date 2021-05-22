yum install -y squid iptables nano
systemctl start squid
systemctl enable squid
systemctl status squid

cp /etc/squid/squid.conf{,.orginal}
rm /etc/squid/squid.conf
curl https://raw.githubusercontent.com/SwapnilSoni1999/dotfiles/main/squid.conf > /etc/squid/squid.conf
RESULT_IPTABLE=$(curl https://raw.githubusercontent.com/SwapnilSoni1999/dotfiles/main/iptables)
iptables $RESULT_IPTABLE
touch /etc/squid/allowed_ips.txt

echo "===========INSTALLATION COMPLETE============"
echo "You can add your whitelisted ip to /etc/squid/allowed_ips.txt"
echo "Squid Port: 6789"
echo "Once done run: systemctl restart squid"
echo "============================================"
