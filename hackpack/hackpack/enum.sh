#!/bin/bash

clear
#DEFINED COLOR SETTINGS
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0)
BLUE=$(tput setaf 6 && tput bold)



echo ""
echo ""
echo ""
echo $RED"              +##############################################+"
echo $RED"              +     em3rgency's Domain enumeration script    +"
echo $RED"              +                                              +"
echo $RED"              +                  Version 1.0                 +"
echo $RED"              +                                              +"
echo $RED"              +               www.em3rgency.com              +"
echo $RED"              +##############################################+"
echo ""
echo $BLUE"     Visit http://www.em3rgency.com for updates to this script. Thanks"
echo ""
echo $BLUE"   This script will perform various reconnaissance on your target domain."
sleep 3
clear



echo ""
echo $RED"                   **************************************";
echo $RED"                   *    1.  WHOIS lookup                *";
echo $RED"                   *    2.  Dig and host list           *";
echo $RED"                   *    3.  TCP traceroute              *";
echo $RED"                   *    4.  DNS enumeration             *";
echo $RED"                   *    5.  Fierce                      *";
echo $RED"                   *    6.  Nmap                        *"; 
echo $RED"                   *    7.  Enumerate ALL               *"; 
echo $RED"                   *    8.  EXIT                        *"; 
echo $RED"                   **************************************";

echo $BLUE"                           Select Menu Option:"$STAND
read menuoption

if [ $menuoption = "1" ]; then
echo "Enter the target EG. domain.org"
read target
whois $target
echo ""
read -p "Please press ENTER to return to the menu"
./enum.sh
else


if [ $menuoption = "2" ]; then
echo "Enter the target EG. domain.org"
read target
dig $target any
echo ""
echo ""
host -l $target
echo ""
read -p "Please press ENTER to return to the menu"
./enum.sh
else

if [ $menuoption = "3" ]; then
echo "Enter the target EG. domain.org"
read target
echo ""
echo $STAND"Please type the name of your network interface Example: eth0 "
read IFACE;
echo ""
echo ""
tcptraceroute -i $IFACE $target
./enum.sh
else

if [ $menuoption = "4" ]; then
echo "Enter the target EG. domain.org"
read target
echo ""
cd /pentest/enumeration/dns/dnsenum
perl dnsenum.pl --enum -f dns.txt --update a -r $target
echo ""
read -p "Please press ENTER to return to the menu"
./enum.sh
else

if [ $menuoption = "5" ]; then
echo "Enter the target EG. domain.org"
read target
echo ""
cd /pentest/enumeration/dns/fierce
perl fierce.pl -dns $target
echo ""
read -p "Please press ENTER to return to the menu"
./enum.sh
else

if [ $menuoption = "6" ]; then
echo "Enter the target EG. domain.org"
read target
echo ""
cd /root
nmap -PN -n -F -T4 -sV -A -oG $target.txt $target
echo ""
read -p "Please press ENTER to return to the menu"
./enum.sh
else

if [ $menuoption = "7" ]; then
echo "Enter the target EG. domain.org"
read target
echo ""
echo ""
whois $target
echo ""
echo ""
dig $target any
echo ""
echo ""
host -l $target
echo ""
echo ""
tcptraceroute -i eth0 $target
echo ""
echo ""
cd /pentest/enumeration/dns/dnsenum
perl dnsenum.pl --enum -f dns.txt --update a -r $target
echo ""
echo ""
echo dnstracer $target
dnstracer $target
echo ""
echo ""
cd /pentest/enumeration/dns/fierce
perl fierce.pl -dns $target
echo ""
echo ""
cd /pentest/enumeration/web/lbd
./lbd.sh $target
echo ""
echo ""
cd /pentest/enumeration/list-urls
./list-urls.py http://www.$target
echo ""
echo ""
cd /root
nmap -PN -n -F -T4 -sV -A -oG $target.txt $target
echo ""
echo ""
amap -i $target.txt
echo ""
echo ""
cd /pentest/enumeration/web/httprint/linux
./httprint -h www.$target -s signatures.txt -P0
echo ""
echo ""
read -p "Please press ENTER to return to the menu"
./enum.sh
else

if [ $menuoption = "8" ]; then
exit
fi
fi
fi
fi
fi
fi
fi
fi















