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
#	deleteMobileConfigProfileID.sh - Deletes a specified Mobile Device Config Profile via the API
#
# DESCRIPTION
#
#	This script will delete (based on ID) a single Mobile Device Configuration Profile in the JSS
#
# REQUIREMENTS
#
#   This script will prompt for a JSS URL and Administrative credentials, as well as the ID to delete
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
#	- Created by Matthew Mitchell on May 12, 2017
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

#Config Profile ID
echo "What Config Profile ID are we deleting?"
read id
echo ""

curl -H "Content-Type: application/xml" -ksu "$jssuser":"$jsspass" "$jssurl/JSSResource/mobiledeviceconfigurationprofiles/id/$id" -X DELETE