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
#	unlockDock.sh - Unlocks the Dock completely
#
# DESCRIPTION
#
#	This script removes any locks on removing/adding content to, changing the position of,
#	or changing the size of, the Dock
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
#	- Created by Matthew Mitchell on June 26, 2017
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

user=`ls -l /dev/console | awk '/ / { print $3 }'`
sudo -u $user defaults write com.apple.Dock contents-immutable -bool no
sudo -u $user defaults write com.apple.Dock position-immutable -bool no
sudo -u $user defaults write com.apple.Dock size-immutable -bool no
sudo killall Dock