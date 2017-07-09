#!/bin/sh 

WD="$4"
current=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'` 

#Download WSA mac client 
cd /Users/$current/Desktop; curl -O http://anywhere.webrootcloudav.com/zerol/wsamacsme.dmg 
wait 15 

#Mount the DMG file 
hdiutil attach /Users/$current/Desktop/wsamacsme.dmg 

#copy app from dmg to applications 
ditto /Volumes/Webroot\ SecureAnywhere /Applications/ 
wait 10 

#run silent install 
sudo "/Applications/Webroot SecureAnywhere.app/Contents/MacOS/Webroot SecureAnywhere" install -keycode=$WD -silent 

#Unmount the DMG 
wait 30
hdiutil detach /Users/$current/Desktop/wsamacsme.dmg
rm -rf /Users/$current/Desktop/wsamacsme.dmg