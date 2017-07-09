#!/bin/bash

if sudo profiles -P | egrep -q ': 36890E84-54FC-4E46-A2D5-1ABB10B4F167'; then
	 echo "<result>Yes</result>"
else
	 echo "<result>No</result>"
fi