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
#	updateMobilePurchasingAPI.sh - Updates a Mobile Device's Inventory Record with Purchasing Info
#
# DESCRIPTION
#
#	This script will add a Warranty Expiration, AppleCare ID, PO Number, and PO Date to a list of serial numbers
#
# REQUIREMENTS
#
#   This script requires a CSV file with three columns, in order:
#	Serial Number, Warranty Expiration, AppleCare ID, PO Number, PO Date
#	
#	The Serial Number must be an exact match for an enrolled Computer
#	The Warranty Expiration must be in the form of YYYY-MM-DD
#	The AppleCare ID can be pretty much anything without a comma in it
#	The PO Number can be pretty much anything without a comma in it
#	The PO Date must be in the form of YYYY-MM-DD
#
#	Do NOT put a header on your columns. Just make sure to put them in the exact order of:
#	Serial Number, Warranty Expiration, AppleCare ID, PO Number, PO Date
#
#	The purchasing information for each device will be applied to the Serial Number in the same row
#
#	Example:
#	XNIT2FJSOCP2,2017-06-19,apple1@me.com,COEHS-9283,2015-08-28
#	UQBPLARMKKPZ,2015-10-11,apple1@me.com,MUED-2498,2013-10-28
#	UQIWN4WJYWGR,2014-07-05,apple1@me.com,8357-9871,2014-11-19
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Added support for PO Number and PO Date
#
#	- Created by Matthew Mitchell on June 28, 2017
#	- Updated by Matthew Mitchell on July 5, 2017
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Enter in the URL of the JSS we are are pulling and pushing the data to. 
echo "Please enter your JSS URL"
echo "On-Prem Example: https://myjss.com:8443"
echo "Jamf Cloud Example: https://myjss.jamfcloud.com"
echo "Do NOT use a trailing / !!"
read jssurl
echo ""

#Login Credentials
echo "Please enter an Adminstrator's username for the JSS:"
read jssuser
echo ""

echo "Please enter the password for your Admin account:"
read -s jsspass
echo ""

#Path to CSV
echo "Please drag the CSV into this window and press Enter:"
read inputcsv
echo ""

echo "Working..."

resourceURL="/JSSResource/mobiledevices/serialnumber/"

#Change this to true for additional output if there are errors
debugging=false

#Read CSV into array
IFS=$'\n' read -d '' -r -a purchasingInfo < $inputcsv

length=${#purchasingInfo[@]}

#Loop through the purchasingInfo array
for ((i=0; i<$length;i++));
do
	#Grab Serial, Warranty, and AppleID
	serial=$(echo ${purchasingInfo[$i]} | cut -d ',' -f1 | tr -d '\r\n')
	warranty=$(echo ${purchasingInfo[$i]} | cut -d ',' -f2 | tr -d '\r\n')
	appleid=$(echo ${purchasingInfo[$i]} | cut -d ',' -f3 | tr -d '\r\n')
	ponum=$(echo ${purchasingInfo[$i]} | cut -d ',' -f4 | tr -d '\r\n')
	podate=$(echo ${purchasingInfo[$i]} | cut -d ',' -f5 | tr -d '\r\n')
	
	if $debugging; then
	echo "PUT the following data:"
	echo "<mobile_device><purchasing><po_number>$ponum</po_number><applecare_id>$appleid</applecare_id><po_date>$podate</po_date><warranty_expires>$warranty</warranty_expires></purchasing></mobile_device>"
	echo "INTO: $jssurl$resourceURL$serial"
	echo "WITH: $jssuser:$jsspass"
	echo "-------------------------------------------------------------"
	fi
	
	#Make the API call
	curl -H "Content-Type: application/xml" -d "<mobile_device><purchasing><po_number>$ponum</po_number><applecare_id>$appleid</applecare_id><po_date>$podate</po_date><warranty_expires>$warranty</warranty_expires></purchasing></mobile_device>" "$jssurl$resourceURL$serial" -ksu $jssuser:$jsspass -X PUT > /dev/null
done

echo "Done."