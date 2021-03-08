#!/bin/bash

#Get the value for the BootstrapTokenAllowedForAuthentication key
output=$(/usr/libexec/mdmclient QuerySecurityInfo | awk -F '[=]' '/BootstrapTokenAllowedForAuthentication/ {print $NF}' | tr -d '";')

#Trim off the leading space
output=${output:1}

echo "<result>$output</result>"