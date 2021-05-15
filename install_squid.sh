yum install -y squid
systemctl start squid
systemctl enable squid
systemctl status squid

cp /etc/squid/squid.conf{,.orginal}
rm /etc/squid/squid.conf
curl https://raw.githubusercontent.com/SwapnilSoni1999/dotfiles/main/squid.conf > /etc/squid/squid.conf
RESULT_IPTABLE=$(curl https://raw.githubusercontent.com/SwapnilSoni1999/dotfiles/main/iptables)

echo "===========INSTALLATION COMPLETE============"
echo "Add the following line to /etc/sysconfig/iptables"
echo $RESULT_IPTABLE
echo "Squid Port: 6969"
echo "============================================"
