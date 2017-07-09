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
#	Version: 1.0
#
#   Release Notes:
#   - Initial release
#
#	- Created by Matthew Mitchell on March 10, 2017
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Get the Serial Number for the computer
serialOutput=$(system_profiler SPHardwareDataType | grep Serial)

#Make it pretty
serialNumber=$(echo $serialOutput | cut -d\  -f4)

#Set ComputerName to the pretty output
sudo scutil --set ComputerName $serialNumber

#Update Inventory to reflect 
sudo jamf recon