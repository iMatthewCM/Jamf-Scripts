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
#	displayNotification.sh - Displays a macOS Notification
#
# DESCRIPTION
#
#	Displays a notification which will appear on screen as well as in Notification Center
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Added variables for easy customization
#
#	- Created by Matthew Mitchell on August 29, 2016
#	- Updated by Matthew Mitchell on February 13, 2017 (Version 1.1)
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Notification Title
#This is the bold text that will appear at the top of the notification
#You MUST maintain the double quotes around the title.
title="This is the title of the notification!"

#Notification Message
#This is the body of text you want to appear
#You MUST maintain the double quotes around the message.
message="This is the message I want my users to see."

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

osascript -e "display notification \"$message\" with title \"$title\"" 