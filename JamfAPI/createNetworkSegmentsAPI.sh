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
#	createNetworkSegmentsAPI.sh - Creates Network Segments based off of a CSV
#
# DESCRIPTION
#
#	This script will read in a CSV file and create a new Network Segment in the JSS according to what
#	is on each line of the CSV
#
# REQUIREMENTS
#
#   The CSV should have the following on the first line:
#	name,starting_address,ending_address,distribution_point,building,department,override_buildings,override_departments
#
#	The CSV can then be built up from there using those column headers as indicators of what information should go in the field
#
#	For best results, ensure that any Buildings or Departments listed in the CSV already exist in the JSS.
#	Capitalization for Buildings & Departments does not matter.
#	Capitalization for distribution_point DOES matter (To point at JCDS, use Cloud Distribution Point
#	Capitalization for override_buildings and override_departments DOES matter, use true or false
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
#	- Created by Matthew Mitchell on October 31, 2017
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#If something is going strangely, set this to "true" for additional debugging
debug="false"

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

echo "Please drag and drop your CSV file into this window and hit ENTER"
read segmentFile

#Read CSV into array
IFS=$'\n' read -d '' -r -a segmentsToAdd < $segmentFile

length=${#segmentsToAdd[@]}

#Starting with i=1 so we skip the header line, which is index 0
for ((i=1; i<$length; i++));
do
	
	segmentName=$(echo ${segmentsToAdd[$i]} | cut -d ',' -f1)
	startingIP=$(echo ${segmentsToAdd[$i]} | cut -d ',' -f2)
	endingIP=$(echo ${segmentsToAdd[$i]} | cut -d ',' -f3)
	distroPoint=$(echo ${segmentsToAdd[$i]} | cut -d ',' -f4)
	building=$(echo ${segmentsToAdd[$i]} | cut -d ',' -f5)
	department=$(echo ${segmentsToAdd[$i]} | cut -d ',' -f6)
	overrideBuildings=$(echo ${segmentsToAdd[$i]} | cut -d ',' -f7)
	overrideDeparments=$(echo ${segmentsToAdd[$i]} | cut -d ',' -f8)
	
	if [ "$debug" == "true" ]; then
	
		echo ""
		echo "Segment Name: $segmentName"
		echo "Starting IP: $startingIP"
		echo "Ending IP: $endingIP"
		echo "Distro Point: $distroPoint"
		echo "Building: $building"
		echo "Department: $department"
		echo "Override Building: $overrideBuildings"
		echo "Override Departments: $overrideDeparments"
		echo "------------------------------------"
	
	fi
	
	curl -H "Content-Type: text/xml" -d "<network_segment><name>$segmentName</name><starting_address>$startingIP</starting_address><ending_address>$endingIP</ending_address><distribution_point>$distroPoint</distribution_point><building>$building</building><department>$department</department><override_buildings>$overrideBuildings</override_buildings><override_departments>$overrideDeparments</override_departments></network_segment>" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/networksegments/id/0"  -X POST
	
done
