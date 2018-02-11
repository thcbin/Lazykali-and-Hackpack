#!/bin/bash

clear
echo
echo Recon
echo
echo
echo By Lee Baird
echo March 26, 2009
echo "v 0.11"
echo
echo "This script will perform various reconnaissance on your target."
echo
echo Usage:  domain.com
echo Enter the domain.
echo
read domain
echo
echo "###########################################################################################"
echo
echo "whois" $domain
whois $domain
echo "###########################################################################################"
echo
echo "dig" $domain "any"
dig $domain any
echo "###########################################################################################"
echo
echo "host -l" $domain
echo
host -l $domain
echo
echo "###########################################################################################"
echo
echo "tcptraceroute -i eth0" $domain
echo
tcptraceroute -i eth0 $domain
echo
echo "###########################################################################################"
echo
echo "cd /pentest/enumeration/dnsenum"
echo "perl dnsenum.pl --enum -f dns.txt --update a -r" $domain
echo
cd /pentest/enumeration/dnsenum
perl dnsenum.pl --enum -f dns.txt --update a -r $domain
echo
echo "###########################################################################################"
echo
echo dnstracer $domain
echo
dnstracer $domain
echo
echo "###########################################################################################"
echo
echo "cd /pentest/enumeration/fierce"
echo "perl fierce.pl -dns" $domain
echo
cd /pentest/enumeration/fierce
perl fierce.pl -dns $domain
echo
echo "###########################################################################################"
echo
echo "cd /pentest/enumeration/lbd"
echo "./lbd.sh" $domain
cd /pentest/enumeration/lbd
./lbd.sh $domain
echo "###########################################################################################"
echo
echo "cd /pentest/enumeration/list-urls"
echo "./list-urls.py http://www."$domain
cd /pentest/enumeration/list-urls
./list-urls.py http://www.$domain
echo
echo "###########################################################################################"
echo
echo "nmap -PN -n -F -T4 -sV -A -oG temp.txt" $domain
cd /root
nmap -PN -n -F -T4 -sV -A -oG temp.txt $domain
echo
echo "###########################################################################################"
echo
echo "amap -i temp.txt"
amap -i temp.txt
echo
echo "###########################################################################################"
echo
echo "cd /pentest/enumeration/www/httprint/linux"
echo "./httprint -h www."$domain "-s signatures.txt -P0"
echo
cd /pentest/enumeration/www/httprint/linux
./httprint -h www.$domain -s signatures.txt -P0
echo
echo "###########################################################################################"
