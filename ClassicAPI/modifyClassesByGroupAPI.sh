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
#	modifyClassesByGroupAPI.sh - Inserts or removes a single Mobile Device Group to any specified class
#
# DESCRIPTION
#
#	This script searches for all devices associated with a specified Group and gets all of the device's names, UDIDs, and WiFi Mac addresses, and inserts or removes the proper data to all classes
#
# REQUIREMENTS
#
#   This script needs at least one class that is already set up in the JSS, as well as an already-populated Smart
#	or Static Mobile Device Group.
#
####################################################################################################
#
# HISTORY
#
#	Version: 3.0
#
#   Release Notes:
#   - Fixed bad code from 2.0
#	- Added a mode to remove a group from all classes
#
#	- Created by Matthew Mitchell on April 28, 2017
#   - Updated by Matthew Mitchell on August 18, 2017 v2.0
#   - Updated by Matthew Mitchell on August 22, 2017 v3.0
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
read jssURL
echo ""

#Login Credentials
echo "Please enter an Adminstrator's username for the JSS:"
read jssUser
echo ""

echo "Please enter the password for $jssUser's account:"
read -s jssPass
echo ""

#Figure out which mode we're in
echo "Press 1 to ADD a group to ALL classes"
echo "               -or-"
echo "Press 2 to REMOVE a group from ALL classes"
read mode
echo ""

if [ "$mode" == "1" ]; then
	modeString="add to"
else
	modeString="remove from"
fi

echo "What is the exact name, including spaces and capitalization, of the group to $modeString ALL classes?"
read mobileGroup
echo ""

#Replace spaces as necessary
mobileGroupAdjusted=$(echo $mobileGroup | sed 's/ /%20/g')

echo "Working...this may take a few moments..."
echo ""

#####################################################
# CURL Commands to get data
#####################################################

#Get ID of mobileGroup
groupID=$(curl -H "Accept: application/xml" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/mobiledevicegroups/name/$mobileGroupAdjusted" -X GET | cut -d '<' -f4 | cut -d '>' -f2)

#Get IDs of all classes
classIDs=$(curl -H "Accept: application/xml" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/classes" -X GET | xpath //classes/class/id  2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g | sed 's/.$//')
IFS=',' read -r -a classes <<< "$classIDs"
classLength=${#classes[@]}


#####################################################
# Function to ADD the group to all classes
#####################################################

function addToScope () {
	
	for ((i=0; i<$classLength; i++));
	do
		currentClass=$(echo ${classes[$i]})
		
		#Need to get the current groups scoped to it
		scope=$(curl -H "Accept: application/xml" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/classes/id/$currentClass" -X GET | xpath //class/mobile_device_group_ids/id 2> /dev/null)
		#And then add the additional group to the scope
		scope+="<id>$groupID</id>"
		#Send it off
		curl -H "Content-Type: application/xml" -d "<class><mobile_device_group_ids>$scope</mobile_device_group_ids></class>" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/classes/id/$currentClass" -X PUT
	done
	
}

#####################################################
# Function to REMOVE the group from all classes
#####################################################

function removeFromScope () {
	
	#For each and every Class...
	for ((i=0; i<$classLength; i++));
	do
		#Get the current class ID
		currentClass=$(echo ${classes[$i]})
		#Get a list of all the Group IDs the class is currently scoped to
		scope=$(curl -H "Accept: application/xml" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/classes/id/$currentClass" -X GET | xpath //class/mobile_device_group_ids/id 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g | sed 's/.$//')
		#Make it into an array
		IFS=',' read -r -a currentClassScope <<< "$scope"
		#Get the length
		scopeLength=${#currentClassScope[@]}
		
		#Initialize variable
		xmlForPut=""
		#For each Group ID that we threw into the array...
		for ((j=0; j<$scopeLength; j++));
		do
			#If this Group ID is NOT the same as the Group ID we are removing
			if [ "${currentClassScope[$j]}" != "$groupID" ]; then
				#Add it to the string
				xmlForPut+="<id>${currentClassScope[$j]}</id>"
			fi
		done
		
		#Update the Class with the new scope. This will only include Group IDs that were not equal to the Group ID to remove
		curl -H "Content-Type: application/xml" -d "<class><mobile_device_group_ids>$xmlForPut</mobile_device_group_ids></class>" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/classes/id/$currentClass" -X PUT
		
	done
}

##################################################################
# Determine which mode we're in and call the appropriate function
##################################################################

if [ "$mode" == "1" ]; then
	addToScope
else
	removeFromScope
fi


echo ""
echo ""
echo "Done, check your JSS."

