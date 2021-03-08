#!/bin/bash

#Get the status of the bootstrap token
output=$(profiles status -type bootstraptoken)

#If we got an error, the output is empty and that means the Mac isn't supervised
if [[ "$output" == "" ]]; then
	echo "<result>Not Supported</result>"
else
	
	#If we didn't get an error, then just grab the last part of the line containing "escrowed"
	output=$(echo "$output" | awk '/escrowed/ {print $NF}')

	#If escrowed is YES...
	if [[ "$output" = "YES" ]]; then
		echo "<result>Yes</result>"
	else
		echo "<result>No</result>"
	fi
fi

