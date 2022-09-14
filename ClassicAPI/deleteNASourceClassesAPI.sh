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
#	deleteNASourceClassesAPI.sh - Deletes all classes that have a Source of N/A
#
# DESCRIPTION
#
#	This script parses through every class in a Jamf Pro Server and deletes any classes it finds
#	with a Source of N/A
#
# REQUIREMENTS
#
#   This script needs a Jamf Pro account with, at minimum, DELETE privileges on Classes objects
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Update xpath expressions to run through xmllint
#
#	- Created by Matthew Mitchell on September 13, 2018
#	- Updated by Matthew Mitchell on September 14, 2022
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#It's OK to leave these variables empty! The script will prompt for any empty fields.

#Do NOT use a trailing / character!
#Include ports as necessary
jamfProURL="https://teamvorp.jamfcloud.com"

#Jamf Pro User Account Username
jamfProUSER="MMitchell"

#Jamf Pro User Account Password
jamfProPASS="Jerry Park59"

if [[ "$jamfProURL" == "" ]]; then
	echo "Please enter your Jamf Pro URL"
	echo "Do not include a trailing /"
	echo "Example: https://myjss.jamfcloud.com"
	read jamfProURL
	echo ""
fi

if [[ "$jamfProUSER" == "" ]]; then
	echo "Please enter your Jamf Pro username"
	read jamfProUSER
	echo ""
fi

if [[ "$jamfProPASS" == "" ]]; then
	echo "Please enter the password for $jamfProUSER's account"
	read -s jamfProPASS
	echo ""
fi


####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

resourceURL=/JSSResource/classes

echo "Working...please wait"
echo ""

#Get a all of the IDs we need to delete
ids=$(curl -H "accept: text/xml" -su "$jamfProUSER":"$jamfProPASS" "$jamfProURL$resourceURL" -X GET | xmllint --xpath //classes/class/id - 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g)

#Make that into an array
IFS=', ' read -r -a allIDs <<< $ids

#Get the length of the array
length=${#allIDs[@]}

#Initialize the string we'll use to mass-delete later
idsToDelete="{"

#Loop through the array
for ((i=0; i<$length;i++));
do
	#Get the ID of the class we're looking at
	currentID=$(echo ${allIDs[$i]})
	
	#Get the value of the Source of the class
	sourceValue=$(curl -H "accept: text/xml" -su "$jamfProUSER":"$jamfProPASS" "$jamfProURL$resourceURL/id/$currentID" -X GET | xmllint --xpath //class/source - 2> /dev/null | sed s/'<source>'//g | sed s/'<\/source>'/''/g)
	
	#If the Source is N/A...
	if [ "$sourceValue" == "N/A" ]; then
		#Add the ID to our string
		idsToDelete+="$currentID,"
		#Inform the user
		echo "ID $currentID will be deleted"
	fi
	
done

#Get rid of the last character (will always be a comma) of idsToDelete
idsToDelete=$(echo $idsToDelete | sed 's/.$//')

#Add the closing curly brace
idsToDelete+="}"

#Tell the user we're starting the deletion process
echo ""
echo "Deleting Source N/A classes..."
echo ""

#Delete all of the things
curl -su "$jamfProUSER":"$jamfProPASS" "$jamfProURL$resourceURL/id/$idsToDelete" -X DELETE

echo "Done"