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
#	enableManagementAndLocalFV2.sh - Enables FV2 on a computer that is not already encrypted
#
# DESCRIPTION
#
#	This script will prompt for the current logged in user's password, and will then enable
#	that user and the management account for FileVault 2, and encrypt the drive.
#
# REQUIREMENTS
#
#   The mgmtUser and mgmtPass variables need to be configured as Parameters 4 and 5, respectively, in the JSS
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Added password authentication
#
#	- Created by Matthew Mitchell on March 24, 2017
#   - Updated by Matthew Mitchell on July 13, 2017 v1.1
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Management Account Username
mgmtUser="$4"

#Management Account Password
mgmtPass="$5"


####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

## Get the logged in user's name
userName=$(/usr/bin/stat -f%Su /dev/console)

for ((i=0; i<3;i++));

do 

userPass="$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter your login password so that your IT department can configure FileVault 2 encryption on this machine:" default answer "" with title "Login Password" with text buttons {"Ok"} default button 1 with hidden answer' -e 'text returned of result')"

authAttempt=$(dscl /Local/Default -authonly "$userName" "$userPass")

if [ "$authAttempt" == "" ]; then
	i=3

	plist="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
	<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyLIst-1.0.dtd\">
	<plist version=\"1.0\">
	<dict>
	<key>Username</key>
	<string>$mgmtUser</string>
	<key>Password</key>
	<string>$mgmtPass</string>
	<key>AdditionalUsers</key>
	<array>
		<dict>
			<key>Username</key>
			<string>$userName</string>
			<key>Password</key>
			<string>$userPass</string>
		</dict>
	</array>
	</dict>
	</plist>"

	echo $plist > /tmp/fv.plist

	sudo fdesetup enable -inputplist < /tmp/fv.plist

	sudo rm /tmp/fv.plist
	
elif [ $i != 2 ]; then
	/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Something went wrong, try entering your password again..." buttons {"Try Again"} default button 1'
else
	/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Too may failed attempts...exiting..." buttons {"OK"} default button 1'
fi

done