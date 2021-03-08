#!/bin/bash

#############################################
#	 Created by iMatthewCM on 12/04/2019	#
#################################################################################################
# This script is not an official product of Jamf Software LLC. As such, it is provided without  #
# warranty or support. By using this script, you agree that Jamf Software LLC is under no 		#
# obligation to support, debug, or otherwise maintain this script. Licensed under MIT.			#
#																								#
# NAME: createBuildingsFromFile.sh																#
# DESCRIPTION: This script will read in the contents of a CSV file that contains information	#
# to create new buildings in Jamf Pro from. Do NOT include column headers in the CSV! The		#
# columns must be in the following order: Name, Street Address 1, Street Address 2, City,		#
# State, ZIP Code, Country																		#
#																								#
# Example CSV line:																				#
# 	New York,1 5th Avenue,#314,New York,NY,12345,US												#
#################################################################################################

##############################
# Configure these variables! #
##############################

#Path to a the file containing the buildinngs to add
#Use the full path - do not use ~ to substitute the home directory
inputFile="/path/to/input.csv"

#Jamf Pro URL
#Do NOT use a trailing / character!
#Include ports as necessary
jamfProURL="https://myjss.jamfcloud.com"

#Token to use for authentication
token=""

#################################
# DO NOT MODIFY BELOW THIS LINE #
#################################

#Change IFS to properly read in CSV
IFS=,

#Loop through input CSV 
while read name address1 address2 city state zip country
do
	#Create new building
	curl -ks -H "Authorization: Bearer $token" -H "content-type: application/json" "$jamfProURL"/uapi/v1/buildings -X POST -d "{\"name\": \"$name\",\"streetAddress1\": \"$address1\",\"streetAddress2\": \"$address2\",\"city\": \"$city\",\"stateProvince\": \"$state\",\"zipPostalCode\": \"$zip\",\"country\": \"$country\"}"
done < $inputFile
