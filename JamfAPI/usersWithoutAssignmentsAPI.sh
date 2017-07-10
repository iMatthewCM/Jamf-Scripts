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
#	usersWithoutAssignmentsAPI.sh - Finds Users that have nothing assigned to them
#
# DESCRIPTION
#
#	This script will comb all Users in the JSS to find if there is anything assigned to that User,
#	such as a Computer, Mobile Device, Peripheral, or VPP Assignment. If there is nothing found,
#	the user can be flagged for deletion.
#
# REQUIREMENTS
#
#   This script requires a valid JSS User Account with full Administrator privileges
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
#	- Created by Matthew Mitchell on May 17, 2017
#   - Updated by Matthew Mitchell on July 10, 2017 v1.1
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

echo "-------------------------"
echo "NOTE: An output file name UsersToDelete.txt will be placed in your /tmp directory, and will open automatically after the script is done running."
echo "Please be patient as this script runs - it can take several minutes depending on how many Users you have."
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

echo "Working..."

#Get all User IDs
listIDs="$(curl $jssURL/JSSResource/users -ksu $jssUser:$jssPass | xpath //users/user/id 2> /dev/null | sed 's/<id>//g' | sed 's/<\/id>/,/g')"

#Create an Array based on listIDs
IFS=', ' read -r -a allIDs <<< "$listIDs"

uselessString="<links><computers /><peripherals /><mobile_devices /><vpp_assignments /><total_vpp_code_count>0</total_vpp_code_count></links>"

#Check if file exists. If it does, remove it, we'll remake a new one later
if [ -f "/tmp/UsersToDelete.txt" ]; then
	rm /tmp/UsersToDelete.txt
fi

#Output file to write to
outputFile="/tmp/UsersToDelete.txt"

echo "The following Users have nothing assigned to them and can be deleted" >> $outputFile
echo "--------------------------------------------------------------------" >> $outputFile

length=${#allIDs[@]}
#Loop through lines
for ((i=0; i<$length;i++));
do
	#Get the ID of the User we're currently looking at, and hack off the comma at the end if necessary
	userid=$(echo "${allIDs[$i]}" | sed 's/,//g')
	
	#Check the User ID to see if it has anything assigned to it
	response="$(curl $jssURL/JSSResource/users/id/$userid -ksu $jssUser:$jssPass | xpath //user/links 2> /dev/null)"
	
	if [ "$response" == "$uselessString" ]; then
		#If this is true, then we'll output the URL to the User in the file so it can be deleted
		echo "$jssURL/users.html?id=$userid&o=r" >> $outputFile
	fi
	
done

echo "Done!"

open /tmp/UsersToDelete.txt