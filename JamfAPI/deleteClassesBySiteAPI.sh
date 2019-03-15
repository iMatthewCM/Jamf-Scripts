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
#	deleteClassesBySiteAPI.sh - Deletes all classes associated with a specified site
#
# DESCRIPTION
#
#	This script will delete all classes in the JSS associated with a specific site
#
# REQUIREMENTS
#
#   -Administrative credentials for the JSS
#	-The name of the Site that we will delete all classes from
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
#	- Created by Matthew Mitchell on August 9, 2017
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

echo "Deleting all classes..."
echo ""

#Location of the Classes API
resourceURL="/JSSResource/classes"

#Get a all of the IDs we need to delete
ids=$(curl -H "Content-Type: application/xml" -ksu "$jssUser":"$jssPass" "$jssURL$resourceURL" -X GET | xpath //classes/class/id  2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g)

#Make that into an array
IFS=', ' read -r -a allIDs <<< $ids

length=${#allIDs[@]}
#Loop through lines
for ((i=0; i<$length;i++));
do
	#Get the ID of the class we're looking at
	currentID=$(echo ${allIDs[$i]})

	#Delete the ID we are looking ats
	curl -ksu "$jssUser":"$jssPass" "$jssURL$resourceURL/id/$currentID" -X DELETE

done

echo ""
echo "Done"