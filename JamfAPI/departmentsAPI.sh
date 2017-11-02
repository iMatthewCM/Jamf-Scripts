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
#	departmentsAPI.sh - Adds Departments to JSS via REST API
#
# DESCRIPTION
#
#	This script reads in a .txt file with Departments, then creates a Curl command for each
#   in order to add it to the JSS. It will automatically use the next available ID.
#
# REQUIREMENTS
#
#   This script requires a .txt file with a list of Department names. Each name must be on a
#   new line. 
#
#	Example:
#
#	Department of Mysteries
#	Auror Headquarters
#	International Magical Trading Standards Body
#
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.4
#
#   Release Notes:
#   - Style Guide Compatibility
#
#	- Created by Matthew Mitchell on December 8, 2016
#	- Updated by Matthew Mitchell on March 13, 2017 v1.3
#   - Updated by Matthew Mitchell on July 10, 2017 v1.4
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
read jssUser

echo "Please enter the password for your Admin account:"
read -s jssPass

echo "Please drag the .txt file with your Departments to add into this window"
read filePath

#Location of the Department API - you can get this from https://YOUR_JSS_URL/api, clicking on a command, "Try it out," and reference "Request URL"
resourceURL="/JSSResource/departments/id/"

#Department name we want to appear in the JSS. This variable will continually be rewritten once we get to the FOR loop
deptName=""

#Using 0 will use the next available ID. This is useful for creating NEW things, since you don't have to worry about overwriting something else
deptID=0

#Read in the file
IFS=$'\n' read -d '' -r -a lines < $filePath


#Get how many times we're looping based on length of array
length=${#lines[@]}
#Loop through lines
for ((i=0; i<$length;i++));
	do
		#Get the contents of the line, and cut it off when we get to a < 
		deptName=`echo ${lines[$i]} | cut -d '<' -f1`
		#If the string isn't empty
		if [ -n "$deptName" ]; then
			#POST it
			#This is the bread and butter of the API - the curl command.
			#In this case you'll see some XML after the -d, which is the portion of XML that the JSS needs to insert the names properly.
			#You can see the XML structure by running a GET on whatever resource you're looking at
			#The -kvu is just good practice, might as well throw that on all of your statements
			#Then there's the user and password, then the full URL to the API resource, and then the POST command
    		curl -H "Content-Type: application/xml" -d "<department><name>$deptName</name></department>" -ksu "$jssUser":"$jssPass" "$jssURL$resourceURL$deptID" -X POST
		fi
done