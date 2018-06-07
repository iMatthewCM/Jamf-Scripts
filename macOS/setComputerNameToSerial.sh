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
#	setComputerNameToSerial.sh - Sets a Mac's name to its Serial Number
#
# DESCRIPTION
#
#	This script grabs the Serial Number for the computer, parses the output, and assigns the Serial Number
#	as the new Computer Name. Then a jamf recon is run to reflect this change in the JSS immediately.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.2
#
#   Release Notes:
#   - New one-liner approach to collecting the serial number
#
#	- Created by Matthew Mitchell on March 10, 2017
#   - Updated by Matthew Mitchell on August 1, 2017 v1.1
#   - Updated by Matthew Mitchell on June 7, 2018 v1.2
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Leave this blank to just set the name to the serial number
#Do not include a hyphen at the end, one will be added automatically
prefix="WM"

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Get the Serial Number for the computer
serialNumber=$(system_profiler SPHardwareDataType | grep Serial | awk '{print $4}')

#Check and see if we're using a Prefix
if [[ "$prefix" != "" ]]; then
	newName="$prefix-$serialNumber"
else
	newName=$serialNumber
fi

#Set Computer name to the output
/usr/sbin/scutil --set ComputerName $newName
/usr/sbin/scutil --set HostName $newName
/usr/sbin/scutil --set LocalHostName $newName

#Update Inventory to reflect the new name
sudo jamf recon