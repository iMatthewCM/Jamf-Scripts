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
#	validateFirmware.sh - Utilizes Duo's EFIgy script to validate macOS firmware
#
# DESCRIPTION
#
#	This script will trigger the EFIgy.py script to run, create a log, and then get the firmware
#	result from the log and send it back to the JSS in the form of an Extension Attribute
#
# REQUIREMENTS
#
#   This script needs to be deployed with a package that installs the EFIgy python script and .pem file
#	to the /tmp/EFIgy directory, as well as an Extension Attribute in the JSS to write to. The script
#	needs to have a Priority of After. The EA needs to utilize Text Field as an Input Type, and String
#	as a Data Type.
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
#	- Created by Matthew Mitchell on October 9, 2017
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#API Username
#Use Parameter 4 in the JSS, or replace $4 with your username surrounded by quotes
#Example: apiUser="admin"
apiUser=$4

#API Password
#Use Parameter 5 in the JSS, or replace $5 with your password surrounded by quotes
#Example: apiPass="jamf1234"
apiPass=$5

#Enter ID number of the EA to populate
#This is found in the JSS URL when looking at the EA
#Use Parameter 6 in the JSS, or replace $6 with the EA ID
#Example: ?id=4&o=r    ID is 4
eaID=$6
 
# Enter the exact Display Name of the Extension Attribute
#Use Paramter 7 in the JSS, or replace $7 with the EA Display Name surrounded by quotes
#Example: eaName="Firmware Valid"
eaName=$7

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Remove existing directory to ensure we don't have extra data later on
rm -rf /tmp/EFIgy/log

#Make a brand new directory with nothing in it
mkdir /tmp/EFIgy/log

#Run the EFIgy script and write a log to /tmp/EFIgy/log
python /tmp/EFIgy/EFIgyLite_cli.py -q -l /tmp/EFIgy/log

#List out the contents of the .../log directory
#Since we just remade a brand new one, the latest log is the only thing that should be in there.
#The logName gets an epoch timestamp in the name, so we can't count on what it will be called
logName=$(ls /tmp/EFIgy/log)

#Variable for later, complete path with log name
logPath=/tmp/EFIgy/log/$logName

#These two lines get the line number that the "Success" or "Attention" message will be on
statusLineNum=`cat $logPath | grep -n "EFI firmware version" | awk -F : '{print $1}'`
statusLineNum=$(expr $statusLineNum + 1)

#Get a copy of the "Success / Attention" line
efiStatus=`head -n $statusLineNum $logPath | tail -n 1`

#Parse out that line to see if it says "Success" or "Attention"
firmwareLogOutput=$(echo $efiStatus | cut -d ']' -f2 | cut -d '-' -f1 | sed 's/ //g')

#If it said Success
if [ "$firmwareLogOutput" == "SUCCESS" ]; then
	#Firmware is valid
	value="True"
else
	#Firmware is invalid
	value="False"
fi

#Set up a path to write to
xmlPath='/tmp/tmp.xml'

#Get serial number of current computer
serial=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'`
 
#Create our XML file for API PUT
cat <<EndXML > $xmlPath
<?xml version="1.0" encoding="UTF-8"?>
<computer>
	<extension_attributes>
		<extension_attribute>
			<id>$eaID</id>
			<name>$eaName</name>
			<type>String</type>
			<value>$value</value>
		</extension_attribute>
	</extension_attributes>
</computer>
EndXML

#Get the JSS URL that this computer is enrolled in
url=$(defaults read /Library/Preferences/com.jamfsoftware.jamf jss_url | grep https:// | sed 's/.$//')
 
#Post XML file to JSS, updates the EA
curl -sk -u $apiUser:$apiPass $url/JSSResource/computers/serialnumber/"${serial}"/subset/extensionattributes -T $xmlPath -X PUT
 
#Clean up temp files
rm -rf $xmlPath