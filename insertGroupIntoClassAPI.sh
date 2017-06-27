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
#	insertGroupIntoClassAPI.sh - Inserts a single Mobile Device Group into any specified class
#
# DESCRIPTION
#
#	This script searches for all devices associated with a specified Group and gets all of the device's names, UDIDs, and WiFi Mac addresses, and inserts the proper data into a specified class.
#
# REQUIREMENTS
#
#   This script needs a class that is already set up in the JSS, as well as an already-populated Smart
#	or Static Mobile Device Group.
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
#	- Created by Matthew Mitchell on April 28, 2017
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

echo "Please enter your JSS URL"
echo "On-Prem Example: https://myjss.com:8443"
echo "Jamf Cloud Example: https://myjss.jamfcloud.com"
echo "Do NOT use a trailing / !!"
read jssURL

echo "Please enter Admin credentials the JSS:"
read apiUser

echo "Please enter the password for your Admin account:"
read -s apiPass

echo "What is the exact name, including spaces and capitalization, of the group to add to a class?"
read mobileGroup

echo "What is the exact name, including spaces and capitalization, of the class to add $mobileGroup to?"
read classToModify

resourceURL="/JSSResource/classes/id/"

#Get ids from mobileGroup
ids=$(curl -H "Content-Type: application/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/mobiledevicegroups/name/$mobileGroup" -X GET | xpath //mobile_device_group/mobile_devices/mobile_device/id | sed s/'<id>'//g | sed s/'<\/id>'/','/g)

#Get ID of mobileGroup
groupID=$(curl -H "Content-Type: application/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/mobiledevicegroups/name/$mobileGroup" -X GET | cut -d '<' -f4 | cut -d '>' -f2)

classID=$(curl -H "Content-Type: application/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/classes/name/$classToModify" -X GET | cut -d '<' -f4 | cut -d '>' -f2)

echo "Group is $mobileGroup with ID of $groupID"
echo "Class is $classToModify with ID of $classID"

IFS=', ' read -r -a array <<< "$ids"

length=${#array[@]}

xmlForPut=""

#Loop through lines
for ((i=0; i<$length;i++));
	do
		name=$(curl -H "Content-Type: application/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/mobiledevices/id/${array[$i]}" -X GET | cut -d '<' -f7 | cut -d '>' -f2)
		udid=$(curl -H "Content-Type: application/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/mobiledevices/id/${array[$i]}" -X GET | cut -d '<' -f38 | cut -d '>' -f2)
		mac=$(curl -H "Content-Type: application/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/mobiledevices/id/${array[$i]}" -X GET | cut -d '<' -f47 | cut -d '>' -f2)
		#echo "ID is ${array[$i]}, Name is $name, UDID is $udid, and WiFiMac is $mac"
		xmlForPut+="<mobile_devices><mobile_device><name>$name</name><udid>$udid</udid><wifi_mac_address>$mac</wifi_mac_address></mobile_device></mobile_devices>"	
done

echo "<class><mobile_device_group><id>$groupID</id><name>$mobileGroup</name></mobile_device_group>$xmlForPut</class>"

curl -H "Content-Type: application/xml" -d "<class>$xmlForPut<mobile_device_group_ids><id>$groupID</id></mobile_device_group_ids></class>" -kvu "$apiUser":"$apiPass" "$jssURL$resourceURL$classID" -X PUT

