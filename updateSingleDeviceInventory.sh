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
#	updateSingleDeviceInventory.sh - Sends an Update Inventory command to a specified iOS device ID
#
# DESCRIPTION
#
#	This script will prompt you for a Mobile Device ID, which can be obtained by going to the Inventory
#	Record for the device in the JSS and looking at the URL for ?id=X, or in the Inventory report under
#	JSS Mobile Device ID. It will then send an Update Inventory command via the JSS REST API to the device.
#
# REQUIREMENTS
#
#   Configured Administrator credentials for the JSS
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Updated script to use prompts rather than hard-coded credentials
#
#	- Created by Matthew Mitchell on May 12, 2017
#	- Updated by Matthew Mitchell on June 26, 2017 (v1.1)
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

echo "Please enter the Mobile Device ID to send an Update Inventory command to:"
read id
echo ""

curl -H "Content-Type: application/xml" -ksu "$jssuser":"$jsspass" "$jssurl/JSSResource/mobiledevicecommands/command/UpdateInventory/id/$id" -X POST