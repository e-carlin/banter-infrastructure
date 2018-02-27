import boto3
import json
client = boto3.client('cognito-idp')

response = client.initiate_auth(
    AuthFlow='USER_PASSWORD_AUTH',
    AuthParameters={
        'USERNAME' : 'evforward123@gmail.com',
        'PASSWORD' : '12345678'
    },
    ClientId = '5983dgn1d2jum78or5mg6cqsk9'
)

print(response['AuthenticationResult']['AccessToken'])