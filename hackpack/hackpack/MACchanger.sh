#!/bin/bash

#MACchanger script writen by em3rgency
#This script will automate the boring task of constantly changing your mac address of you NIC
#It is very important you change your MAC address of you NIC if you are doing any kind of wireless pentesting.


#DEFINED COLOR SETTINGS
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0)
BLUE=$(tput setaf 6 && tput bold)


echo ""
echo ""
echo ""
echo $RED"              +############################################+"
echo $RED"              +       em3rgency's MACchanger Script        +"
echo $RED"              +                                            +"
echo $RED"              +                Version 1.0                 +"
echo $RED"              +                                            +"
echo $RED"              +             www.em3rgency.com              +"
echo $RED"              +############################################+"
echo ""
echo $BLUE"     Visit http://www.em3rgency.com for updates to this script. Thanks" $BLUE
echo ""
echo ""
echo ""
 
echo -n " Finding your Network Interfaces for you... "$GREEN
sleep 2
echo ""
ifconfig -a | cut -d " " -f1 | sed '/^$/d' | egrep -v 'lo|vm'
echo ""

echo $BLUE" Please enter the the interface you want the mac to change for EG. mon0 or wlan0: "
read NIC
echo ""
sleep 2
clear


echo $RED"              +############################################+"
echo $RED"              +       em3rgency's MACchanger Script        +"
echo $RED"              +                                            +"
echo $RED"              +                Version 1.0                 +"
echo $RED"              +                                            +"
echo $RED"              +             www.em3rgency.com              +"
echo $RED"              +############################################+"
echo ""
echo $BLUE"     Visit http://www.em3rgency.com for updates to this script. Thanks" $BLUE
echo ""
echo ""
echo ""
sleep 2
echo " Taking Your Interface Down... "
ifconfig $NIC down
sleep 2
echo ""
echo ""
echo " Changing your MAC address... "
macchanger -r $NIC
sleep 2
echo ""
echo ""
echo " Bringing your Interface Up... "
ifconfig $NIC up
echo ""
echo ""
echo "Your Mac is now random Thank you for using MAC changer! "
echo ""
echo ""
read -p "Please press ENTER to exit the script"



