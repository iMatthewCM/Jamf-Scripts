#!/bin/bash

current=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'` 

#1
echo "Removing Webroot SecureAnywhere.app"
rm -rf /Applications/Webroot\ SecureAnywhere.app

#2
echo "Removing Global Webroot Application Support"
rm -rf /Library/Application\ Support/Webroot

#3
echo "Removing Webroot Extensions"
rm -rf /Library/Extensions/SecureAnywhere.kext

#4
echo "Removing Webroot LaunchAgent"
rm /Library/LaunchAgents/com.webroot.WRMacApp.plist

#5
echo "Removing Webroot LaunchDaemon"
rm /Library/LaunchDaemons/com.webroot.security.mac.plist

#6
echo "Removing User .wsalock"
rm /Users/$current/.wsalock

#7
echo "Removing User Webroot Application Support"
rm -rf /Users/$current/Library/Application\ Support/Webroot

#8
echo "Removing User Webroot Preferences"
rm /Users/$current/Library/Preferences/com.webroot.Webroot-SecureAnywhere.plist
rm /Users/$current/Library/Preferences/com.webroot.WSA.plist

#9
echo "Removing Webroot Daemon"
rm /usr/local/bin/WSDaemon