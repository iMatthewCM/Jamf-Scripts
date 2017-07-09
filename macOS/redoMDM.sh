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
#	redoMDM.sh - A potential fix for MDM Capable: No
#
# DESCRIPTION
#
#	This script will wipe out every single Configuration Profile stored on the machine, then re-enable
#	the machine for MDM, which pulls back any Configuration Profiles that are properly scoped to the machine.
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
#	- Created by Matthew Mitchell on February 13, 2017
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

sudo rm -rf /var/db/ConfigurationProfiles/

sudo jamf mdm