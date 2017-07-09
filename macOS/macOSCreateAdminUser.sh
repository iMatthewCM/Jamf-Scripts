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
#	macOSCreateAdminUser.sh - Configures an Admin Account for a single macOS computer
#
# DESCRIPTION
#
#	This script will configure a local Administrator account for macOS devices
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Added a variable to set an alternative Home directory
#	- Fixed a bug where special characters in a password could cause script to fail
#
#	Created by Matthew Mitchell on February 7, 2017
#	Updated by Matthew Mitchell on February 8, 2017 (Version 1.1)
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Create Accounts as HIDDEN? (YES/NO)
#Changing this to YES will mean the account will never be available to click on via the Login screen
#You will need to manually type in the username and password
hidden=NO

#Account Username
macOSuser=jamfadmin

#Account Password
#You must maintain the single quotes around this password
macOSpass='jamf1234'

#Account Full Name
#You must maintain the single quotes around this name
macOSfullname='Jamf Administrator'

#User Home Folder Location
#Do not use a trailing /
macOShome='/Users'

#Account Unique ID
#If you have never run this script before, leave this as 9509...it's very unlikely you've got
#a UID this high already.
macOSuid=9509

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY ANYTHING BELOW THIS LINE!!!!
# CREATING ACCOUNTS MUST BE DONE IN A PARTICULAR WAY, SO, REALLY, DON'T MODIFY ANYTHING!!!
#
####################################################################################################

#Hidden String
hstring=HIDDEN

#Hidden Account Variable Processing
if [ $hidden == "YES" ]; then
	hidden=1
else
	hidden=0
	hstring=UN-HIDDEN
fi

#Show information and continue
echo "
This script will create the following $hstring accounts:

Account Username......... $macOSuser
Account Password......... $macOSpass
Account Full Name........ $macOSfullname
Account Unique ID........ $macOSuid
Account Home Directory... $macOShome/$macOSuser

Please make a note of this information. 
You will need the Username and Password for both accounts 
to configure the File Share Distribution Point in the JSS.

When this script is finished, your computer will RESTART AUTOMATICALLY.
"

#Admin User Creation

sudo dscl . -create /Users/$macOSuser

sudo dscl . -create /Users/$macOSuser UserShell /bin/bash

sudo dscl . -create /Users/$macOSuser RealName "$macOSfullname"

sudo dscl . -create /Users/$macOSuser UniqueID $macOSuid

sudo dscl . -create /Users/$macOSuser PrimaryGroupID 1000

sudo dscl . -create /Users/$macOSuser NFSHomeDirectory $macOShome/$macOSuser

sudo dscl . -passwd /Users/$macOSuser $macOSpass

sudo dscl . -append /Groups/admin GroupMembership $macOSuser

sudo dscl . -create /Users/$macOSuser IsHidden $hidden

echo "Done, rebooting..."

sleep 2

sudo shutdown -r now