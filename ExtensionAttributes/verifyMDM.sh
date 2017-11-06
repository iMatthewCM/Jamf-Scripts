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
#	verifyMDM.sh - An Extension Attribute to report if a computer has a valid MDM profile
#
# DESCRIPTION
#
#	This script reads data on all Configuration Profiles stored on a Mac, finds the MDM Profile,
#	and returns the verification status of the MDM Profile as an EA to the JSS
#
# REQUIREMENTS
#
#   This script needs to be used in an Extension Attribute in the JSS
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
#	- Created by Matthew Mitchell on November 6, 2017
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

tmpFile=/tmp/MDMProfileInfo.txt

#Check if file exists. If it does, remove it, we'll remake a new one later
if [ -f "$tmpFile" ]; then
	rm $tmpFile
fi

#Write the output of the command into the tmpFile
echo "$(system_profiler SPConfigurationProfileDataType)" >> $tmpFile

#Find the line number that has the MDM Profile on
lineNum=`cat $tmpFile | grep -n "Description: MDM Profile" | awk -F : '{print $1}'`

#Store 10 lines after that so we can collect the verification status
profileInfo=`head -n $(( $lineNum + 10 )) $tmpFile | tail -n 11`

#Remove the file to clean up after ourselves
rm $tmpFile

#Get the verification status of the MDM Profile
verificationStatus=$(echo "$profileInfo" | grep "Verification State:" | cut -d ':' -f2 | awk '{print $1}')

#Echo it out to an EA
echo "<result>$verificationStatus</result>"