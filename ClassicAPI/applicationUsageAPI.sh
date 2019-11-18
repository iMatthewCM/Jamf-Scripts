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
#	applicationUsageAPI.sh - Collects Application Usage data for all computers for a specific App
#
# DESCRIPTION
#
#	This script will query each managed computer in a Jamf Pro server and get the total usage
#	time, in minutes, for a specific application. A CSV will be written out to /tmp with the output
#
# REQUIREMENTS
#
#   - Edit lines 45, 48, and 53 to reflect login credentials and a Jamf Pro URL
#	- The account used to authenticate only needs READ privileges on Computer objects
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
#	- Created by Matthew Mitchell on June 5, 2018
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Username for Jamf Pro account
jssUser=username

#Password for Jamf Pro account
jssPass=password

#Jamf Pro URL
#On-Prem Example: https://myjss.com:8443
#Jamf Cloud Example: https://myjss.jamfcloud.com
jssURL=https://myjss.jamfcloud.com

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#####################################################
# Get user input for app name and date range
#####################################################

#Prompt for the app name
echo "What is the name of the application to collect Usage data for?"
echo "Make sure to include spaces and the extension, exactly as it would appear in Jamf Pro!"
echo "Example: Microsoft Outlook.app"
read appToCheck
echo ""

#Prompt for the starting date
echo "This script will collect Usage data for $appToCheck within a date range."
echo "What is the date to start the range?"
echo "Format: YYYY-MM-DD"
echo "Example: 2018-01-01"
read startingDate
echo ""

#Prompt for the ending date
echo "What is the date to end the range?"
read endingDate
echo ""

#Concatenate them together to make the date range for the API
dateRange=$startingDate"_"$endingDate

#####################################################
# Get the output file set up
#####################################################

#Rip off the .app from the app name
fileName=$(echo $appToCheck | cut -d '.' -f1 | sed s/' '/'_'/g)

#Get the epoch time this report was run
epoch=$(date +%s)

#Appened _Usage_Report.csv
fileName=$fileName"_Usage_Report_"$epoch".csv"

#Initialize the variable
outputFile=/tmp/$fileName

#Create the column headers
echo "Computer Name, Serial Number, macOS Version, Application Usage (Minutes)" >> $outputFile

#Inform the admin about the file name
echo "$fileName will be placed in /tmp when this script is finished"
echo "$epoch, reflected in the file name, is the epoch time that this report ran"
echo ""

#Begin
echo "Working..."
echo ""

#####################################################
# Get all Computers
#####################################################

#API call to get all Computer IDs
allComputerIDs=$(curl -H "Accept: application/xml" "$jssURL/JSSResource/computers" -ksu $jssUser:$jssPass | xpath //computers/computer/id 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g | sed 's/.$//')

#Read them into an array
IFS=',' read -r -a ids <<< "$allComputerIDs"

#Get the length
idlength=${#ids[@]}

#####################################################
# Gather the Usage logs for all Computers
#####################################################

#Loop through the array of computer IDs
for ((i=0; i<$idlength; i++));
do
	
	#####################################################
	# Get information on this particular computer
	#####################################################
	
	#Get the entire inventory record for this computer ID
	computerData=$(curl -H "Accept: application/xml" "$jssURL/JSSResource/computers/id/${ids[$i]}" -ksu $jssUser:$jssPass)
	
	#Get the Computer Name
	computerName=$(echo $computerData | xpath //computer/general/name 2> /dev/null | sed s/'<name>'//g | sed s/'<\/name>'//g)
	
	#Get the Serial Number
	serialNumber=$(echo $computerData | xpath //computer/general/serial_number 2> /dev/null | sed s/'<serial_number>'//g | sed s/'<\/serial_number>'//g)
	
	#Get the macOS version
	macOSVersion=$(echo $computerData | xpath //computer/hardware/os_version 2> /dev/null | sed s/'<os_version>'//g | sed s/'<\/os_version>'//g)
	
	#####################################################
	# Collect Usage data
	#####################################################
	
	#Get the entire application usage output for this computer ID for the date range previously specified
	usageData=$(curl -H "Accept: application/xml" "$jssURL/JSSResource/computerapplicationusage/id/${ids[$i]}/$dateRange" -ksu $jssUser:$jssPass)
	
	#Get all Application names that are present in this date range
	applicationNames=$(echo $usageData | xpath //computer_application_usage/usage/apps/app/name 2> /dev/null | sed s/'<name>'//g | sed s/'<\/name>'/','/g | sed 's/.$//')
	
	#Read them into an array
	IFS=',' read -r -a appNames <<< "$applicationNames"

	#Get the length
	#No need to get this for the next array since they'll be the same
	appNamesLength=${#appNames[@]}
	
	#Get all the Foreground time for each application present in this date range
	applicationForeground=$(echo $usageData | xpath //computer_application_usage/usage/apps/app/foreground 2> /dev/null | sed s/'<foreground>'//g | sed s/'<\/foreground>'/','/g | sed 's/.$//')
	
	#Read them into an array
	IFS=',' read -r -a appForegrounds <<< "$applicationForeground"
	
	#####################################################
	# Process Usage data for specific application
	#####################################################
	
	#Initalize the variable to 0 so we can add as we go
	openTime=0
	
	#Hooray for nested For loops!
	for ((j=0; j<$appNamesLength; j++));
	do
		#If the app at the current index is the app we're trying to collect data for
		if [ "${appNames[$j]}" == "$appToCheck" ]; then
			
			#Grab the time it has spent in the foreground and add it to the openTime variable
			openTime=$(($openTime + ${appForegrounds[$j]}))
			
		fi
	done
	
	#We've collected all of the Usage information for the application for this computer
	#Write it out to the file and move on to the next Computer ID
	echo "$computerName,$serialNumber,$macOSVersion,$openTime" >> $outputFile

done

#All done, inform the admin
echo "Done. Once again, $fileName has been placed in /tmp with the Usage data results."
