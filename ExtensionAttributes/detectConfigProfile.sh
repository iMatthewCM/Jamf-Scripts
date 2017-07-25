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
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Variable Configuration
#
#	- Created by Matthew Mitchell on March 3, 2017
#   - Updated by Matthew Mitchell on July 10, 2017 v1.1
#
####################################################################################################
# 
# DEFINE VARIABLES AND READ-IN PARAMETERS
#
####################################################################################################

#Config Profile ID
#Get this from About This Mac > System Profiler > Profiles > Name of Profile > Identifier
profileID=E039C901-46C9-4A68-9E6A-29A24937D156

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if sudo profiles -P | egrep -q ': '$profileID ; then
	 echo "<result>Yes</result>"
else
	 echo "<result>No</result>"
fi