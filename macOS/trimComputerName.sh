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
#	trimComputerName.sh - Removes the "'s MacBook" from the end of device names
#
# DESCRIPTION
#
#	This script will trim off the trailing characters of a computer name if it detects "s MacBook" in the name
#
# REQUIREMENTS
#
#   This script should be deployed in a Policy from the JSS
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Added support for all Mac models
#
#	- Created by Matthew Mitchell on July 26, 2017
#   - Updated by Matthew Mitchell on July 27, 2017 v1.1
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#This is the function that does the renaming.
#It'll do Computer, Host, and Localhost Name, then submit a Recon
function renameComputer () {
	
	/usr/sbin/scutil --set ComputerName ${1}
	/usr/sbin/scutil --set HostName ${1}
	/usr/sbin/scutil --set LocalHostName ${1}
	
	echo "Set name to" ${1}

	jamf recon
}

#Get the name of the computer
currentName=$(networksetup -getcomputername)

#Get the last seven characters, needed to detect if it's just a MacBook
lastSeven=$(echo "${currentName: -7}")

#Is it a MacBook Pro?
if [[ $currentName == *"s MacBook Pro"* ]]; then

	newName=${currentName::${#currentName}-14}

	renameComputer $newName
	
#Is it a MacBook Air?
elif [[ $currentName == *"s MacBook Air"* ]]; then
	
	newName=${currentName::${#currentName}-14}

	renameComputer $newName
	
#Is it an iMac?
elif [[ $currentName == *"s iMac"* ]]; then
	
	newName=${currentName::${#currentName}-7}

	renameComputer $newName

#Is it a Mac Mini?
elif [[ $currentName == *"s Mac Mini"* ]]; then
	
	newName=${currentName::${#currentName}-11}

	renameComputer $newName
	
#Is it a MacBook?
elif [[ $lastSeven == "MacBook" ]]; then
	
	newName=${currentName::${#currentName}-10}

	renameComputer $newName

#The name didn't contain any product names, so don't mess with it	
else
	
	echo "No need to change the name"
	
fi