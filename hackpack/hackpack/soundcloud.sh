#!/bin/bash
#soundcloud music downloader by http://360percents.com
#development: https://github.com/lukapusic/soundcloud-dl/
#Author: Luka Pusic <luka@pusic.si>

echo "[i] soundcloud.com music downloader by http://360percents.com (cURL version)";

if [ -z "$1" ]; then
	echo "";echo "[i] Usage: `basename $0` http://soundcloud.com/link_with_tracks_on_page";echo "";exit
fi

command -v curl &>/dev/null || { echo "[!] Curl needs to be installed."; exit 1; }

echo "[i] Grabbing artists page"
page=$(curl -L -s --user-agent 'Mozilla/5.0' $1)
clientID="b45b1aa10f1ac2941910a7f0d10f8e28" #$(echo "$page" | grep "clientID" | tr "," "\n" | grep "clientID" | cut -d '"' -f 4)
#echo "Client id is: $clientID"
artistID=$(echo "$page" | tr "," "\n" | grep "trackOwnerId" | head -n 1 | cut -d ":" -f 2)
#echo "Artist id is: $artistID"
echo "[i] Grabbing all song info"
songs=$(curl -s -L --user-agent 'Mozilla/5.0' "https://api.sndcdn.com/e1/users/$artistID/sounds?limit=256&offset=0&linked_partitioning=1&client_id=$clientID" | tr -d "\n" | sed 's/stream\-item\>/\n/g' | grep "integer")
songcount=$(echo "$songs" | wc -l)
echo "[i] Found $songcount songs!"

if [ -z "$songs" ]; then
	echo "[!] No songs found at $1" && exit
fi

for (( i=1; i <= $songcount; i++ ))
do
	title=$(echo "$songs" | sed -n "$i"p | tr ">" "\n" | grep "</title" | cut -d "<" -f 1)
	echo "[-] Downloading $title..."
	filename=$(echo "$title".mp3 | tr '/' '\\')
	songID=$(echo "$songs" | sed -n "$i"p | tr " " "\n" | grep "</id>" | head -n 1 | cut -d ">" -f 2 | cut -d "<" -f 1)
	#echo "Song id is $songID"
	url=$(curl -s -L --user-agent 'Mozilla/5.0' "https://api.sndcdn.com/i1/tracks/$songID/streams?client_id=$clientID" | cut -d '"' -f 4 | sed 's/\\u0026/\&/g')
	curl -L --user-agent 'Mozilla/5.0' -o "$filename" "$url";
done

