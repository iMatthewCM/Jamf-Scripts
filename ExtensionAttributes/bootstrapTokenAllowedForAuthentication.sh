#!/bin/bash

#############################################
#	 Created by iMatthewCM on 03/08/2021	#
#################################################################################################
# This script is not an official product of Jamf Software LLC. As such, it is provided without  #
# warranty or support. By using this script, you agree that Jamf Software LLC is under no 		#
# obligation to support, debug, or otherwise maintain this script. Licensed under MIT.			#
#																								#
# NAME: bootstrapTokenAllowedForAuthentication.sh												#
# DESCRIPTION: This script is to be used in an Extension Attribute in Jamf Pro. A use case for  #
# implementation is a kernel extension approval workflow, where this value would need to be     #
# "supported" for M1 Macs																		#
#																								#
# POSSIBLE RETURN VALUES:																		#
# not supported																					#
# allowed																						#
# disallowed																					#
#																								#
# ("not supported" for Intel Macs, "allowed" if we're good to go, "disallowed" if not			#
#################################################################################################

#Get the value for the BootstrapTokenAllowedForAuthentication key
output=$(/usr/libexec/mdmclient QuerySecurityInfo | awk -F '[=]' '/BootstrapTokenAllowedForAuthentication/ {print $NF}' | tr -d '";')

#Trim off the leading space
output=${output:1}

echo "<result>$output</result>"