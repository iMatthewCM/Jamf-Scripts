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
#	CurrentlyLoggedInUser.sh - Gets the Full Name of the currently logged in user
#
# DESCRIPTION
#
#	Utilizes the dscl binary to read the RealName variable of the currently logged in user,
#	which is passed from a variable that contains the username
#
# REQUIREMENTS
#
#   None
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Added variable to change between standard formatting and last name, first name formatting
#
#	- Created by Matthew Mitchell on Jan 16, 2017
#	- Updated by Matthew Mitchell on Jan 16, 2017
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Set formatting
#YES will result in First Name Last Name (Does not contain a comma)
#NO will result in Last Name, First Name (Contains a comma)
standardnaming=NO

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

username="$(stat -f%Su /dev/console)"
firstname="$(dscl . -read /Users/$username RealName | cut -d: -f2 | sed -e 's/^[ \t]*//' | grep -v "^$" | cut -d\  -f1)"
lastname="$(dscl . -read /Users/$username RealName | cut -d: -f2 | sed -e 's/^[ \t]*//' | grep -v "^$" | cut -d\  -f2)"

if [ $standardnaming == "YES" ]; then
	realname="$(echo $firstname $lastname)"
else
	realname="$(echo $lastname, $firstname)"
fi

echo "$realname"
