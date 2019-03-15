#!/bin/bash

#Read the current value of the root user's password
currentStatus=$(sudo dscl . -read /Users/root Password)

#Return value for a disabled account
disabledStatus="Password: *"

#Check if the status we got is the same as the value for a disabled account
if [[ "$currentStatus" = "$disabledStatus" ]]; then
	echo "<result>Disabled</result>"
else
	echo "<result>Enabled</result>"
fi