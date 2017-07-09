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
#	GetiPadBySerialAPI.sh - Uses the REST API to look up any enrolled iPad by Serial Number
#
# DESCRIPTION
#
#	This script looks up any given serial number for a device, and if enrolled in the JSS, will
#	return the XML output containing the inventory record information. A .txt file will be created
#	on the Desktop named SERIAL_NUMBER Output.txt, where SERIAL_NUMBER is replaced for the device's
#	actual serial number.
#
# REQUIREMENTS
#
#   This script requires valid login credentials for a JSS Administrator, a valid iOS Serial Number,
#	and must be run as root (sudo) so that a file can be placed on the Desktop.
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
#	- Created by Matthew Mitchell on March 13, 2017
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Enter in the URL of the JSS we are are pulling and pushing the data to. 
echo "Please enter your JSS URL"
echo "On-Prem Example: https://myjss.com:8443"
echo "Jamf Cloud Example: https://myjss.jamfcloud.com"
echo "Do NOT use a trailing / !!"
read jssurl
echo ""

#Login Credentials
echo "Please enter an Adminstrator's username for the JSS:"
read jssuser
echo ""

echo "Please enter the password for your Admin account:"
read -s jsspass
echo ""

#Login Credentials
echo "Please enter the Serial Number of the Mobile Device to get:"
read serialNumber
echo ""

resourceURL="/JSSResource/mobiledevices/serialnumber/"

output="$(curl "$jssurl$resourceURL$serialNumber" -kvu $jssuser:$jsspass)" 

echo > ~/Desktop/$serialNumber\ Output.txt "$output"



