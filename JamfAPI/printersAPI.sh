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
#	printersAPI.sh - Creates printers in Jamf Pro based on a CSV
#
# DESCRIPTION
#
#	This script parses a CSV and creates a printer in Jamf Pro based on the contents
#
# REQUIREMENTS
#
#   Administrative credentials to Jamf Pro
#
#	A CSV with the following headers:
#	Name, Category, URI, CUPS Name, Location, Model, Info, Notes, Make Default, OS Requirements
#
#	Only Name, URI, and CUPS Name are required. All other fields are optional
#
#	This script only supports a single OS Requirement at this time. 
#	(Example, 10.13.x is fine, but 10.12.x, 10.13.x is not)
#
#	Categories must already exist in Jamf Pro prior to the script running
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
#	- Created by Matthew Mitchell on December 8, 2017
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

#Get Path to Printer CSV
echo "Please drag the CSV containing the Printers to add into this window and press Enter:"
read csvFile
echo ""

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#API resource we're using
resourceURL="/JSSResource/printers/id/0"

#####################################################
# Set up logging
#####################################################

#Log file for this script to write to
logFile="$HOME/Desktop/JamfPrinterLog.txt"

#Write a new run into the log file to preserve existing contents
echo "-------------New Script Run-------------" >> $logFile
echo "" >> $logFile

#Write to the log. Takes in $appID and a status message
logging () {
	echo "Printer Name: $1 | Status: $2" >> $logFile
	echo "" >> $logFile
}

#####################################################
# Set up script to run
#####################################################

#Read CSV into array
IFS=$'\n' read -d '' -r -a printers < $csvFile

#Length of the array we just made
length=${#printers[@]}

#####################################################
# API Request
#####################################################

#Go through each line, each line is a printer
#Start at i=1 since the first line is just headers
for ((i=1; i<$length; i++));
do
	
	#Get all the data for this printer
	name=$(echo ${printers[$i]} | cut -d ',' -f1)
	category=$(echo ${printers[$i]} | cut -d ',' -f2)
	uri=$(echo ${printers[$i]} | cut -d ',' -f3)
	cups=$(echo ${printers[$i]} | cut -d ',' -f4)
	location=$(echo ${printers[$i]} | cut -d ',' -f5)
	model=$(echo ${printers[$i]} | cut -d ',' -f6)
	info=$(echo ${printers[$i]} | cut -d ',' -f7)
	notes=$(echo ${printers[$i]} | cut -d ',' -f8)
	default=$(echo ${printers[$i]} | cut -d ',' -f9 | sed s/' '/''/g | tr '[:upper:]' '[:lower:]')
	osreqs=$(echo ${printers[$i]} | cut -d ',' -f10)
	
	#POST the printer data
	output=$(curl -H "Content-Type: application/xml" -d "<printer><name>$name</name><category>$category</category><uri>$uri</uri><CUPS_name>$cups</CUPS_name><location>$location</location><model>$model</model><info>$info</info><notes>$notes</notes><make_default>$default</make_default><use_generic>true</use_generic><ppd_path>/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Resources/Generic.ppd</ppd_path><os_requirements>$osreqs</os_requirements></printer>" -ksu "$jssUser":"$jssPass" "$jssURL$resourceURL" -X POST)
	
	#See what we got back from the API command
	successMessage=$(echo $output | cut -d '?' -f2)
	
	#If the output of the curl command is equal to this string
	if [ "$successMessage" == "xml version=\"1.0\" encoding=\"UTF-8\"" ]; then
		#API call was successful, log it
		logging "$name" "Success"
	else
		#Something went wrong, log it
		logging "$name" "Failed"
	fi

done

echo "Done. JamfPrinterLog.txt was placed on your Desktop containing script results."