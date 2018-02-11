#!/bin/bash

clear
echo
echo Find Hosts
echo
echo
echo By Lee Baird
echo March 23, 2007
echo "v 0.2"
echo
echo "This script will find all live hosts in a Class C range."
echo
echo Usage:  192.168.1
echo Enter the Class C range.
echo
read class
echo
echo "####################"
echo
for x in `seq 1 254`;do
ping -c 1 $class.$x | grep "bytes from" | cut -d " " -f4 | cut -d ":" -f1 &
done
echo
