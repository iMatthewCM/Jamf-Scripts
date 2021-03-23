## iMatthewCM Python Library Release Notes

**3/23/21 - Version 0.2.1**  

* Updated help() function with version information

**3/23/21  -  Version 0.2.0**  

* Added new function: putData(server, endpoint, token, data)
* Updated help() function with putData documentation

**3/22/21  -  Version 0.1.0**  
**Important Implementation Note!**  
While I do not expect to make breaking changes such as renaming functions or re-ordering their arguments, until I have more fully built out this library those breaking changes are possible. If a breaking change is ever made during this period, it will be called out in the release notes. A major feature of version **1.0.0** will be a style guide to prevent any breaking changes going forward.

**Initial release**  
Available functions:  

* help()
* getToken(server, username, password)
* getData(server, endpoint, token, query_parameters)
* getDataFormatted(server, endpoint, token, query_parameters)
* postData(server, endpoint, token, data)