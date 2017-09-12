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
#	diskReportingAPI.sh - Gets the Model and Capacity of all Disks in all Computers in the JSS
#
# DESCRIPTION
#
#	This script will get each computer's name and serial number, and then the model and capacity
#	of each disk reported in the JSS Inventory, and write all of this out to disks.csv on the Desktop
#
# REQUIREMENTS
#
#   Admin credentials for the JSS
#	This script must be run on a Mac, or modify the output file path to accommodate Linux
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
#	- Created by Matthew Mitchell on September 12, 2017
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

echo "Working...depending on how many computers are enrolled, this may take awhile"

#Output file to write to
outfile="$HOME/Desktop/disks.csv"

#Check if file exists. If it does, remove it, we'll remake a new one later
if [ -f "$outfile" ]; then
	rm $outfile
fi

#Initialize the column headers in the file
echo "Computer Name, Serial Number, Disk Model, Disk Capacity (MB)" >> $outfile

#API call to get all Computer IDs
allComputerIDs=$(curl -H "Accept: application/xml" "$jssURL/JSSResource/computers" -ksu $jssUser:$jssPass | xpath //computers/computer/id 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g | sed 's/.$//')
#Read them into an array
IFS=',' read -r -a ids <<< "$allComputerIDs"
#Get the length
idlength=${#ids[@]}

for ((i=0; i<$idlength; i++));
	do
		#Reset all the variables so we don't accidentally concatenate data
		name=""
		serial=""
		model=""
		capacity=""
		models=""
		capacities=""
		
		currentID=$(echo ${ids[$i]})
		
		#API Call to get the Device Name
		name=$(curl -H "Accept: application/xml" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/computers/id/$currentID" -X GET | xpath //computer/general/name 2> /dev/null | sed s/'<name>'//g | sed s/'<\/name>'//g)
		
		#API Call to get the Device Serial
		serial=$(curl -H "Accept: application/xml" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/computers/id/$currentID" -X GET | xpath //computer/general/serial_number 2> /dev/null | sed s/'<serial_number>'//g | sed s/'<\/serial_number>'//g)

		#API Call to get all Models of all Disks associated with the Device
		model=$(curl -H "Accept: application/xml" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/computers/id/$currentID" -X GET | xpath //computer/hardware/storage/device/model 2> /dev/null | sed s/'<model>'//g | sed s/'<\/model>'/','/g | sed s/'<model \/>'/'Not\ Found,'/g | sed 's/.$//')
		
		#Make an array out of them so we can iterate later
		IFS=',' read -r -a models <<< "$model"
		#The number of models and capacities will be the same, and is the number of disks in the computer
		numberOfDisks=${#models[@]}

		#API Call to get all Capacities of all Disks associated with the Device
		capacity=$(curl -H "Accept: application/xml" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/computers/id/$currentID" -X GET | xpath //computer/hardware/storage/device/drive_capacity_mb 2> /dev/null | sed s/'<drive_capacity_mb>'//g | sed s/'<\/drive_capacity_mb>'/','/g | sed 's/.$//')
		
		#Make an array out of them so we can iterate later
		IFS=',' read -r -a capacities <<< "$capacity"
		
		#Start writing this to the outfile
		echo "$name,$serial,${models[0]},${capacities[0]}" >> $outfile

		for ((j=1; j<$numberOfDisks; j++));
			do
				echo ",,${models[$j]},${capacities[$j]}" >> $outfile
			done

	done
	
echo "Done. An output file named disks.csv has been placed on your Desktop"