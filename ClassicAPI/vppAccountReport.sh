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
#	vppAccountReport.sh - Reports on all VPP accounts in a Jamf Pro server
#
# DESCRIPTION
#
#	This script will report on all information from the "Details" tab of each VPP Token in a
#	single Jamf Pro server
#
# REQUIREMENTS
#
#   You will be prompted to enter a Jamf Pro username and password - this account must at least
#	have READ permissions on "VPP Admin Accounts" objects
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Now correctly accounts for an empty Apple ID
#
#	- Created by Matthew Mitchell on June 22, 2018
#   - Updated by Matthew Mitchell on June 25, 2018 (v1.1)
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Enter in the URL of the JSS we are are pulling and pushing the data to. 
echo "Please enter your JSS URL"
echo "On-Prem Example: https://myjss.com:8443"
echo "Jamf Cloud Example: https://myjss.jamfcloud.com"
read jssURL
echo ""

#Trim the trailing slash off if necessary
if [ $(echo "${jssURL: -1}") == "/" ]; then
	jssURL=$(echo $jssURL | sed 's/.$//')
fi

#Login Credentials
echo "Please enter an Adminstrator's username for the JSS:"
read jssUser
echo ""

echo "Please enter the password for $jssUser's account:"
read -s jssPass
echo ""

echo "Working..."
echo ""

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Declare API endpoint
resourceURL=/JSSResource/vppaccounts

#Initialize the variable
outputFile=/tmp/VPP_Account_Report.csv

#Remove the file if it already exists
rm $outputFile

echo "JSS ID,Display Name,Contact,Account Name,Expiration Date,Country,Apple ID,Site,Populate Purchased,Notify Users" >> $outputFile

#API call to get all VPP Token IDs
allTokenIDs=$(curl -H "Accept: application/xml" "$jssURL$resourceURL" -ksu $jssUser:$jssPass | xpath //vpp_accounts/vpp_account/id 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g | sed 's/.$//')

#Read them into an array
IFS=',' read -r -a ids <<< "$allTokenIDs"

#Get the length
idlength=${#ids[@]}

for ((i=0; i<$idlength; i++));
do

	#Get the JSS ID
	jssID=${ids[$i]}
	
	#API call to GET all of the information on the token, so we don't have to make multiple calls to get the specific pieces
	allTokenInfo=$(curl -H "Accept: application/xml" "$jssURL$resourceURL/id/$jssID" -ksu $jssUser:$jssPass)
	
	#Get Display Name from allTokenInfo
	displayName=$(echo $allTokenInfo | xpath //vpp_account/name 2> /dev/null | sed s/'<name>'//g | sed s/'<\/name>'/''/g)
	
	#Get Contact from allTokenInfo
	contact=$(echo $allTokenInfo | xpath //vpp_account/contact 2> /dev/null | sed s/'<contact>'//g | sed s/'<\/contact>'/''/g | sed s/'<contact\ \/>'/''/g)
	
	#Get Account Name from allTokenInfo
	accountName=$(echo $allTokenInfo | xpath //vpp_account/account_name 2> /dev/null | sed s/'<account_name>'//g | sed s/'<\/account_name>'/''/g)
	
	#Get Expiration Date from allTokenInfo
	expirationDate=$(echo $allTokenInfo | xpath //vpp_account/expiration_date 2> /dev/null | sed s/'<expiration_date>'//g | sed s/'<\/expiration_date>'/''/g)
	
	#Get Country from allTokenInfo
	country=$(echo $allTokenInfo | xpath //vpp_account/country 2> /dev/null | sed s/'<country>'//g | sed s/'<\/country>'/''/g)
	
	#Get Apple ID from allTokenInfo
	appleID=$(echo $allTokenInfo | xpath //vpp_account/apple_id 2> /dev/null | sed s/'<apple_id>'//g | sed s/'<\/apple_id>'/''/g | sed s/'<apple_id\ \/>'/''/g)
	
	#Get Site from allTokenInfo
	site=$(echo $allTokenInfo | xpath //vpp_account/site/name 2> /dev/null | sed s/'<name>'//g | sed s/'<\/name>'/''/g)
	
	#Get Populate Purchased Content from allTokenInfo
	populatePurchased=$(echo $allTokenInfo | xpath //vpp_account/populate_catalog_from_vpp_content 2> /dev/null | sed s/'<populate_catalog_from_vpp_content>'//g | sed s/'<\/populate_catalog_from_vpp_content>'/''/g | sed s/'true'/'True'/g | sed s/'false'/'False'/g)
	
	#Get Notify Users from allTokenInfo
	notifyUsers=$(echo $allTokenInfo | xpath //vpp_account/notify_disassociation 2> /dev/null | sed s/'<notify_disassociation>'//g | sed s/'<\/notify_disassociation>'/''/g | sed s/'true'/'True'/g | sed s/'false'/'False'/g)
	
	#Write it to the output file
	echo "$jssID,$displayName,$contact,$accountName,$expirationDate,$country,$appleID,$site,$populatePurchased,$notifyUsers" >> $outputFile

done

echo "Done. VPP_Account_Report.csv has been written to /tmp"