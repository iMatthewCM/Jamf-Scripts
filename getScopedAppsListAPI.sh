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
#	getScopedAppsListAPI.sh - Makes a list containing all Mobile Device Apps that are currently scoped
#
# DESCRIPTION
#
#	This script looks through every single app in the JSS and checks if it has a scope. If it has a scope
#	the name of the app is added to a file called appsBeingScoped.txt and the file will be placed on the
#	script runner's desktop
#
# REQUIREMENTS
#
#   Administrative Credentials for the JSS
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
#	- Created by Matthew Mitchell on May 4, 2017
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

ids=$(curl -H "Content-Type: application/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/mobiledeviceapplications" -X GET | xpath //mobile_device_applications/mobile_device_application/id | sed s/'<id>'//g | sed s/'<\/id>'/', '/g)

IFS=', ' read -r -a array <<< "$ids"

length=${#array[@]}

emptyScopeResponse="<?xml version=\"1.0\" encoding=\"UTF-8\"?><mobile_device_application><scope><all_mobile_devices>false</all_mobile_devices><all_jss_users>false</all_jss_users><mobile_devices/><buildings/><departments/><mobile_device_groups/><jss_users/><limitations><users/><user_groups/><network_segments/></limitations><exclusions><mobile_devices/><buildings/><departments/><mobile_device_groups/><users/><user_groups/><network_segments/><jss_users/></exclusions></scope></mobile_device_application>"

for ((i=0; i<$length;i++));

do
		#Get the contents of the line, and cut it off when we get to a < 
		currentID=$(echo ${array[$i]})
		scopeResponse=$(curl -H "Content-Type: application/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/mobiledeviceapplications/id/$currentID/subset/Scope" -X GET)
		
		if [ "$scopeResponse" != "$emptyScopeResponse" ]; then
			#get the name of the app for currentID
			nameCurrentID=$(curl -H "Content-Type: application/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/mobiledeviceapplications/id/$currentID" -X GET | xpath //mobile_device_application/general/name | sed s/'<name>'//g | sed s/'<\/name>'//g)
			echo $nameCurrentID >> ~/Desktop/appsBeingScoped.txt
		fi
done
