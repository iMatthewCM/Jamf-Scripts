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
# HISTORY
#
#	Version: 1.0
#
#   Release Notes:
#   - Initial release
#
#	- Created by Matthew Mitchell on June 30, 2017
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

autocheck=$(sudo defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled)

autodownload=$(sudo defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload)

autoupdate=$(sudo defaults read /Library/Preferences/com.apple.commerce.plist AutoUpdate)

macupdate=$(sudo defaults read /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired)

secupdate=$(sudo defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall)

if [[ "$autocheck" -eq "1" && "$autodownload" -eq "1" && "$autoupdate" -eq "1" && "$macupdate" -eq "1" && "$secupdate" -eq "1" ]]; then
	echo "<result>Enabled</result>"
else
	echo "<result>Disabled</result>"
fi


