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
#	macStaticGroupAPI.sh - Creates a Static Computer Group
#
# DESCRIPTION
#
#	This script will create a Static Computer Group based on a CSV of JSS Computer IDs
#
# REQUIREMENTS
#
#   A CSV containing all of the JSS Computer IDs to insert into a Static Group
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.2
#
#   Release Notes:
#   - Fixed a bug with how XML was being written that wasn't compatible with the Jamf API
#
#	- Created by Matthew Mitchell on June 26, 2017
#   - Updated by Matthew Mitchell on July 10, 2017 v1.1
#   - Updated by Matthew Mitchell on June 7, 2018 v1.2
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

echo "-------------------------"
echo "NOTE: A file named macStaticgroupAPI.txt will be placed in your /tmp directory containing"
echo "the XML that is sent to your JSS server."
echo "Please be patient as this script runs - it can take a bit depending on how big the CSV is"
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
echo "Please drag and drop CSV into this window and hit enter"
read deviceList
echo ""

#Name our static Device group
echo "What should the group name be? DO NOT USE SPACES!" 
read name 

#Read CSV into array
IFS=$'\n' read -d '' -r -a deviceIDs < $deviceList

length=${#deviceIDs[@]}

#Check if file exists. If it does, remove it, we'll remake a new one later
if [ -f "/tmp/macStaticgroupAPI.txt" ]; then
	rm /tmp/macStaticgroupAPI.txt
fi

outfile="/tmp/macStaticgroupAPI.txt"

#build the xml from the array
echo >> $outfile "<?xml version=\"1.0\" encoding=\"utf-8\"?><computer_group><name>$name</name><is_smart>false</is_smart><computers>"

for ((i=0; i<$length;i++));
do
	deviceid=$(echo "${deviceIDs[$i]}" | sed 's/,//g' | tr -d '\r\n')
	echo >> $outfile "<computer><id>$deviceid</id></computer>"
	
done

echo >> $outfile "</computers></computer_group>"

#post the XML file to the JSS
curl -ksu $jssUser:$jssPass -H "Content-type: text/xml" $jssURL/JSSResource/computergroups/id/0 -X POST -T $outfile > /dev/null