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
#	create2801group.sh - Creates a Static Group based on a CSV
#
# DESCRIPTION
#
#	This script takes in a CSV (created with a MySQL command that can be obtained from Jamf) and
#	adds the Computer IDs contained in the CSV to a Static Group.
#
# REQUIREMENTS
#
#   A CSV with a list of IDs to insert into the Static Group
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.3
#
#   Release Notes:
#   - Added debugging messages to discover missing IDs or unmanaged machines
#	- Resolved an issue running API calls against Jamf Cloud environments
#
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
################################################################################

echo "-------------------------"
echo "NOTE: An output file named 2801output.txt will be placed in your /tmp directory"
echo "Please be patient as this script runs - it can take several minutes depending on how big the CSV is"
echo "-------------------------"
echo ""

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

#CSV file path for devices list - JSS ID numbers only
echo "Please drag and drop csv into this window and hit enter"
read devicelist
echo ""

#Name our static Device group
echo "What should the group name be? DO NOT USE SPACES!" 
read name 

#Create the Static Group and get the ID
newgroup=`curl -ksu "$jssuser":"$jsspass" -H "Content-type: text/xml" $jssurl/JSSResource/computergroups/id/0 -X POST -d "<?xml version=\"1.0\" encoding=\"utf-8\"?><computer_group><name>$name</name><is_smart>false</is_smart></computer_group>"`

newgroupid=`echo $newgroup | xpath //computer_group/id | sed 's/<id>//g' | sed 's/<\/id>//g'`

#Check if file exists. If it does, remove it, we'll remake a new one later
if [ -f "/tmp/2801output.txt" ]; then
	rm /tmp/2801output.txt
fi

#Output file to write to
outputFile="/tmp/2801output.txt"

echo "Created Static Group named $name with a group ID of $newgroupid" >> $outputFile

#Read CSV into array
IFS=$'\n' read -d '' -r -a deviceIDs < $devicelist

length=${#deviceIDs[@]}

#Assume fale until proven true
isHosted="false"

if [[ $jssurl == *"jamfcloud"* ]]; then
	isHosted="true"
	echo "Hosted Environmenet detected, will insert a Sleep statement before each PUT" >> $outputFile
fi

#Do all the things
for ((i=0; i<$length;i++));
do
	#Get current computerid and hack off the ugly bits
	computerid=$(echo "${deviceIDs[$i]}" | sed 's/,//g' | tr -d '\r\n')

	#Do an API query on the current ID
	validityQuery="$(curl -H "Content-Type: application/xml" -ksu "$jssuser":"$jsspass" "$jssurl/JSSResource/computers/id/$computerid")"

	if [[ "$validityQuery" =~ ^\<html\> ]]; then
		echo "Computer ID $computerid Status: INVALID - DID NOT EXIST" >> $outputFile
	else
		#Verify device is managed
		managedStatus=$(echo $validityQuery | xpath //computer/general/remote_management/managed | sed s/'<managed>'//g | sed s/'<\/managed>'//g)
		
		if [ "$managedStatus" == "true" ]; then
			#For whatever reason, this sleep seems to help Jamf Cloud process better.
			#If On-Prem, this will not trigger
			if [ "$isHosted" == "true" ]; then
				sleep 6
			fi
			
			#Device is managed, put into group
			sendQuery="$(curl -ksu "$jssuser":"$jsspass" -H "Content-type: text/xml" $jssurl/JSSResource/computergroups/id/$newgroupid -X PUT -d "<?xml version=\"1.0\" encoding=\"utf-8\"?><computer_group><computer_additions><computer><id>$computerid</id></computer></computer_additions></computer_group>")"
			
			#Check to see if we got a 404 response
			if [[ "$sendQuery" =~ ^\<html\> ]]; then
				#Try it one more time with a longer sleep
				sleep 10
				#Redo the Query
				sendQueryAgain="$(curl -ksu "$jssuser":"$jsspass" -H "Content-type: text/xml" $jssurl/JSSResource/computergroups/id/$newgroupid -X PUT -d "<?xml version=\"1.0\" encoding=\"utf-8\"?><computer_group><computer_additions><computer><id>$computerid</id></computer></computer_additions></computer_group>")"
				
				#Check for 404 again
				if [[ "$sendQueryAgain" =~ ^\<html\> ]]; then	
					#If it still failed, give up and write it out
					echo "Computer ID $computerid Status: VALID - REQUEST TIMED OUT, NOT ADDED" >> $outputFile		
				else				
					#If that made it work, sweet, mission accomplished
					echo "Computer ID $computerid Status: VALID - ADDED" >> $outputFile				
				fi	
						
			else			
				#Device added, write it out
				echo "Computer ID $computerid Status: VALID - ADDED" >> $outputFile			
			fi		
		else		
			#Device was found, but unmanaged.
			echo "Computer ID $computerid Status: INVALID - UNMANAGED" >> $outputFile
		fi
	fi
done