#!/bin/sh
####################################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT 
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	configureAppUpdate.sh - Configures Automatic App Update settings for macOS through Apple API
#
# DESCRIPTION
#
#	This script can configure the settings in the App Store preference pane according to how the
#   IT Admin wants the settings to appear. The description before each variable below references
#   the exact text of the checkbox it is modifying. Valid input is given in the description for
#   each setting. Deploy this script in a Policy to each machine you'd like to have these settings.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#   Release Notes:
#   - Implemented workaround for macOS bug that requires CriticalUpdateInstall and ConfigDataInstall
#     to be set to the same value.
#
#	- Created by Matthew Mitchell on December 2, 2016
#   - Updated by Matthew Mitchell on December 3, 2016
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Popup notifying updates are available (OFF / ON)
#Suggestion: Keep this OFF
notifyme=OFF

#Automatically check for updates (YES / NO)
autoupdates=YES

#Download newly available updates in the background (YES / NO)
background=YES

#Install app updates (YES / NO)
appupdate=YES

#Install macOS updates (YES / NO)
macupdate=YES

#Install system data files and security updates (YES / NO)
critupdate=YES

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

osascript -e "tell application \"System Preferences\" to quit"

sudo softwareupdate --schedule $notifyme 

sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool $autoupdates

sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool $background

sudo defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool $appupdate

sudo defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired -bool $macupdate 

sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool $critupdate

#There appears to be a bug in macOS Sierra that requires ConfigDataInstall to be set the same as CriticalUpdateInstall
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool $critupdate
