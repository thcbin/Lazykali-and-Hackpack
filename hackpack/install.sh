#!/bin/bash
### Hackpack installer by reaperz73
cp *.png /usr/share/icons
cp *.menu /etc/xdg/menus/applications-merged
cp *.directory /usr/share/desktop-directories
cp -r hackpack /opt/
rm -rf /usr/share/applications/hackpack
mkdir /usr/share/applications/hackpack
cd launchers
cp *.desktop /usr/share/applications/hackpack
