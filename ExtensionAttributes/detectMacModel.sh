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
#	detectMacModel.sh - Better detection for Mac model identifiers
#
# DESCRIPTION
#
#	This script, when used in an Extension Attribute, will return the Mac Model information
#	in the following format: MacBook Pro (Retina, 13-inch, Early 2015)
#
#	Once this information is correctly populated in the JSS Inventory, you can make Smart Groups
#	and other scoping decisions based off of this.
#
# REQUIREMENTS
#
#   This script will need to be put into an Extension Attribute. An internet connection is required
#	as this script makes two calls to Apple's servers.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#   Release Notes:
#   - Formatted original script into an Extension Attribute script
#
#	- Original Creator mm2270: https://www.jamf.com/jamf-nation/feature-requests/2214/fix-inconsistent-naming-of-macs-in-the-inventory#responseChild6198
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

Last4Ser=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformSerialNumber/{print $4}' | tail -c 5)
Last3Ser=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformSerialNumber/{print $4}' | tail -c 4)

FullModelName=$(curl -s -o - "http://support-sp.apple.com/sp/product?cc=$Last4Ser&lang=en_US" | xpath //configCode[1] 2>&1 | awk -F'[>|<]' '{print $3}' | sed '/^$/d')

if [[ "$FullModelName" == "" ]]; then
    FullModelName=$(curl -s -o - "http://support-sp.apple.com/sp/product?cc=$Last3Ser&lang=en_US" | xpath //configCode[1] 2>&1 | awk -F'[>|<]' '{print $3}' | sed '/^$/d')
fi

echo "<result>$FullModelName</result>"