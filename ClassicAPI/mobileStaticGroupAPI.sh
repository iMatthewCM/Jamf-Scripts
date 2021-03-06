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
#	mobileStaticGroupAPI.sh - Blurb About Script
#
# DESCRIPTION
#
#	This script will create a Static Mobile Device Group based on a CSV of JSS Mobile Device IDs
#
# REQUIREMENTS
#
#   A CSV containing all of the JSS Mobile Device IDs to insert into a Static Group
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
#	- Created by Matthew Mitchell on June 26, 2017
#   - Updated by Matthew Mitchell on July 10, 2017 v1.1
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

echo "-------------------------"
echo "NOTE: A file named mobileStaticgroupAPI.txt will be placed in your /tmp directory containing"
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
read Name 

#Read CSV into array
IFS=$'\n' read -d '' -r -a deviceIDs < $deviceList

length=${#deviceIDs[@]}

#Check if file exists. If it does, remove it, we'll remake a new one later
if [ -f "/tmp/mobileStaticgroupAPI.txt" ]; then
	rm /tmp/mobileStaticgroupAPI.txt
fi

outfile="/tmp/mobileStaticgroupAPI.txt"

#build the xml from the array
echo >> $outfile "<?xml version=\"1.0\" encoding=\"utf-8\"?><mobile_device_group><name>$Name</name><is_smart>false</is_smart><mobile_devices>"

for ((i=0; i<$length;i++));
do
	deviceID=$(echo "${deviceIDs[$i]}" | sed 's/,//g' | tr -d '\r\n')
	echo >> $outfile "<mobile_device><id>$deviceID</id></mobile_device>"
	
done

echo >> $outfile "</mobile_devices></mobile_device_group>"

#post the XML file to the JSS
curl -ksu $jssUser:$jssPass -H "Content-type: text/xml" $jssURL/JSSResource/mobiledevicegroups/id/0 -X POST -T $outfile > /dev/null