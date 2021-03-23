#!/usr/bin/env python3
import requests
import json


def getToken(server: str, username: str, password: str):
	token = requests.post(server + '/api/v1/auth/token', auth=(username, password)).json()['token']
	return token

	
def getData(server: str, endpoint: str, token: str, query_parameters: str):
	headers = {'Authorization': "Bearer " + token}
	response = requests.get(server + endpoint, params=query_parameters, headers=headers)
	return response.json()


def getDataFormatted(server: str, endpoint: str, token: str, query_parameters: str):
	headers = {'Authorization': "Bearer " + token}
	response = requests.get(server + endpoint, params=query_parameters, headers=headers)
	return json.dumps(response.json(),indent=2)


def postData(server: str, endpoint: str, token: str, data: str):
	headers = {'Authorization': "Bearer " + token, 'Content-Type': 'application/json'}
	response = requests.post(server + endpoint, headers=headers, data=json.dumps(data))
	return response.status_code,response.json()


def putData(server: str, endpoint: str, token: str, data: str):
	headers = {'Authorization': "Bearer " + token, 'Content-Type': 'application/json'}
	response = requests.put(server + endpoint, headers=headers, data=json.dumps(data))	
	return response.status_code,response.json()

def help():
	print('''
getToken(server, username, password)
Purpose: obtain an authorization token for the Jamf Pro API
Returns: String
Usage: token = iMatthewCM.getToken('https://JAMF_PRO_URL', 'myUsername', 'myPassword')

getData(server, endpoint, token, query_parameters)
Purpose: perform a GET operation on any given endpoint
Returns: Raw JSON
Usage: computer_data = iMatthewCM.getData('https://JAMF_PRO_URL', '/api/v1/computers-inventory', token, query_parameters)
Notes: query_parameters can be left empty, but still needs to be passed as an argument. Just pass "" in place of a value.
	For more complicated parameters, save them to a variable beforehand and pass the entire variable
	Example: query_parameters = {'section': ['GENERAL'], 'page-size':'2000'}
	
getDataFormatted(server, endpoint, token, query_parameters)
Purpose: perform a GET operation on any given endpoint
Returns: Formatted JSON
Usage: computer_data = iMatthewCM.getData('https://JAMF_PRO_URL', '/api/v1/computers-inventory', token, query_parameters)
Notes: If you plan to do anything with the data other than look at it, you probably want getData() instead of this function.
    query_parameters can be left empty, but still needs to be passed as an argument. Just pass "" in place of a value.
	For more complicated parameters, save them to a variable beforehand and pass the entire variable
	Example: query_parameters = {'section': ['GENERAL'], 'page-size':'2000'}

postData(server, endpoint, token, data)
Purpose: perform a POST operation on any given endpoint
Returns: HTTP response code and JSON response body
Usage: response = iMatthewCM.postData('https://JAMF_PRO_URL', '/api/v1/buildings', token, data)
Notes: The data parameter is expecting formatted JSON. Create your data in a variable, and pass the variable to the function.
	Example:
	data = {
		"name": "A New Building",
		"country": "USA"
	}

putData(server, endpoint, token, data)
Purpose: perform a PUT operation on any given endpoint
Returns: HTTP response code and JSON response body
Usage: response = iMatthewCM.putData('https://JAMF_PRO_URL', '/api/v1/buildings/10', token, data)
Notes: The data parameter is expecting formatted JSON. Create your data in a variable, and pass the variable to the function.
	Example:
	data = {
		"name": "A Building Name to Change"
	}
	''')