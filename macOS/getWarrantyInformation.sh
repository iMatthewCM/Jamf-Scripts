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
#    getWarrantyInformation.sh - Gets the estimated Warranty Expiration for a Mac
#
# DESCRIPTION
#
#    This script utilizes getwarranty.py, sourced from https://github.com/pudquick/pyMacWarranty/blob/master/getwarranty.py
#
#    The script will get the serial number of the computer it's being run on, call the getwarranty.py script, and then
#    send the Warranty Expiration date to Jamf Pro using the API
#
# REQUIREMENTS
#
#	A comprehensive walkthrough for properly configuring this script is available:
#	https://github.com/iMatthewCM/Jamf-Scripts/blob/master/Workflows/Warranty%20Reporting.pdf
#
####################################################################################################
#
# HISTORY
#
#    Version: 2.0
#
#   Release Notes:
#   - Updated with credential encryption, better text parsing, and documentation parity
#
#   - Created by Matthew Mitchell on May 23, 2018
#   - Updated by Matthew Mitchell on August 26, 2019
#
####################################################################################################
#
# ENCRYPTED CREDENTIALS CONFIGURATION
#
####################################################################################################

#Follow the steps in the "Setting up Encrypted Credentials" section of the documentation to configure the following:

#Enter the SALT value:
SALT="enter value here"

#Enter the PASSPHRASE value:
PASSPHRASE="enter value here"

####################################################################################################
#
# DEFINE VARIABLES
#
####################################################################################################

#Follow the steps in the "Modifying Script Variables" section of the documentation to configure the following:

#Enter your Jamf Pro URL - include any necessary ports but do NOT include a trailing /
#On-Prem Example: https://myjss.com:8443"
#Jamf Cloud Example: https://myjss.jamfcloud.com"
JAMF_PRO_URL="https://myjss.jamfcloud.com"

#Username for the API call
#This user only needs permissions to UPDATE Computer and User objects, and should be entered here in clear text
API_USERNAME="warrantyAPIuser"

#The Jamf Pro Object ID of the EA we're going to update
#You can get this from clicking into the EA in the GUI and checking the URL
#There will be a section that says id=X - write in the value for X here:
WARRANTY_EA_ID=4

#This is the display name for the EA - write this exactly as it appears in Jamf Pro
#Capitalization matters, and make sure to keep the quotes around it as seen in the example
WARRANTY_EA_NAME="AppleCare Warranty Expiration Date"

####################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Get the Serial Number for the computer
serial=$(system_profiler SPHardwareDataType | grep Serial | awk '{print $NF}')

#Run the script
output=$(python /tmp/getwarranty.py)

#Cut to the part of the output that we need
output=$(echo $output | cut -d ':' -f5 | awk '{print $1}')

#Tack on a timestamp for 11:59pm to format the value as a date
output+=" 23:59:59"



#Make the API call
curl -H "Content-Type: text/xml" -d "<computer><extension_attributes><extension_attribute><id>$WARRANTY_EA_ID</id><name>$WARRANTY_EA_NAME</name><type>Date</type><value>$output</value></extension_attribute></extension_attributes></computer>" -ksu "$API_USERNAME":"$API_PASSWORD" "$JAMF_PRO_URL/JSSResource/computers/serialnumber/$serial/subset/extensionattributes" -X PUT

#Remove the script, we don't need it anymore
rm /tmp/getwarranty.py