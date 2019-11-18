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
#	Version: 1.0
#
#   Release Notes:
#   - Initial release
#
#	- Created by Matthew Mitchell on September 13, 2018
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Enter in the URL of the JSS we are are pulling and pushing the data to. 
echo "Please enter your JSS URL"
echo "On-Prem Example: https://myjss.com:8443"
echo "Jamf Cloud Example: https://myjss.jamfcloud.com"
read jssURL
echo ""

#Trim the trailing slash off if necessary
if [ $(echo "${jssURL: -1}") == "/" ]; then
	jssURL=$(echo $jssURL | sed 's/.$//')
fi

#Login Credentials
echo "Please enter an Adminstrator's username for the JSS:"
read jssUser
echo ""

echo "Please enter the password for $jssUser's account:"
read -s jssPass
echo ""

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

resourceURL=/JSSResource/classes

echo "Working...please wait"
echo ""

#Get a all of the IDs we need to delete
ids=$(curl -H "Content-Type: application/xml" -ksu "$jssUser":"$jssPass" "$jssURL$resourceURL" -X GET | xpath //classes/class/id  2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g)

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
	sourceValue=$(curl -H "Content-Type: application/xml" -ksu "$jssUser":"$jssPass" "$jssURL$resourceURL/id/$currentID" -X GET | xpath //class/source 2> /dev/null | sed s/'<source>'//g | sed s/'<\/source>'/''/g)
	
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
curl -H "Accept: text/xml" -ksu $jssUser:$jssPass "$jssURL$resourceURL/id/$idsToDelete" -X DELETE > /dev/null

echo "Done"