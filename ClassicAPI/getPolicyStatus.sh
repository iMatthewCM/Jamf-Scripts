#!/bin/bash

#############################################
#	 Created by iMatthewCM on 03/08/2021	#
#################################################################################################
# This script is not an official product of Jamf Software LLC. As such, it is provided without  
# warranty or support. By using this script, you agree that Jamf Software LLC is under no 		
# obligation to support, debug, or otherwise maintain this script. Licensed under MIT.			
#																								
# NAME: getPolicyStatus.sh																	
# DESCRIPTION: This script will look at each enrolled computer's policy history and report back
# the status of a particular policy from each computer, saved to a CSV
#################################################################################################

##########################
# VARIABLES TO CONFIGURE #
##########################

#Your Jamf Pro URL
#Do not include a trailing /
JAMF_PRO_URL="https://jss.jamfcloud.com"

#Your API account credentials, encoded as base64
#The only permissions this account needs is "Read" on Computers
#To obtain this value, run something like this in Terminal:
# echo -n "username:password" | base64
AUTHENTICATION_STRING="dXNlcm5hbWU6cGFzc3dvcmQ="

#The Policy ID that we want the status of
POLICY_ID_TO_CHECK="8"

#The following three variables are asking for paths to store things
#ONLY include the directory to store the item in - the script handles the file name and extension

#The location that a stylesheet can be written out to
#This file will be deleted when the script is done running
STYLESHEET_PATH="/tmp"

#The location to store a temporary CSV
#This file will be deleted when the script is done running
TEMP_CSV_PATH="/tmp"

#The location to SAVE your finished report to
CSV_PATH="/Users/admin/Desktop"

#################################################
# STOP! DO NOT CHANGE ANYTHING BELOW THIS LINE! #
#################################################

#Fill in the rest of our file path variables
STYLESHEET_PATH="$STYLESHEET_PATH/stylesheet.xslt"
TEMP_CSV_PATH="$TEMP_CSV_PATH/temp.csv"
CSV_PATH="$CSV_PATH/PolicyStatus_`/bin/date +%b-%d-%Y_%H-%M `.csv"

echo "Gathering and parsing policy information..."
echo "If you have a lot of computers in your environment, this script might take a bit to fully complete"

#Get the data for all of our computers
allComputers=$(/usr/bin/curl -s -H "Authorization: basic $AUTHENTICATION_STRING" -H "accept: text/xml" "$JAMF_PRO_URL/JSSResource/computers" -X GET)

#Create an array of all of our computer IDs
computerIDs=()
computerIDs+=($(echo "$allComputers" | /usr/bin/xmllint --format - | /usr/bin/awk -F '[<>]' '/<id>/{print $3}'))

#Create our stylesheet for use later on
/bin/cat << EOF > "$STYLESHEET_PATH"
<?xml version="1.0" encoding="UTF-8"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 
<xsl:output method="text"/> 
<xsl:template match="/computer_history/policy_logs"> 
<xsl:for-each select="policy_log"> 
<xsl:value-of select="policy_id"/> 
<xsl:text>,</xsl:text> 
<xsl:value-of select="status"/> 
<xsl:text>&#xa;</xsl:text> 
</xsl:for-each> 
</xsl:template> 
</xsl:stylesheet>
EOF

#For each computer ID in the array we just created....
for ((i=0; i<${#computerIDs[@]}; i++))
do
	
	#Get the value of i+1, since XML arrays are zero-indexed
	iValuePlusOne=$((i+1))
	
	#Get the name of the computer associated to this computer ID
	computerName=$(echo "$allComputers" | /usr/bin/xmllint --xpath '/computers/computer'[$iValuePlusOne]'/name/text()' -)
	
	#Write that name out to the temporary CSV
	echo "$computerName,">> "$TEMP_CSV_PATH"
	
	#Get that computer's entire policy history and run it through the stylesheet
	/usr/bin/curl -s -H "Authorization: basic $AUTHENTICATION_STRING" -H "accept: text/xml" "$JAMF_PRO_URL/JSSResource/computerhistory/id/${computerIDs[i]}/subset/PolicyLogs" -X GET | /usr/bin/xsltproc "$STYLESHEET_PATH" - >> "$TEMP_CSV_PATH"
	
done

#Filter the CSV
#We're saving rows that either contain the policy ID we're looking for in column 1...
#Or if the second column is empty, which means the first column contains the computer name
filteredCSV=$(/usr/bin/awk -v id=$POLICY_ID_TO_CHECK -F ',' '$1 == id || $2 == ""' < "$TEMP_CSV_PATH")

#Write out our new filtered CSV
echo "$filteredCSV" > "$TEMP_CSV_PATH"

echo "CSV filtering is complete...preparing final report."

#Reusable variable
computerName=""

#Change IFS to a comma for looping through the CSV
IFS=,

#Loop through our filtered CSV
while read identifier status
do
	
	#If the status column is empty, then this row contains the computer's name, so stash it in the variable up top
	if [[ "$status" = "" ]]; then
		computerName="$identifier"
	else
		#We're in a row containing our policy data, so write it out to our final report file
		echo "$computerName,$status" >> "$CSV_PATH"
		
		#Set out resuable variable back to nothing
		computerName=""
	fi
	
done < "$TEMP_CSV_PATH"

#Just good housekeeping
unset IFS

#Clean up our empty files
/bin/rm "$STYLESHEET_PATH"
/bin/rm "$TEMP_CSV_PATH"

echo "Done! Your finished report for Policy ID $POLICY_ID_TO_CHECK is saved to $CSV_PATH"