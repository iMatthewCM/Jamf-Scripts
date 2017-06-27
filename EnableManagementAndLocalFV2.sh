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
#	EnableManagementAndLocalFV2.sh - Enables FV2 on a computer that is not already encrypted
#
# DESCRIPTION
#
#	This script will prompt for the current logged in user's password, and will then enable
#	that user and the management account for FileVault 2, and encrypt the drive.
#
# REQUIREMENTS
#
#   The mgmtUser and mgmtPass variables need to be configured in DEFINE VARIABLES & READ IN PARAMETERS
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
#	- Created by Matthew Mitchell on March 24, 2017
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Management Account Username
mgmtUser="admin"

#Management Account Password
mgmtPass="jamf1234"


####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

## Get the logged in user's name
userName=$(/usr/bin/stat -f%Su /dev/console)

userPass="$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter your login password:" default answer "" with title "Login Password" with text buttons {"Ok"} default button 1 with hidden answer' -e 'text returned of result')"

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