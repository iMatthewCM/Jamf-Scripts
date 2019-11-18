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
#	usersWithComputers.sh - Provides a list of all Users with Computers assigned to them
#
# DESCRIPTION
#
#	This script gets all Users in Jamf Pro and then checks each to see if they have at least one
#	computer assigned to them. If so, the script writes it to the output file.
#
# REQUIREMENTS
#
#   This script requires credentials to Jamf Pro that have, at minimum, READ access on User objects
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
#	- Created by Matthew Mitchell on August 20, 2018
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
read jssURL
echo ""

#Trim the trailing slash off if necessary
if [ $(echo "${jssURL: -1}") == "/" ]; then
	jssURL=$(echo $jssURL | sed 's/.$//')
fi

#Login Credentials
echo "Please enter a username to authenticate with Jamf Pro:"
read jssUser
echo ""

echo "Please enter the password for $jssUser's account:"
read -s jssPass
echo ""

echo "Working..."
echo ""

#Set the output file
outputFile=$HOME/Desktop/usersWithComputers.csv

#Check if file exists. If it does, remove it, we'll remake a new one later
if [ -f "$HOME/Desktop/usersWithComputers.csv" ]; then
	rm $HOME/Desktop/usersWithComputers.csv
fi

#Initialize the headers in the output file
echo "User ID,Username,Full Name" >> $outputFile

#GET all User IDs to loop through
allUserIDs=$(curl -H "Accept: text/xml" -ksu $jssUser:$jssPass "$jssURL/JSSResource/users" | xpath //users/user/id 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g | sed 's/.$//')

#Read them into an array
IFS=',' read -r -a ids <<< "$allUserIDs"

#Get length of array
length=${#ids[@]}

#Loop through the array
for ((i=0; i<$length; i++));
do
	
	#Pull down the user data so we don't have to keep requesting it
	userData=$(curl -H "Accept: text/xml" -ksu $jssUser:$jssPass "$jssURL/JSSResource/users/id/${ids[$i]}")
	
	#Get a list of the computer IDs associated to the machine
	computersAssociated=$(echo "$userData" | xpath //user/links/computers/computer/id 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g | sed 's/.$//')
	
	#As long as that didn't wind up being blank...
	if [ "$computersAssociated" != "" ]; then
		
		#Get the associated username
		name=$(echo "$userData" | xpath //user/name 2> /dev/null | sed s/'<name>'//g | sed s/'<\/name>'/''/g)
		
		#Get the associated full name
		fullName=$(echo "$userData" | xpath //user/full_name 2> /dev/null | sed s/'<full_name>'//g | sed s/'<\/full_name>'/''/g)
		
		#Write it to the output file
		echo "${ids[$i]},$name,$fullName" >> $outputFile
	fi

done

echo "Done. Output file placed at $HOME/Desktop/usersWithComputers.csv"