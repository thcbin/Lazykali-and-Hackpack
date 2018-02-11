#!/bin/bash
#NAME=Passive Fingerprinting

#	Hax0rBl0x - 70_Passive_Fingerprint.sh
#	Copyright (C) 2013  Dopey and ShadowBlade72
#	Version 1.2
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http://www.gnu.org/licenses/>.

#### DO NOT EDIT ABOVE THIS LINE ####
#### EDIT USER VARIABLES BELOW THIS LINE ####

Report_File="$HOME/Passive_Fingerprint_Report_$(date +%d%b%y:%H%M).txt"
Refresh_Time=10 #Recommend 30 seconds for RaspberryPI
Generate_Report_Time=10

#### EDIT USER VARIABLES ABOVE THIS LINE ####
#### DO NOT EDIT BELOW THIS LINE ####
 
#Trap keyboard interrupt (control-c)
trap control_c SIGINT

#Declare arrays and define variables
Ettercap_Passive_Log="/tmp/.passive_ettercap_data.eci"
Temp_Etterlog_XML="/tmp/.temp_etterlog_output.txt"
Passive_Log_File="/tmp/.p0f_reports.txt"
Temp_Sorted_XML="/tmp/.temp_sorted_XML.txt"
declare -a Wireless_Interface IP_Array App_Array Number_Apps_Array OS_Array Browser_Array Number_Browser_Array Check_App Uptime_Array LastSeen_Array Mac_Array Type_Array Ports_Array Number_Ports_Array Manuf_Array Android_Array
past_display_time=`date +%s`
next_etterlog_time=`date +%s`
next_report_time=`date +%s`
LineNumber=0
LineNumberPOF=0
LineNumberEtt=0
LineNumberPrev=0
ReportsRemaining=0
SETT=0
SPOF=0
OrigSTTY=`stty -g`

#Grabbing all wireless interfaces
Wireless_Interface=(`ip link show | awk -F: '/^[0-9]/ {print $2}'`)
Number_Interfaces="${#Wireless_Interface[@]}"

#Sanity Checks
fnSanityCheck() {
	POF=0
	clear
	echo -e "Sanity check in progress... "
	fnPOFCheck
	fnEttercapCheck
	#Add in any dependances you want to check for using a ||. Example: $POF -eq 1 || $EXAMPLE -eq 1 
	if [[ $POF -eq 1 || $ETTERCAP -eq 1 ]]; then
		fnInstallCheck
	else
		echo -e "$(tput setaf 2)[+]$(tput sgr0) Sanity check successful. All dependencies found."
		sleep 1
		fnMainMenu
	fi
}

fnPOFCheck() {
	echo -e "$(tput setaf 2)[+]$(tput sgr0) p0f version check... \c"
	p0f -i vercheck > /tmp/.pofcheck 2>&1
	eval `cat /tmp/.pofcheck | head -n1 | awk '{for(i=1;i<NF;i++) {if ($i ~ /p0f|version/) {ver=$(++i); gsub (/[[:alpha:]]|\./,"",ver);print "VER="ver; } } }'`
	rm /tmp/.pofcheck
	if [[ $VER -ge 306  ]]; then
		echo -e "$(tput setaf 2)Success$(tput sgr0)"
	else
		echo -e "$(tput setaf 1)Failed!$(tput sgr0)"
		ETTERCAP=1
	fi
}

fnEttercapCheck() {
	echo -e "$(tput setaf 2)[+]$(tput sgr0) Ettercap check... \c"
	if [[ -e `which ettercap` ]]; then
		echo -e "$(tput setaf 2)Success$(tput sgr0)"
	else
		echo -e "$(tput setaf 1)Failed!$(tput sgr0)"
		POF=1
	fi
}

fnInstallCheck() {
	while :; do
		echo -e "$(tput sgr0)\nWould you like to install the missing dependancies [yes]? \c"
		read Selection
		if [[ -z $Selection ]]; then 
			fnInstallDependancies
		else
			case $Selection in
			y|Y|YES|yes|Yes) fnInstallDependancies;;
			n|N|no|NO|No) control_c;;
			*) echo -e "Please enter yes or no.\n\n"
			sleep 2
			esac
		fi
	done
}

fnInstallDependancies() {
	echo -e "$(tput sgr0) \nInstalling dependancies..."
	if [[ $UID -eq 0 ]]; then
		if [[ $POF -eq 1 ]]; then
			echo -e "$(tput setaf 2) \n[+]$(tput sgr0) Installing p0f version 3.06b...\c"
				cd /tmp > /dev/null 2>&1
				echo -e ".\c"
				wget lcamtuf.coredump.cx/p0f3/releases/p0f-3.06b.tgz > /dev/null 2>&1
				echo -e ".\c"
				if [[ ! -e /tmp/p0f-3.06b.tgz ]]; then
					echo -e "$(tput setaf 1)Failed! Could not connect to server$(tput sgr0)"
					sleep 1
					control_c
				fi
				tar -xvf /tmp/p0f-3.06b.tgz > /dev/null 2>&1
				echo -e ".\c"
				rm /tmp/p0f-3.06b.tgz > /dev/null 2>&1
				echo -e ".\c"
				cd /tmp/p0f-3.06b/ > /dev/null 2>&1
				echo -e ".\c"
				make > /dev/null 2>&1
				echo -e ".\c"
				mv p0f /usr/sbin/p0f > /dev/null 2>&1
				rc=$?
				echo -e ".\c"
				mv p0f.fp /etc/p0f > /dev/null 2>&1
				echo -e ".\c"
				cd ~
				echo -e ".\c"
				rm -R /tmp/p0f-3.06b/ > /dev/null 2>&1
				echo -e ".$(tput sgr0)\c"
				if [[ $rc -eq 0 ]]; then
					echo -e "$(tput setaf 2)Success$(tput sgr0)"
					sleep 1					
				else
					echo -e "$(tput setaf 1)Failed!$(tput sgr0)"
					sleep 1
				fi
		fi
		if [[ $ETTER -eq 1 ]]; then
			echo -e "$(tput setaf 2)\n[+]$(tput sgr0) Installing ettercap... \c"
			apt-get install ettercap-graphical >/dev/null 2>&1
			rc=$?
			echo -e ".\c"
			if [[ $rc -eq 0 ]]; then
				echo -e "$(tput setaf 2)Success$(tput sgr0)"
				sleep 1
			else
				echo -e "$(tput setaf 1)Failed!$(tput sgr0)"
				sleep 1
			fi
		fi
	else
		echo -e "$(tput setaf 1)[-]$(tput sgr0) You must be root to install dependances!\n"
		control_c
	fi
	fnSanityCheck
}

control_c()
#Run if user hits control-c
{
	tput sgr0
	clear
	echo -e "Cleaning up! Please wait..."
	if [[ $SPOF -eq 1 && $PIDPOF && `ps -ef | grep -v grep | grep -i $PIDPOF` ]]; then
		echo -e "$(tput setaf 2)[+]$(tput sgr0) Killing p0f...\c"
		kill $PIDPOF
		rc=$?
		if [[ $rc -eq 0 ]]; then
			echo -e "$(tput setaf 2)Success$(tput sgr0)"
		else
			echo -e "$(tput setaf 1)Failed!$(tput sgr0)"
		fi
	fi
	if [[ $SETT -eq 1 && $PIDETTERCAP && `ps -ef | grep -v grep | grep -v xterm | grep -i $PIDETTERCAP` ]]; then
		echo -e "$(tput setaf 2)[+]$(tput sgr0) Killing ettercap...\c"
		kill -9 $PIDETTERCAP
		rc=$?
		if [[ $rc -eq 0 ]]; then
			echo -e "$(tput setaf 2)Success$(tput sgr0)"
		else
			echo -e "$(tput setaf 1)Failed!$(tput sgr0)"
		fi
	fi
	if [[ $ReportsRemaining -gt 0 ]]; then
		echo -e "$(tput setaf 1)[-]$(tput sgr0)Unprocessed Reports: $ReportsRemaining... Would you like to process these before exiting? [yes]: \c"
		read SelectionInit
		Selection=$(tr '[:upper:]' '[:lower:]' <<<$SelectionInit)
		if [[ -z $Selection || $Selection == "yes" || $Selection == "y" || $Selection == "ye" ]]; then
		echo -e "$(tput setaf 1)[-]$(tput sgr0)This may take a while... Please be patient."
		past_display_time=$((`date +%s` + `date +%s`))
		fnSniff_Etterlog
		fnSniff_POF
		fi
	fi
	echo -e "$(tput setaf 2)[+]$(tput sgr0) Generating final report...\c"
	fnGenerate_Report
	echo -e "$(tput setaf 2)Complete$(tput sgr0)"
	if [[ $SPOF -eq 1 && -f $Passive_Log_File ]]; then
		echo -e "$(tput setaf 2)[+]$(tput sgr0) Deleting p0f output file...\c"
		rm $Passive_Log_File
		echo -e "$(tput setaf 2)Complete$(tput sgr0)"
	fi
	if [[ $SETT -eq 1 && -f $Ettercap_Passive_Log ]]; then
		echo -e "$(tput setaf 2)[+]$(tput sgr0) Deleting Ettercap output file...\c"
		rm $Ettercap_Passive_Log
		echo -e "$(tput setaf 2)Complete$(tput sgr0)"
	fi
	if [[ `pgrep Hax0rBl0x` ]]; then
		echo -e "\n*** Returning to main menu... ***\n"
	else
		echo -e "\n*** Exiting script... ***\n"
	fi
	stty $OrigSTTY
	exit
}

fnMainMenu()
{
	check=0
	while [[ $check -ne 1 ]]; do
		clear
		echo -e "****************** Passive Fingerprinting Script ******************\n"
		echo -e "Please enter interface: \c"
		read Selection
		if [ -z "$Selection" ]; then
			echo "No input. Exiting function."
			sleep 2
			control_c
		fi

		#See if input is an interface
		count=0
		while [[ $count -ne $Number_Interfaces ]]; do
			if [[ "$Selection" == "${Wireless_Interface[$count]}" ]]; then
				check=1
				Interface="$Selection"
				Source="-i $Selection"
				count=$Number_Interfaces
			else
				((count++))
			fi
		done
		
		#See if input is a file
#		if [ -f $Selection ]; then
#			check=1
#			Source="-r $Selection"
#		fi
		if [[ $check -eq 0 ]]; then
			echo "Error! '$Selection' is not an interface!"
			sleep 3
		fi
	done

	#Set Current Network
	Current_Network=$(ifconfig $Interface | awk -F ' *|:' '/inet ad*r/{split($4,a,"\\."); printf("%d.%d.%d\n", a[1],a[2],a[3])}')
	fnStart_p0f
	fnStart_Ettercap
	sleep 1
	fnSniff_It
}

fnStart_p0f()
{
	echo -e "$(tput setaf 2)[+]$(tput sgr0) Checking for previous instances of p0f...\c"
	PIDPOF=$(ps -ef | grep -v grep | grep -v xterm | grep -i p0f | grep -i "\-o $Passive_Log_File" | head -n1 | awk '{ print $2 }')
	if [[ $PIDPOF ]]; then
		echo -e "$(tput setaf 2) found!\n  [+]$(tput sgr0) p0f logging is running...\c"
		echo "$(tput setaf 2)Complete$(tput sgr0) [PID: $PIDPOF]"
		if [[ -f $Passive_Log_File ]]; then
			return
		else
			echo -e "$(tput setaf 1)[-]$(tput sgr0) p0f log file not found...\c"
		fi
	else
		echo "$(tput setaf 2)None found$(tput sgr0)"
	fi
	echo -e "$(tput setaf 2)[+]$(tput sgr0) Starting p0f in background...\c"
	SPOF=1
	p0f $Source -f /etc/p0f/p0f.fp -o $Passive_Log_File >/dev/null 2>&1 &
	PIDPOF=$!
	sleep 1
	if [[ `ps -ef | grep -i p0f | grep -i $PIDPOF` ]]; then
		echo "$(tput setaf 2)Success$(tput sgr0) [PID: $PIDPOF]"
	else
		echo -e "$(tput setaf 1)Failed$(tput sgr0)"
		sleep 3
		control_c
	fi
	sleep 1
}

fnStart_Ettercap()
{
	echo -e "$(tput setaf 2)[+]$(tput sgr0) Checking for previous instances of Ettercap...\c"
	EttercapLogClean=`echo $Ettercap_Passive_Log | awk -F'\n' '{ gsub (/\.eci/,"",$1); print $1 }'`
	PIDETTERCAP=$(ps -ef | grep -v grep | grep -v xterm | grep -i "ettercap" | grep -i "\-l $EttercapLogClean" | head -n1 | awk '{ print $2 }')
	if [[ $PIDETTERCAP ]]; then
		echo -e "$(tput setaf 2) found!\n  [+]$(tput sgr0) Ettercap logging is running...\c"
		echo "$(tput setaf 2)Complete$(tput sgr0) [PID: $PIDETTERCAP]"
		if [[ -f $Ettercap_Passive_Log ]]; then
			return
		else
			echo -e "$(tput setaf 1)[-]$(tput sgr0) Ettercap log file not found...\c"
		fi
	else
		echo "$(tput setaf 2)None found$(tput sgr0)"
	fi
	echo -e "$(tput setaf 2)[+]$(tput sgr0) Starting Ettercap in background...\c"
	SETT=1
	ettercap -TQ -i $Interface -u -l $EttercapLogClean  >/dev/null 2>&1 &
	PIDETTERCAP=$!
	sleep 1
	if [[ `ps -ef | grep -i ettercap | grep -i $PIDETTERCAP` ]]; then
		echo "$(tput setaf 2)Success$(tput sgr0) [PID: $PIDETTERCAP]"
	else
		echo -e "$(tput setaf 1)Failed$(tput sgr0)"
		sleep 3
		control_c
	fi
	sleep 1
}

fnSniff_Etterlog()
{
	etterlog -x $Ettercap_Passive_Log > $Temp_Etterlog_XML 2>&1
	perl -e'$x=join("",<STDIN>);$x=~s/\s*[\r\n]+\s*//gs; $x=~s/^.*?(<host.*<\/host>).*?$/$1/i;$x=~s/<\/host>/<\/host>\n/gi;print $x;' <$Temp_Etterlog_XML >$Temp_Sorted_XML
	rm $Temp_Etterlog_XML
	for LINE in `cat $Temp_Sorted_XML`; do
		if [[ `date +%s` -gt $(( $past_display_time + ( $Refresh_Time -1 ))) ]]; then
			past_display_time=`date +%s`
			fnStats
			fnDisplay_Info	
		fi
		((LineNumberEtt++))	
		fnParse_Data
	done
	rm $Temp_Sorted_XML
}

fnSniff_POF() {
for LINE in `tail -"$ReportsRemaining" "$Passive_Log_File"`; do
		if [[ `date +%s` -gt $(( $past_display_time + ( $Refresh_Time -1 ))) ]]; then
			past_display_time=`date +%s`
			fnStats
			fnDisplay_Info	
		fi
		fnParse_Data
		((ReportsRemaining--))
done
}

fnSniff_It()
{
	fnDisplay_Info	
	IFS=$'\n'
	LineNumber=0
	while :; do
		fnStats
		fnSniff_POF
		if [[ -f $Ettercap_Passive_Log && `date +%s` -gt $next_etterlog_time ]]; then
			next_etterlog_time=$(( `date +%s` + 10 ))
			fnSniff_Etterlog
		fi
	done
}

fnStats() {
	LineNumberPrev=$LineNumberPOF
	LineNumberPOF=`cat $Passive_Log_File | wc -l`
	LineNumber=$((LineNumberPOF + LineNumberEtt))
	ReportsRemaining=$(((LineNumberPOF - LineNumberPrev) + ReportsRemaining))
}

fnParse_Data()
{
	if [[ -z "$LINE" ]]; then
		return;
	fi
	
	#See if data is from etterlog. If so, extract it. Otherwise, pull p0f data
	if [[ "$(echo $LINE | awk '{ print $1 }')" == "<host" ]]; then
		eval `echo $LINE | awk -F\> '{for(i=1;i<=NF;i++) { if($i ~ /host ip=/) { cl=$i; gsub(/.*=|\/.*/,"",cl); } if(i==NF) { printf "export Client=\"%s\"",cl; cl=""; } } }'`	
		Mac=`echo $LINE | awk -vRS="</mac>" '{gsub(/.*<mac.*>/,"");print}' | head -n 1`
		Manuf=`echo $LINE | awk -vRS="</manuf>" '{gsub(/.*<manuf.*>/,"");print}' | head -n 1`
		Type=`echo $LINE | awk -vRS="</type>" '{gsub(/.*<type.*>/,"");print}' | head -n 1`
		Subject="cli"
		eval `echo $LINE | awk  -F'[ =<>]' '{ count=0; { printf "declare -a PORTS" } for(i=1;i<NF;i++) { if ($i ~ /proto/) { proto=$(++i); gsub (/\"/,"",proto); }if ($i ~ /addr/) { addr=$(++i); gsub (/\"/,"",addr); count++; } if ($i ~ /service/) { service=$(++i); gsub (/\"/,"",service); } if (proto != "" && addr != "" && service != "") { printf "export PORTS[%d]=\"%s:%d - %s\" ",count,proto,addr,service; proto=addr=service="";} } }'`
	else	
		eval `echo $LINE | awk -F'[; |]' '{ for(i=1;i<=NF;i++) { if($i ~ /subj=/) { sb=$i; gsub(/.*=/,"",sb); } if($i ~ /Android/) { an=$i" "$(i+1)" "$(i+3); } if($i ~ /srv=/) { sr=$i; gsub(/.*=|\/.*/,"",sr); } if($i ~ /cli=/) { cl=$i; gsub(/.*=|\/.*/,"",cl); } if($i ~ /os=/) { os=$i; gsub(/.*=/,"",os); } if($i ~ /app=/) { ap=$i; gsub(/.*=/,"",ap); } if($i ~ /uptime=/) { up=$i; gsub(/.*=/,"",up); } if(i==NF) { printf "export Subject=\"%s\" export Server=\"%s\" export Client=\"%s\" export OS=\"%s\" export App=\"%s\" export Uptime=\"%s\" export Android=\"%s\"",sb,sr,cl,os,ap,up,an; sb=sr=cl=os=ap=up=an=""; } } }'`
	fi

	#File garnered data below
	#Check where client is located.
	Client_Network=$(echo $Client | awk '{split($1,a,"\\."); printf("%d.%d.%d\n", a[1],a[2],a[3])}')
	#If client is in network find last octet for use in array location	
	if [ "$Client_Network" == "$Current_Network" ]; then
		Location=$(echo $Client | awk '{split($1,a,"\\."); printf("%d\n", a[4])}')
		if [[ $Client ]]; then
			IP_Array[$Location]=$Client
			if [[ "$(echo $LINE | awk '{ print $1 }')" != "<host" ]]; then
				LastSeen_Array[$Location]=`date +%s`
			fi
		fi
		if [[ "$Subject" == "cli" && $OS && "$OS" != "???" ]]; then
			OS_Array[$Location]=$OS
			if [[ "Android" ]]; then
				OS_Array[$Location]="${OS_Array[$Location]} ($Android)"
			fi
				
		fi
		if [[ "$Subject" == "cli" && "$Android" ]]; then
			Android_Array[$Location]="$Android"
		fi
		if [[ "$Subject" == "cli" && $App && "$App" != "???" ]]; then
			tempapp=$(echo $App | awk '{print $1}')
			if [[ "$tempapp" == "MSIE" || "$tempapp" == "Firefox" || "$tempapp" == "Chrome" || "$tempapp" == "Safari" || "$tempapp" == "Opera" ]]; then
				if [[ "${Browser_Array[$Location]}" ]]; then
					included=0
					count=0
					eval `echo ${Browser_Array[$Location]} | awk -F', ' '{for(i=0;i<=NF;i++) {printf "\nCheck_App[%d]=\"%s\"",i,$i;}}'`
					Number_App="${#Check_App[@]}"
					while [[ $count -ne $Number_App ]]; do
						if [ "${Check_App[$count]}" == "$App" ]; then
							included=1
						fi
						((count++))
					done
					if [[ $included -eq 0 ]]; then
						Browser_Array[$Location]="${Browser_Array[$Location]}, $App"
						Number_Browser_Array[$Location]=$Number_App
					fi
					unset Check_App
				else
					Browser_Array[$Location]="$App"
					Number_Browser_Array[$Location]=1
				fi	
			else
				if [[ "${App_Array[$Location]}" ]]; then
					included=0
					count=0
					eval `echo ${App_Array[$Location]} | awk -F', ' '{for(i=0;i<=NF;i++) {printf "\nCheck_App[%d]=\"%s\"",i,$i;}}'`
					Number_App="${#Check_App[@]}"
					while [[ $count -ne $Number_App ]]; do
						if [[ "${Check_App[$count]}" == "$App" ]]; then
							included=1
						fi
						((count++))
					done
					if [[ $included -eq 0 ]]; then
						App_Array[$Location]="${App_Array[$Location]}, $App"
						Number_Apps_Array[$Location]=$Number_App
					fi
					unset Check_App
				else
					App_Array[$Location]="$App"
					Number_Apps_Array[$Location]=1	
				fi	
			fi
				
		fi
	
		if [[ "$Subject" == "cli" && $Uptime && "$Uptime" != "???" ]]; then
			Uptime_Array[$Location]=$Uptime
		fi
		if [[ $Mac ]]; then
			Mac_Array[$Location]="$Mac"
		fi
		if [[ $Type ]]; then
			Type_Array[$Location]="$Type"
		fi
		if [[ $Manuf ]]; then
			Manuf_Array[$Location]="$Manuf"
		fi
		if [[ ${PORTS[1]} ]]; then
			Number_Ports="${#PORTS[@]}"
			Ports_Array[$Location]="${PORTS[1]}"
			count=2
			while [[ $count -le $Number_Ports ]]; do
				Ports_Array[$Location]="${Ports_Array[$Location]} | ${PORTS[$count]}"
				((count++))
			done
			Number_Ports_Array[$Location]=$Number_Ports
		fi
			 
	fi

	#If Server is in network find last octet for use in array location	
	Server_Network=$(echo $Server | awk '{split($1,a,"\\."); printf("%d.%d.%d\n", a[1],a[2],a[3])}')
	if [[ "$Server_Network" == "$Current_Network" ]]; then
		Location=$(echo $Server | awk '{split($1,a,"\\."); printf("%d\n", a[4])}')
		if [[ $Server ]]; then
			IP_Array[$Location]=$Server
			LastSeen_Array[$Location]=`date +%s`
		fi
		if [[ "$Subject" == "srv" && $OS && "$OS" != "???" ]]; then
			OS_Array[$Location]=$OS
		fi
		if [[ "$Subject" == "srv" && "$Android" ]]; then
			Android_Array[$Location]="$Android"
		fi
		if [[ "$Subject" == "srv" && $App && "$App" != "???" ]]; then
			tempapp=$(echo $App | awk '{print $1}')
			if [[ "$tempapp" == "MSIE" || "$tempapp" == "Firefox" || "$tempapp" == "Chrome" || "$tempapp" == "Safari" || "$tempapp" == "Opera" ]]; then
				if [ "${Browser_Array[$Location]}" ]; then
					included=0
					count=0
					eval `echo ${Browser_Array[$Location]} | awk -F', ' '{for(i=0;i<=NF;i++) {printf "\nCheck_App[%d]=\"%s\"",i,$i;}}'`
					Number_App="${#Check_App[@]}"
					while [[ $count -ne $Number_App ]]; do
						if [[ "${Check_App[$count]}" == "$App" ]]; then
							included=1
						fi
						((count++))
					done
					if [[ $included -eq 0 ]]; then
						Browser_Array[$Location]="${Browser_Array[$Location]}, $App"
						Number_Browser_Array[$Location]=$Number_App
					fi
					unset Check_App
				else
					Browser_Array[$Location]="$App"
					Number_Browser_Array[$Location]=1
				fi	
			else
				if [[ "${App_Array[$Location]}" ]]; then
					included=0
					count=0
					eval `echo ${App_Array[$Location]} | awk -F', ' '{for(i=0;i<=NF;i++) {printf "\nCheck_App[%d]=\"%s\"",i,$i;}}'`
					Number_App="${#Check_App[@]}"
					while [[ $count -ne $Number_App ]]; do
						if [[ "${Check_App[$count]}" == "$App" ]]; then
							included=1
						fi
						((count++))
					done
					if [[ $included -eq 0 ]]; then
						App_Array[$Location]="${App_Array[$Location]}, $App"
						Number_Apps_Array[$Location]=$Number_App
					fi
					unset Check_App
				else
					App_Array[$Location]="$App"
					Number_Apps_Array[$Location]=1
				fi	
			fi
				
		fi

		if [[ "$Subject" == "srv" && $Uptime && "$Uptime" != "???" ]]; then
			Uptime_Array[$Location]=$Uptime
		fi

	fi
	#Unset ports
	unset Subject Client Server OS App Location Client_Network Server_Network tempapp Mac Type Manuf Uptime
}

fnDisplay_Info()
{
	clear
	Timestamp=`date +"%r"`
	count=1
	Number_of_Lines=0
	echo -e "$(tput setaf 7)-=-=-=-=-=-=-=-=-=-=-=-=-=-=- Fingerprint Summary -=-=-=-=-=-=-=-=-=-=-=-=-=-=-$(tput sgr0)\n"
	echo -e "$(tput setaf 7)Generated:$(tput sgr0) $Timestamp   |   \c" #$(tput setaf 7)Ettercap info:$(tput sgr0) \c"
	#if [ -f $Ettercap_Passive_Log ]; then
	#	echo -e "$(tput setaf 2)Found$(tput sgr0)     | \c"
	#else
	#	echo -e "$(tput setaf 1)Not Found$(tput sgr0) | \c"
	#fi
	echo -e "$(tput setaf 7)Refresh:$(tput sgr0) "$Refresh_Time"s   |   \c"
	echo -e "$(tput setaf 7)Reports/Unprocessed:$(tput sgr0) $LineNumber/$ReportsRemaining$(tput sgr0)"
	#echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	#echo -e "$(tput setaf 7)Refresh Rate:$(tput sgr0) "$Refresh_Time"s                                $(tput setaf 7)Unprocessed Reports:$(tput sgr0) "$ReportsRemaining""
	echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo -e "(Note: IP will be green if seen less than 5 minutes ago)\n"
	echo -e "                  $(tput smul)  \c"
	echo -e "$(tput setaf 3)1$(tput sgr0)$(tput smul)   \c"
	echo -e "$(tput setaf 2)2$(tput sgr0)$(tput smul)   \c"
	echo -e "$(tput setaf 4)3$(tput sgr0)$(tput smul)   \c"
	echo -e "$(tput setaf 3)4$(tput sgr0)$(tput smul)   \c"
	echo -e "$(tput setaf 2)5$(tput sgr0)$(tput smul)   \c"
	echo -e "$(tput setaf 4)6$(tput sgr0)$(tput smul)   \c"
	echo -e "$(tput setaf 3)7$(tput sgr0)$(tput smul)   \c"
	echo -e "$(tput setaf 2)8$(tput sgr0)$(tput smul)  $(tput sgr0)"

	while [[ $count -ne 255 ]]; do
		if [[ ${IP_Array[$count]} ]]; then
			#Add 1 to number of lines
			((Number_of_Lines++))
			#Figure adjustments for gray dashes (Find max IP size)
			stringlength="${#IP_Array[$count]}"
			#stringlength=$(( $stringlength + 2 ))
			if [[ $MaxStringLength && $MaxStringLength -gt $stringlength ]]; then
				Spaces=$(( $MaxStringLength - $stringlength ))
			else
				MaxStringLength=$stringlength
			fi
			
			#Determine Color of IP Address
			if [[ ${LastSeen_Array[$count]} ]]; then
				seconds_past=$(( `date +%s` - ${LastSeen_Array[$count]} ))	
				if [[ $seconds_past -lt 300 ]]; then
					IPColor=2
				else
					IPColor=1
				fi
			else
				IPColor=1
			fi
			
			#Print IP address
			echo -e "$(tput setaf $IPColor)${IP_Array[$count]}$(tput sgr0) \c"
			
			#Print gray dashes						
			for i in `seq $stringlength 15`
			do
			    echo -e "$(tput setaf 0)-$(tput sgr0)\c"
			done
			echo -e " |$(tput smul) \c"
			
			#Display 1. Mac (3)
			if [[ ${Mac_Array[$count]} ]]; then
				echo -e "$(tput setaf 3)X$(tput sgr0)$(tput smul)\c"
			else
				echo -e "-\c"
			fi
			echo -e " | \c"

			#Display 2. OS (2)
			if [[ ${OS_Array[$count]} ]]; then
				echo -e "$(tput setaf 2)X$(tput sgr0)$(tput smul)\c"
			else
				echo -e "-\c"
			fi
			echo -e " | \c"

			#Display 3. Manufacturer (4)
			if [[ ${Manuf_Array[$count]} ]]; then
				echo -e "$(tput setaf 4)X$(tput sgr0)$(tput smul)\c"
			else
				echo -e "-\c"
			fi
			echo -e " | \c"

			#Display 4. Host Type (3)
			if [[ ${Type_Array[$count]} ]]; then
				echo -e "$(tput setaf 3)X$(tput sgr0)$(tput smul)\c"
			else
				echo -e "-\c"
			fi
			echo -e " | \c"

			#Display 5. Number of Browsers (2)
			if [[ ${Browser_Array[$count]} ]]; then
				echo -e "$(tput setaf 2)${Number_Browser_Array[$count]}$(tput sgr0)$(tput smul)\c"
			else
				echo -e "-\c"
			fi
			echo -e " | \c"
			
			#Display 6. Number of Apps (4)
			if [[ ${App_Array[$count]} ]]; then
				echo -e "$(tput setaf 4)${Number_Apps_Array[$count]}$(tput sgr0)$(tput smul)\c"
			else
				echo -e "-\c"
			fi
			echo -e " | \c"
			
			#Display 7. Number of Ports (3)
			if [[ ${Ports_Array[$count]} ]]; then
				echo -e "$(tput setaf 3)${Number_Ports_Array[$count]}$(tput sgr0)$(tput smul)\c"
			else
				echo -e "-\c"
			fi
			echo -e " | \c"

			#Display 8. Uptime (2)
			if [[ ${Uptime_Array[$count]} ]]; then
				echo -e "$(tput setaf 2)X$(tput sgr0)$(tput smul)\c"
			else
				echo -e "-\c"
			fi
			echo -e " |$(tput sgr0)"
		fi
		((count++))
	done

	#Display Color Key at bottom
	templines=$(( `tput lines` - 11 ))
	for i in `seq $Number_of_Lines $templines`
	do
	    echo -e ""
	done
	unset templines
	echo -e "1. MAC Address | \c"
	echo -e "2. OS | \c"
	echo -e "3. Manuf | \c"
	echo -e "4. Host Type | \c"
	echo -e "5. Num. of Browsers"
	echo -e "6. Num. of Apps | \c"
	echo -e "7. Num. of Ports | \c"
	echo -e "8. Uptime"
	
	#Generate Report
	if [[ `date +%s` -ge $next_report_time && $LineNumber > 10 ]]; then
		next_report_time=$((`date +%s` + $Generate_Report_Time))
		fnGenerate_Report
	fi
}

fnGenerate_Report()
{
	echo -e "-=-=-=-=-=-=-=-=-=-=- Fingerprint Report -=-=-=-=-=-=-=-=-=-=-\n" > $Report_File
	count=1
	Timestamp=`date`
	echo -e "Report generated: $Timestamp" >> $Report_File
	echo -e "Reports scanned: $LineNumber\n\n" >> $Report_File
	
	while [[ $count -ne 255 ]]; do
		if [[ ${IP_Array[$count]} ]]; then
			echo -e "${IP_Array[$count]} \c" >> $Report_File
			if [[ ${Mac_Array[$count]} ]]; then
				echo -e "[${Mac_Array[$count]}]" >> $Report_File
			else
				echo "" >> $Report_File
			fi
			if [[ ${OS_Array[$count]} ]]; then
				if [[ ${Android[$count]} ]]; then
					echo "   OS: ${OS_Array[$count]} (${Android[$count]})" >> $Report_File
				else
					echo "   OS: ${OS_Array[$count]}" >> $Report_File
				fi
			fi
			if [[ ${Manuf_Array[$count]} ]]; then
				echo "   Manufacturer: ${Manuf_Array[$count]}" >> $Report_File
			fi
			if [[ ${Type_Array[$count]} ]]; then
				echo "   Host Type: ${Type_Array[$count]}" >> $Report_File
			fi
			if [[ ${Browser_Array[$count]} ]]; then
				echo "   Browser(s): ${Browser_Array[$count]}" >> $Report_File
			fi
			if [[ ${App_Array[$count]} ]]; then
				echo "   Apps(s): ${App_Array[$count]}" >> $Report_File
			fi
			if [[ ${Ports_Array[$count]} ]]; then
				echo "   Port(s): ${Ports_Array[$count]}" >> $Report_File
			fi
			if [[ ${Uptime_Array[$count]} ]]; then
				echo "   Uptime: ${Uptime_Array[$count]}" >> $Report_File
			fi
			echo -e "" >> $Report_File
		fi
		((count++))
	done
	echo -e "\nEnd of Report" >> $Report_File
}
fnSanityCheck
