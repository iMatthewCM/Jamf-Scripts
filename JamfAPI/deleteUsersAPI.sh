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
#	deleteUsersAPI.sh - Deletes Users from the JSS based on username
#
# DESCRIPTION
#
#	This script reads in a CSV file containing only usernames, then deletes each of those Users from the JSS. Yikes.
#
# REQUIREMENTS
#
#   A CSV file containing the usernames to delete. Each username should be on a new line.
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
#	- Created by Matthew Mitchell on March 7, 2018
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

echo "-------------------------"
echo "WARNING: This is a dangerous script to run, as it will try and delete whatever you pass it,"
echo "so make sure that your CSV does not contain any usernames you do not want to delete."
echo "Please make sure you have a MySQL database backup you're OK rolling back to if something goes wrong."
echo "-------------------------"
echo ""

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

#CSV file path for devices list - Serial Numbers only
echo "Please drag and drop csv into this window and hit enter"
read userList
echo ""

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Read CSV into array
IFS=$'\n' read -d '' -r -a users < $userList

length=${#users[@]}

#Do all the things
for ((i=0; i<$length;i++));

do
	username=$(echo ${users[i]} | sed 's/,//g' | tr -d '\r\n')
	curl -kvu "$jssUser":"$jssPass" "$jssURL/JSSResource/users/name/$username" -X DELETE
done