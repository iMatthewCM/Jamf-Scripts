#!/bin/bash

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

echo "Please enter the name of the Smart Group to convert to a Static Group"
read smartGroupName
echo ""

#Generate a name for the static group
staticName="$smartGroupName - Static"

#Tell the user what we are making
echo "Creating Static Group: $staticName ..."
echo ""

#Throw %20 in place of spaces so we can GET properly
formattedName=$(echo "$smartGroupName" | sed s/' '/%20/g)

#GET all computer IDs in the specified smart group
allComputerIDs=$(curl -H "Accept: text/xml" -ksu $jssUser:$jssPass "$jssURL/JSSResource/computergroups/name/$formattedName" | xpath //computer_group/computers/computer/id 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g | sed 's/.$//')

#Read the computer IDs into an array
IFS=',' read -r -a computerIDs <<< "$allComputerIDs"

#Get the length of the array so we can loop through it
idlength=${#computerIDs[@]}

#build the xml to POST
apiPOST="<computer_group><name>$staticName</name><is_smart>false</is_smart><computers>"

#add computers to group
for ((i=0; i<$idlength;i++));
do
	deviceid=$(echo "${computerIDs[$i]}" | sed 's/,//g' | tr -d '\r\n')
	apiPOST+="<computer><id>$deviceid</id></computer>"
	
done

#Close up the data
apiPOST+="</computers></computer_group>"

#POST the group
curl -H "Content-Type: text/xml" -d "$apiPOST" -ksu "$jssUser":"$jssPass" "$jssURL/JSSResource/computergroups/id/0" -X POST

echo ""
echo "Done."