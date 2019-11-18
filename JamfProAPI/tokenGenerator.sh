#!/bin/bash

#############################################
#	 Created by iMatthewCM on 11/18/2019	#
#################################################################################################
# This script is not an official product of Jamf Software LLC. As such, it is provided without  #
# warranty or support. By using this script, you agree that Jamf Software LLC is under no 		#
# obligation to support, debug, or otherwise maintain this script. Licensed under MIT.			#
#																								#
# NAME: tokenGenerator.sh																		#
# DESCRIPTION: Generates a token for use with the Jamf Pro API									#
#																								#
# NOTES: This script will run in either fill or prompt mode. To run in fill mode, add values to	#
# the jamfProURL, jamfProUSER, and jamfProPASS variables. To run in prompt mode, any variables	#
# left blank will prompt the user for values.													#
#################################################################################################

#It's OK to leave these variables empty! The script will prompt for any empty fields.

#Do NOT use a trailing / character!
#Include ports as necessary
jamfProURL=""

#Jamf Pro User Account Username
jamfProUSER=""

#Jamf Pro User Account Password
jamfProPASS=""

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

#Get the token
token=$(curl -ksu "$jamfProUSER":"$jamfProPASS" "$jamfProURL"/uapi/auth/tokens -X POST)

#Documenting this line because it's terrible
#Awking for the line in the response that contains the word "token", and grabbing the last column of that response with $NF
#Then passing the remainging output to cut, where it is cutting the string down so that it starts on the 2nd character (hence the 2)
#Then passing that output to rev, which flips the string backwards so that we can...
#Pass it back to cut, this time cutting it down so it starts on the 3rd character, hence the 3. But this is actually the end of the string, so we're cutting off the last 2 bits essentially
#Then passing it back to rev to put in the proper order
token=$(echo "$token" | awk '/token/{print $NF}' | cut -c 2- | rev | cut -c 3- | rev)

#Output
echo "Here's your Jamf Pro API token:"
echo "$token"
echo ""
echo "Tokens expire 30 minutes after they are created"