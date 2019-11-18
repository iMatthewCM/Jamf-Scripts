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
#	iOSAppInstallMethodsAPI.sh - Reports all Install Methods for all iOS Apps in the JSS
#
# DESCRIPTION
#
#	This script returns the app name and the installation method for each iOS App in the JSS
#
# REQUIREMENTS
#
#   Administrative credentials to the JSS
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
#	- Created by Matthew Mitchell on November 6, 2017
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#####################################################
# Credentials
#####################################################

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

echo "Working...please wait..."
#####################################################
# Setting up the output file
#####################################################

#Output file to write to
outputFile="$HOME/Desktop/iOS_App_Report.csv"

#Check if file exists. If it does, remove it, we'll remake a new one later
if [ -f "$outputFile" ]; then
	rm $outputFile
fi

#Create the file
touch $outputFile

#Set up the first line of the file
echo "App Name,Installation Method" >> $outputFile

#####################################################
# Read in Application IDs
#####################################################

#GET
allAppIDs=$(curl "$jssURL/JSSResource/mobiledeviceapplications" -ksu $jssUser:$jssPass | xpath //mobile_device_applications/mobile_device_application/id 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g | sed 's/.$//')
#Make array
IFS=',' read -r -a appIDs <<< "$allAppIDs"
idLength=${#appIDs[@]}

#####################################################
# GET data and write CSV
#####################################################

for((i=0; i<$idLength; i++))
do
	#Get App Name by ID
	appName=$(curl "$jssURL/JSSResource/mobiledeviceapplications/id/${appIDs[$i]}" -ksu $jssUser:$jssPass | xpath //mobile_device_application/general/name 2> /dev/null | sed s/'<name>'//g | sed s/'<\/name>'/''/g | sed s/','/''/g)
	
	#Get Installation Method by ID
	installMethod=$(curl "$jssURL/JSSResource/mobiledeviceapplications/id/${appIDs[$i]}" -ksu $jssUser:$jssPass | xpath //mobile_device_application/general/deployment_type 2> /dev/null | sed s/'<deployment_type>'//g | sed s/'<\/deployment_type>'/''/g)
	
	#Write CSV
	echo "$appName,$installMethod" >> $outputFile
	
done

echo "Done"