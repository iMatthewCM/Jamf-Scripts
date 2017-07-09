# Introduction

This is a collection of Scripts used to extend the functionality of Jamf Pro’s macOS management capabilites. They are originally written by Matthew Mitchell, a Strategic Technical Account Manager at Jamf[^1], although community members are welcome to submit Pull Requests and add their name to the Script under the *Version History* section if they contribute something to a Script.

There are three categories of Scripts on this GitHub: API Scripts, macOS Scripts, and Extension Attributes.

***API Scripts*** can be run on anything that can run Bash. They do not need to be deployed to computers enrolled in Jamf Pro.
***macOS Scripts*** are written to be deployed via a Jamf Pro Policy to a macOS device.
***Extension Attributes*** are used to collect additional Inventory information for computers enrolled in Jamf Pro.

Each script is categorized and listed alphabetically below with a description of what it does. If you are interested in contributing to this GitHub, a very brief Style Guide is at the bottom of this README.

## Jamf API Scripts

These Scripts all utilize Jamf’s REST API to do something useful in the JSS. You always need to enter your JSS URL and Administrative Credentials. Some Scripts additionall require a CSV or other input.

#### DepartmentsAPI.sh

**Purpose:** Use this Script to make a bunch of Departments all at once. You just need to feed in a .txt file containing each Department name to add. Put each Department name on a new line.

#### GetiPadBySerialAPI.sh

**Purpose:** Get *all* Inventory information for a single iPad by entering its Serial Number. This is returned as XML. Sometimes useful for troubleshooting potentially incorrect Inventory Display (when Tomcat is displaying one thing, but MySQL says differently)

#### DeleteComputersAPI.sh

**Dangerous Purpose:** This is a small atomic bomb you can run to delete a handful of computers out of your JSS. You need a CSV with the JSS ID for each computer you want to delete. This is probably a bad idea to run, but sometimes it’s necessary. Use with caution.

[^1]: These Scripts are not official Jamf products and are provided without warranty. Do not contact Jamf Support to ask for help using these Scripts as scripting is ***unsupported*** except as a paid engagement with Professional Services.
