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
#	deleteComputersAPI.sh - Deletes Computers from the JSS based on ID
#
# DESCRIPTION
#
#	This script reads in a CSV file containing Computer IDs, then deletes each Computer ID from the JSS. Yikes.
#
# REQUIREMENTS
#
#   A CSV file containing the IDs to delete. Each ID should be on a new line.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Style Guide Compatibility
#
#	- Created by Matthew Mitchell on June 12, 2017
#   - Updated by Matthew Mitchell on July 10, 2017 v1.1
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

echo "-------------------------"
echo "WARNING: This is a dangerous script to run, as it will try and delete whatever you pass it."
echo "Please make sure you have a MySQL database backup you're OK rolling back to if something goes wrong."
echo "-------------------------"
echo ""

#Enter in the URL of the JSS we are are pulling and pushing the data to. 
echo "Please enter your JSS URL"
echo "On-Prem Example: https://myjss.com:8443"
echo "Jamf Cloud Example: https://myjss.jamfcloud.com"
echo "Do NOT use a trailing / !!"
read jssURL
echo ""

#Login Credentials
echo "Please enter an Adminstrator's username for the JSS:"
read jssUser
echo ""

echo "Please enter the password for your Admin account:"
read -s jssPass
echo ""

#CSV file path for devices list - JSS ID numbers only
echo "Please drag and drop csv into this window and hit enter"
read deviceList
echo ""

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Read CSV into array
IFS=$'\n' read -d '' -r -a deviceIDs < $deviceList

length=${#deviceIDs[@]}

#Do all the things
for ((i=0; i<$length;i++));

do
	id=$(echo ${deviceIDs[i]} | sed 's/,//g' | sed 's/ //g'| tr -d '\r\n')
	curl -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/computers/id/$id" -X DELETE
done