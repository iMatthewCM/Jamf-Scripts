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
#	lockDock.sh - Allows locking various aspects of the Dock
#
# DESCRIPTION
#
#	This script can lock the dock contents (and their position), the location of the dock on screen,
#	and the size of the dock.
#
# REQUIREMENTS
#
#   This script simply needs to be deployed via Policy, or run locally on a machine.
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
#	- Created by Matthew Mitchell on April 29, 2017
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#To Prevent Changing or Rearranging Apps, set this to yes
preventChangingApps=yes

#To Prevent Changing the Location of the Dock, set this to yes
preventChangingLocation=yes

#To Prevent Changing the Size of the Dock, set this to yes
preventChangingSize=yes

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

user=`ls -l /dev/console | awk '/ / { print $3 }'`
sudo -u $user defaults write com.apple.Dock contents-immutable -bool $preventChangingApps
sudo -u $user defaults write com.apple.Dock position-immutable -bool $preventChangingLocation
sudo -u $user defaults write com.apple.Dock size-immutable -bool $preventChangingSize
sudo killall Dock