import json

def handler(event, context):
	print("EVENT: {}".format(event))
	message = 'Hello Evan'  
	return respond(None, message) 

def respond(err, response=None):
	return {
		'statusCode': '400' if err else '200',
		'body': err if err else json.dumps(response),
		'headers': {
			'Content-Type': 'application/json',
		},
	}