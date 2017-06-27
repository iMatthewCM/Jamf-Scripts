#!/bin/sh
####################################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT
#
# BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE 
# IS UNDER NO OBLIGATION TO SUPPORT, DEBUG, OR OTHERWISE 
# MAINTAIN THIS SCRIPT 
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	disable_menubar_wifi.sh - Removes the WiFi Icon from the Menu Bar
#
# DESCRIPTION
#
#	This script moves the AirPort.menu file out of the directory macOS is expecting, then restarts
#	the Menu Bar. The system can no longer find the icon, and therefore can't display it.
#
# REQUIREMENTS
#
#   This script will only run on a computer running any release of macOS 10.9
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#   Release Notes:
#   - Initial release
#
#	- Created by Matthew Mitchell on March 3, 2017
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

macOSversion="$(sw_vers -productVersion)"

function removeIcon {
	sudo mkdir /System/Library/CoreServices/Menu\ Extras/hidden_items
	sudo mv /System/Library/CoreServices/Menu\ Extras/AirPort.menu /System/Library/CoreServices/Menu\ Extras/hidden_items
	sudo killall SystemUIServer
	exit
}

if [[ $macOSversion == *"10.9"* ]]; then
	removeIcon
else
	echo "$macOSversion not supported, exiting..."
	exit
fi
