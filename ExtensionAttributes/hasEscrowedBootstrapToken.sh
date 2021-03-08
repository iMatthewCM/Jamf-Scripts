#!/bin/bash

#############################################
#	 Created by iMatthewCM on 03/08/2021	#
#################################################################################################
# This script is not an official product of Jamf Software LLC. As such, it is provided without  
# warranty or support. By using this script, you agree that Jamf Software LLC is under no 		
# obligation to support, debug, or otherwise maintain this script. Licensed under MIT.			
#																								
# NAME: hasEscrowedBootstrapToken.sh															
# DESCRIPTION: This script is to be used in an Extension Attribute in Jamf Pro. It will detect  
# if a Bootstrap token has been escrowed, which is required for (amongst other things) 			
# approving legacy kernel extensions on M1 Macs. 												
#																								
# POSSIBLE RETURN VALUES:																		
# Not Supported																					
# Yes																							
# No																							
#																								
# (Yes if a token is escrowed, No if it's not, Not Supported if the Mac isn't supervised		
#################################################################################################

#Get the status of the bootstrap token
output=$(profiles status -type bootstraptoken)

#If we got an error, the output is empty and that means the Mac isn't supervised
if [[ "$output" == "" ]]; then
	echo "<result>Not Supported</result>"
else
	
	#If we didn't get an error, then just grab the last part of the line containing "escrowed"
	output=$(echo "$output" | awk '/escrowed/ {print $NF}')

	#If escrowed is YES...
	if [[ "$output" = "YES" ]]; then
		echo "<result>Yes</result>"
	else
		echo "<result>No</result>"
	fi
fi

