#!/bin/sh
####################################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT 
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	setupCasperShareUsers.sh - Configures Accounts to use with a File Share Distribution Point
#
# DESCRIPTION
#
#	This script will configure the accounts (and appropriate settings) that are required for
#   setting up a File Share Distribution Point to use with the JSS.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.2
#
#   Release Notes:
#   - Fixed a bug where Full Names weren't getting written properly
#
#	Created by Matthew Mitchell on August 24, 2016
#   Updated by Matthew Mitchell on December 3, 2016 (Version 1.1)
#	Updated by Matthew Mitchell on February 7, 2017 (Version 1.2)
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Create Accounts as HIDDEN? (YES/NO)
#There usually isn't a reason to have these accounts un-hidden
hidden=YES

#Read/Write Account Username
rwuser=casperadmin

#Read/Write Account Password
rwpass=jamf1234

#Read/Write Account Full Name
#You must maintain the single quotes around this name
rwname='CasperAdmin'

#Read/Write Account Unique ID
#The Read Account Unique ID will be automatically set to 1 higher
#If you have never run this script before, leave this as 9509
rwid=9509


#Read Account Username
ruser=casperinstall

#Read Account Password
rpass=jamf1234

#Read Account Full Name
#You must maintain the single quotes around this name
rname='CasperInstall'

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY ANYTHING BELOW THIS LINE!!!!
# CREATING ACCOUNTS MUST BE DONE IN A PARTICULAR WAY, SO, REALLY, DON'T MODIFY ANYTHING!!!
#
####################################################################################################

#Read Account Unique ID
rid=$((rwid+1))

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
read -p "
This script will create the following $hstring accounts:

Read/Write Username..... $rwuser
Read/Write Password..... $rwpass
Read/Write Full Name.... $rwname
Read/Write Unique ID.... $rwid

Read Username........... $ruser
Read Password........... $rpass
Read Full Name.......... $rname
Read Unique ID.......... $rid

Please make a note of this information. 
You will need the Username and Password for both accounts 
to configure the File Share Distribution Point in the JSS.

When this script is finished, your computer will RESTART AUTOMATICALLY.

Press ENTER to Continue, or ^C to Quit
"

#R/W User Creation

sudo dscl . -create /Users/$rwuser

sudo dscl . -create /Users/$rwuser UserShell /bin/bash

sudo dscl . -create /Users/$rwuser RealName $rwname

sudo dscl . -create /Users/$rwuser UniqueID $rwid

sudo dscl . -create /Users/$rwuser PrimaryGroupID 1000

sudo dscl . -create /Users/$rwuser NFSHomeDirectory /var/$rwuser

sudo dscl . -passwd /Users/$rwuser $rwpass

sudo dscl . -append /Groups/admin GroupMembership $rwuser

sudo dscl . -create /Users/$rwuser IsHidden $hidden

#R User Creation

sudo dscl . -create /Users/$ruser

sudo dscl . -create /Users/$ruser UserShell /bin/bash

sudo dscl . -create /Users/$ruser RealName $rname

sudo dscl . -create /Users/$ruser UniqueID $rid

sudo dscl . -create /Users/$ruser PrimaryGroupID 1000

sudo dscl . -create /Users/$ruser NFSHomeDirectory /var/$ruser

sudo dscl . -passwd /Users/$ruser $rpass

sudo dscl . -append /Groups/admin GroupMembership $ruser

sudo dscl . -create /Users/$ruser IsHidden $hidden

echo "Done, rebooting..."

sleep 2

sudo shutdown -r now