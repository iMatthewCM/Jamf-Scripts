# Welcome

This is a collection of Scripts used to extend the functionality of Jamf Pro’s macOS management capabilites. They are originally written by Matthew Mitchell, a Strategic Technical Account Manager at Jamf, although community members are welcome to submit Pull Requests and add their name to the Script under the *Version History* section if they contribute something to a Script.

These Scripts are **not official Jamf products** and are provided without warranty. Do **not** contact Jamf Support to ask for help using these Scripts as scripting is ***unsupported*** except as a paid engagement with Professional Services.

There are four categories of Scripts on this GitHub: API Scripts, macOS Scripts, Extension Attributes, and Snippets. Each category is in a directory named the same, and there is a README inside each directory detailing its contents.

***API Scripts*** can be run on anything that can run Bash. They do not need to be deployed to computers enrolled in Jamf Pro.

***macOS Scripts*** are written to be deployed via a Jamf Pro Policy to a macOS device.

***Extension Attributes*** are used to collect additional Inventory information for computers enrolled in Jamf Pro.

***Snippets*** are little pieces of code that might be useful to integrate into other projects. By themselves, they're usually pretty pointless.

If you are interested in contributing to this GitHub, please read the following, very brief, Style Guide.

## Style Guide

### 1. Use camel-case for variable names, starting with a lowercase letter.
Examples of **incorrect** names: device_inventory, DeviceInventory,  deviceinventory, DEVICEINVENTORY

Exceptions are made for common acronyms / words. For example, jssURL is acceptable.

### 2. Add comments on as much as possible.
Since these scripts can be used in production environments, it is important to make it as easy as possible for an administrator to see what the script is doing. It is also necessary when documenting "logic" in how data is processed, so that it can be easily understood and modified if necessary.

### 3. Suppress all output that is not being "echoed" or written to a file.

For example, always use the silent flag (-s) on curl commands, and always pipe console output to /dev/null. The only output a user should see should come from echo statements.

### 4. Update the History section when you make changes.

There are a few things to do when updating this section:

- Increase the version number. This repository uses **semantic versioning**, but only so far as major and minor. If your changes were mostly small tweaks or minor functionality improvments, increment the minor version by 1. If you did a drastic rewrite or added considerable functionality, increase the major version by 1 and reset the minor version to 0. (Example, a minor revision to 1.8 would become 1.9. A major revision to 1.8 would become 2.0) ***Do not use a third (patch) number.***
- Delete the previous release notes and replace them with your own. Describe the changes you made in a bulleted (well, with hyphens) list. If your changes mean the script requirements need to change, make sure to update the *REQUIREMENTS* section too.
- Add your name to the bottom of the list of contributors. Use the following format: - Updated by [Name] on [Date] vX.Y
The date format is the full month name followed by the day, with a comma before the year. Example: October 9, 2016. Do **not** put a comma between the month and day.

### 5. Only update multiple scripts in a single commit if the commit message is equally applicable to all scripts in the commit.

The idea here is since this is a collection of scripts rather than a cohesive project or application, each script is an island. So updating 3 scripts at a time and having a message of "Added X to script 1, Y to script 2, and Z to script 3" does no one any good. An example of acceptable use of multiple script updates with a single commit message would be "Added Jamf Pro 10 compatibility."
