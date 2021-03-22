## Jamf Pro API Scripts

These scripts utilize Jamf's newer "Jamf Pro API" instead of the older "Classic API"

The main differences between these scripts, and scripts that utilize the Classic API, are:

1. Token-based authentication
2. JSON

With the Jamf Pro API, you can no longer authenticate against the API in clear text, nor can you use a standard Base64 encoded string as a basic authorization. You *must* use a token, which can be created using the [tokenGenerator.sh](https://github.com/iMatthewCM/Jamf-Scripts/blob/master/JamfProAPI/tokenGenerator.sh) script.

The Jamf Pro API also completely eschews XML in favor of JSON, so you'll see different data structures inside of each script.

To work with the Jamf Pro API using Python, check out the [iMatthewCM Python Library!](https://github.com/iMatthewCM/Jamf-Scripts/blob/master/JamfProAPI/iMatthewCM%20Python%20Library)