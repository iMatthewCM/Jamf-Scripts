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
#	secureTokenUsers.sh - Lists ALL Users on a Mac and their SecureToken status
#
# DESCRIPTION
#
#	This script uses the dscl binary to list out all Users on a Mac, and then the sysadminctl
#	binary to check the SecureToken status for each user
#
# REQUIREMENTS
#
#   Run this script locally on a machine
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
#	- Created by Matthew Mitchell on June 7, 2018
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Get the list of users and write it out to /tmp
#Couldn't get the array to read properly without writing it out
echo $(dscl . list /Users) > /tmp/users.txt

#Read CSV into array
IFS=$' ' read -d '' -r -a usernames < /tmp/users.txt

#Delete the file, we don't need it anymore
rm /tmp/users.txt

#Get the length of the array
length=${#usernames[@]}

#For each entry in the array
for ((i=0; i<$length; i++));
do
	#Check the SecureToken status
	sysadminctl -secureTokenStatus ${usernames[$i]}
done
