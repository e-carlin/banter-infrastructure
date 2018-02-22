import boto3

client = boto3.client('cognito-idp')

users = client.list_users(
    UserPoolId="us-east-1_M0GwiV1g7"
)

for user in users['Users']:
    print(user['Username'])
    client.admin_disable_user(
        UserPoolId="us-east-1_M0GwiV1g7",
        Username=user['Username']
    )
    client.admin_delete_user(
        UserPoolId="us-east-1_M0GwiV1g7",
        Username=user['Username']
    )
