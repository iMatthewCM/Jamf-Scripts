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
#	directoryReportingAPI.sh - Get a list of all local usernames and their associated home directory
#
# DESCRIPTION
#
#	This script will gather all Computer IDs, then query each ID via the REST API to obtain their
#	full inventory record from Jamf Pro. Serial Number, Computer Name, Local User Accounts, and Home
#	Directory paths will be extracted from that record and written to a CSV
#
# REQUIREMENTS
#
#   Minimum of READ credentials on Computer objects in Jamf Pro
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
#	- Created by Matthew Mitchell on March 12, 2018
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#####################################################
# Credentials
#####################################################

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

echo "Working..."
echo ""

#####################################################
# Initial data gathering
#####################################################

#API call to get all Computer IDs
allComputerIDs=$(curl -H "Accept: application/xml" "$jssURL/JSSResource/computers" -ksu $jssUser:$jssPass | xpath //computers/computer/id 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g | sed 's/.$//')

#Read them into an array
IFS=',' read -r -a ids <<< "$allComputerIDs"

#Get the length
idlength=${#ids[@]}

#####################################################
# Setting up the output file
#####################################################

#Check if file exists. If it does, remove it, we'll remake a new one later
if [ -f "$HOME/Desktop/directory_report.csv" ]; then
	rm $HOME/Desktop/directory_report.csv
fi

#Output file to write to
outputFile="$HOME/Desktop/directory_report.csv"

#Create the file
touch $HOME/Desktop/directory_report.csv

#Set up the first line of the file
echo "Serial Number, Computer Name, Local Username, Home Directory" >> $outputFile

#####################################################
# Get inventory information for each computer
#####################################################

#Loop through all computer IDs
for ((i=0; i<$idlength; i++));
do

	#Get the entire inventory record for the computer with current JSS ID
	computerData=$(curl -H "Accept: text/xml" -ksu $jssUser:$jssPass "$jssURL/JSSResource/computers/id/${ids[$i]}")
	
	#Get the Serial Number
	serialNumber=$(echo $computerData | xpath "//computer/general/serial_number" 2> /dev/null | sed s/'<serial_number>'//g | sed s/'<\/serial_number>'//g)
	
	#Get the Computer Name
	computerName=$(echo $computerData | xpath "//computer/general/name" 2> /dev/null | sed s/'<name>'//g | sed s/'<\/name>'//g)
	
	#Get the Local Account Username(s)
	#A comma will be put in between each username
	username=$(echo $computerData | xpath "//computer/groups_accounts/local_accounts/user/name" 2> /dev/null | sed s/'<name>'//g | sed s/'<\/name>'/','/g | sed 's/.$//')
	
	#Read the username variable into an array
	IFS=',' read -r -a usernames <<< "$username"
	
	#Get length of array
	#Should wind up being the same size as the homeDirectory array
	usernamesLength=${#usernames[@]}
	
	#Get the Local Account Home Directory
	#A comma will be put in between multiple directories
	homeDirectory=$(echo $computerData | xpath "//computer/groups_accounts/local_accounts/user/home" 2> /dev/null | sed s/'<home>'//g | sed s/'<\/home>'/','/g | sed 's/.$//')
	
	#Read the homeDirectory variable into an array
	IFS=',' read -r -a homes <<< "$homeDirectory"
	
	#Loop through the usernames array
	for ((j=0; j<$usernamesLength; j++));
	do
		#Write out the data for this username and home directory pair
		echo "$serialNumber,$computerName,${usernames[$j]},${homes[$j]}" >> $outputFile
	done
done

echo "Done. directory_report.csv has been placed on your Desktop."
echo "If a single computer shows up multiple times, then that computer has multiple Local Accounts being reported in Inventory."