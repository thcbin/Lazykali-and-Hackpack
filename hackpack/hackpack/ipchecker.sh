#!/bin/bash

clear



echo "######################################"
echo "#    http://www.top-hat-sec.com      #"
echo "#   Email: admin@top-hat-sec.com     #"
echo "#      Challenge = Opportunity       #"
echo "######################################"

echo ""
echo ""
echo "Checking Assigned ISP IP Address"
echo "This may take a few seconds"
echo ""
echo "Your IP is: "
curl -s checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
echo ""
echo "If you do not see your IP address, you may not be connected to the internet."


