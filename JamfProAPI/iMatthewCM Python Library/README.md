## iMatthewCM Python Library

The goal of this library is to shuffle the actual Jamf Pro API work outside of your primary Python script, leaving you with only the responsibility to parse the output and display results.

This library **requires Python 3** as well as the **requests** library. To get these set up on a Mac, take a look at my [cliffnote document](https://github.com/iMatthewCM/Jamf-Scripts/blob/master/Workflows/Install%20Python%203%20on%20Mac.sh) which is taken from and based off of [this article from opensource.com](https://opensource.com/article/19/5/python-3-default-mac).

To use the library, simply place the iMatthewCM.py file inside the same directory as the script you're working on, and import it using:

`import iMatthewCM`

You don't necessarily need to import `json` or `requests` in your script, unless *your* code is going to explicitly leverage either of them. Otherwise, the library file already imports what it needs.

To see what features are available in the library, execute:

`iMatthewCM.help()`

Take a look at [demo.py](https://github.com/iMatthewCM/Jamf-Scripts/blob/master/JamfProAPI/iMatthewCM%20Python%20Library/demo.py) for some usage examples!