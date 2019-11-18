#!/bin/sh

#############################################
#	 Created by iMatthewCM on 11/18/2019	#
#################################################################################################
# This script is not an official product of Jamf Software LLC. As such, it is provided without  #
# warranty or support. By using this script, you agree that Jamf Software LLC is under no 		#
# obligation to support, debug, or otherwise maintain this script. Licensed under MIT.			#
#																								#
# NAME: createDepartmentsFromFile.sh															#
# DESCRIPTION: This script will read in the contents of a plain text file and create each line 	#
# of the file as a new department in Jamf Pro. IMPORTANT: Include an empty new line at the		#
# bottom of the file, otherwise the final department will not be created!						#
#################################################################################################

##############################
# Configure these variables! #
##############################

#Path to a the file containing the department names to add
inputFile="/path/to/input.txt"

#Jamf Pro URL
#Do NOT use a trailing / character!
#Include ports as necessary
jamfProURL="https://myjss.jamfcloud.com"

#Token to use for authentication
token="eyJhbGciOiJIUzI1NiJ9.eyJhdXRoZW50aWNhdGVkLWFwcCI6IkdFTkVSSUMiLCJhdXRoZW50aWNhdGlvbi10eXBlIjoiSlNTIiwiZ3JvdXBzIjpbXSwic3ViamVjdC10eXBlIjoiSlNTX1VTRVJfSUQiLCJ0b2tlbi11dWlkIjoiM2Y0MjNlNjUtMDNiNS00MDA5LTk4N2EtNzljNjVhNWNkOGIxIiwibGRhcC1zZXJ2ZXItaWQiOi0xLCJzdWIiOiIxIiwiZXhwIjoxNTc0MTE0ODYyfQ.WpOcG_1F9IAnbLs5U6BN5ZDW1VUiqWns1Uux6AKpqHE"

#Loop through the file and create the departments
while read department
do
	curl -s -H "Authorization: Bearer $token" -H "Content-type: application/json" "$jamfProURL"/uapi/v1/departments -X POST -d "{\"name\": \"$department\"}"
done < /Users/Matthew/Desktop/in.txt
