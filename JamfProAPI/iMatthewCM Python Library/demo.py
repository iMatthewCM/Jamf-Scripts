import iMatthewCM
import creds
#creds is just a file that has some variables set, to take them out of this script


#Print documentation for iMatthewCM library
iMatthewCM.help()

#Obtain an authorization token
token = iMatthewCM.getToken(creds.server, creds.username, creds.password)

#Define query parameters for our GET
query_params = {'section': ['GENERAL', 'OPERATING_SYSTEM', 'APPLICATIONS'],'page-size':'2000'}

#Perform our API call
computers = iMatthewCM.getData(creds.server, '/api/v1/computers-inventory', token, query_params)

#For each returned computer, print the OS version and number of installed applictions
for computer in computers['results']:
	print(f'Information for "{computer["general"]["name"]}"')
	print(f'macOS {computer["operatingSystem"]["version"]}')
	print(f'{len(computer["applications"])} installed applications')
	print()
