#!/bin/sh
# -*- coding: utf-8 -*-
#
#  readysethack.py
#  
#  Copyright 2013 written by: TH3CR4CK3R        TOP-HAT-SEC.COM
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  

clear
echo ""
echo " **** ****  **  ***  *   * ***** ***** ***** *   *  **  **** *  *"
echo " *  * *    *  * *  *  * *  *     *       *   *   * *  * *    * * "
echo " **** ***  **** *  *   *   ***** ****    *   ***** **** *    **"
echo " * *  *    *  * *  *   *       * *       *   *   * *  * *    * *"
echo " *  * **** *  * * *    *   ***** *****   *   *   * *  * **** *  *"
echo ""
echo ""
echo ""
echo ""
sleep 2.5
echo " #################################################################"
echo " #################################################################"
echo " ##   THIS SCRIPT WILL PUT THE INTERFACE THAT YOU CHOOSE INTO   ##"
echo " ##  MONITOR MODE. IT WILL THEN FAKE THE MAC FOR BOTH MONITOR   ##"
echo " ##                  MODE AND MANAGED MODE                      ##"
echo " ##      00:11:22:33:44:55 IS THE DEFAULT MAC ADDRESS USED      ##"
echo " #################################################################"
echo " #################################################################"
echo ""
echo ""
echo ""
echo "     --------------------------------------------------------"
echo "     -----MAKE SURE THAT YOUR WIRELESS CARD IS CONNECTED-----"
echo "     --------------------------------------------------------"
echo ""
echo ""
echo ""
echo "          **********************************************"
echo "          ******PRESS ENTER WHEN READY TO CONTINUE******"
echo "          **********************************************"
echo
read ENTER
sleep 1
clear
echo
airmon-ng
echo
echo "  WHICH INTERFACE WOULD YOU LIKE TO USE? \c" 
read IFACE
sleep 1 
clear
echo ""
echo ""
echo " ###########################################################"
echo " ###########################################################"
echo " ##                                                       ##"
echo " ##       BOOSTING TXPOWER from 20 > 30 on $IFACE          ##"
echo " ##                                                       ##"
echo " ###########################################################"
echo " ###########################################################"
sleep 3
echo 
iw reg set BO
echo
iwconfig wlan0 txpower 30
echo
sleep 1
clear
echo ""
echo ""
echo ""
echo " ##########################################################"
echo " ################ PLEASE SELECT AN OPTION #################"
echo " ##########################################################"
echo " "
echo "  OPTION 1 - USE DEFAULT MAC ADDRESS"
echo ""
echo "  OPTION 2 - USE CUSTOM MAC ADDRESS"
echo "" 
echo "  ENTER YOUR CHOICE [1/2]: \c"
read option



if [ $option =  "2" ]; then

  echo
  echo ""
  echo "  WHAT MAC ADDRESS WOULD YOU LIKE TO USE: \c"
  read MMAC
  sleep 0.75
  clear
  echo ""
  echo ""
  echo ""
  echo " #############################################################"
  echo " #############################################################"
  echo " ##                                                         ##"
  echo " ##   BRINGING DOWN $IFACE TO CHANGE THE MAC ADDRESS         ##"
  echo " ##      ====SETTING TO: $MMAC                  ##"
  echo " #############################################################"
  echo " #############################################################"
  sleep 2
  echo 
  ifconfig $IFACE down
  sleep 0.25 
  macchanger -m $MMAC $IFACE
  sleep 0.25
  clear
  echo ""
  echo ""
  echo "" 
  echo " ##############################################################"
  echo " ##############################################################"
  echo " ##                                                          ##"
  echo " ##       BRINGING UP $IFACE..... THIS MAY TAKE A MOMENT      ##"
  echo " ##                                                          ##"
  echo " ##############################################################"
  echo " ##############################################################"
  sleep 2
  ifconfig $IFACE up
  sleep 1.5
  clear
  echo ""
  echo ""
  echo ""
  echo " ##############################################################"
  echo " ##############################################################"
  echo " ##                                                          ##"
  echo " ##             PUTTING $IFACE INTO MONITOR MODE              ##"
  echo " ##                                                          ##"
  echo " ##############################################################"
  echo " ##############################################################"
  sleep 1.5
  airmon-ng start $IFACE
  sleep 0.5
  clear
  echo ""
  echo ""
  echo ""
  echo " ##############################################################"
  echo " ##############################################################"
  echo " ##                                                          ##"
  echo " ##    NOW BRINGING DOWN Mon0 & AND CHANGING THE MAC ADDRESS ##"
  echo " ##    ----CHANGING TO: $MMAC                    ##"
  echo " ##############################################################"
  echo " ##############################################################"
  echo ""
  echo ""
  sleep 2
  ifconfig mon0 down
  sleep 0.5
  echo ""
  macchanger -m $MMAC mon0
  sleep 0.25
  echo ""
  ifconfig mon0 up
  sleep 0.5
  clear
  echo ""
  echo ""
  echo ""
  echo " ##############################################################"
  echo " ##############################################################"
  echo " ##  $IFACE HAS BEEN PUT INTO MONITOR MODE                    ##"
  echo " ##  THE TXPOWER HAS BEEN SET TO:30                          ##"
  echo " ##  THE MAC ADDRESS OF BOTH $IFACE AND MON0                  ##"
  echo " ##  HAVE BEEN SPOOFED TO: $MMAC                 ##"
  echo " ##############################################################"
  echo " ##############################################################"
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo " PRESS ENTER TO START HACKING: \c"
  read ENTER
  sleep 0.5
  exit
  
  
else
if [ $option = "1" ]; then

clear
  echo ""
  echo ""
  echo ""
  echo " #############################################################"
  echo " #############################################################"
  echo " ##                                                         ##"
  echo " ##   BRINGING DOWN $IFACE TO CHANGE THE MAC ADDRESS         ##"
  echo " ##      ====SETTING TO: 00:11:22:33:44:55                  ##"
  echo " #############################################################"
  echo " #############################################################"
  sleep 2
  echo 
  ifconfig $IFACE down
  sleep 0.25 
  echo
  macchanger -m 00:11:22:33:44:55 $IFACE
  sleep 0.25
  clear
  echo ""
  echo ""
  echo "" 
  echo " ##############################################################"
  echo " ##############################################################"
  echo " ##                                                          ##"
  echo " ##       BRINGING UP $IFACE..... THIS MAY TAKE A MOMENT      ##"
  echo " ##                                                          ##"
  echo " ##############################################################"
  echo " ##############################################################"
  sleep 2
  echo
  ifconfig $IFACE up
  sleep 1
  clear
  echo ""
  echo ""
  echo ""
  echo " ##############################################################"
  echo " ##############################################################"
  echo " ##                                                          ##"
  echo " ##            PUTTING $IFACE INTO MONITOR MODE               ##"
  echo " ##                                                          ##"
  echo " ##############################################################"
  echo " ##############################################################"
  sleep 1.5
  airmon-ng start $IFACE
  sleep 0.5
  clear
  echo ""
  echo ""
  echo ""
  echo " ##############################################################"
  echo " ##############################################################"
  echo " ##                                                          ##"
  echo " ##    NOW BRINGING DOWN Mon0 & AND CHANGING THE MAC ADDRESS ##"
  echo " ##    ----CHANGING TO: 00:11:22:33:44:55                    ##"
  echo " ##############################################################"
  echo " ##############################################################"
  sleep 2
  ifconfig mon0 down
  sleep 0.5
  echo
  macchanger -m 00:11:22:33:44:55 mon0
  echo
  sleep 0.25
  ifconfig mon0 up
  sleep 0.5
  echo 
  sleep 1
  clear
  echo ""
  echo ""
  echo ""
  echo " ##############################################################"
  echo " ##############################################################"
  echo " ##  $IFACE HAS BEEN PUT INTO MONITOR MODE                    ##"
  echo " ##  THE TXPOWER HAS BEEN SET TO:30                          ##"
  echo " ##  THE MAC ADDRESS OF BOTH $IFACE AND mon0                  ##"
  echo " ##  HAVE BEEN SPOOFED TO: 00:11:22:33:44:55                 ##"
  echo " ##############################################################"
  echo " ##############################################################"
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo " PRESS ENTER TO START HACKING: \c"
  read ENTER
  sleep 0.5
  exit



fi
fi
