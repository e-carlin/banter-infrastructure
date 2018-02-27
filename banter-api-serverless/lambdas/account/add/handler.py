import json
import logging
from plaid import Client
from marshmallow import Schema, fields, ValidationError

PLAID_CLIENT_ID = '59dd926b4e95b872dbbb6cdf'
PLAID_SECRET_KEY = '2e17db39ac71ebd3810b276801569e'
PLAID_PUBLIC_KEY = '74912a00575badb2f1b0f1b8bdfde2'
PLAID_ENV = 'sandbox'

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
  logger.info('Handler called. Event: {}'.format(event))
  
  client = get_plaid_client()

  return {
    'status' : 200,
    'body' : json.dumps(event)
  }


def get_plaid_client():
  try:
    client = Client(client_id=PLAID_CLIENT_ID,
                          secret=PLAID_SECRET_KEY,
                          public_key=PLAID_PUBLIC_KEY,
                          environment=PLAID_ENV)
    return client
  except Exception as e:
    logger.error('Exception raised when trying to create Plaid client. Exception: {}'.format(e))
    raise Exception("Error creating Plaid client")


class AddAccountSchema(Schema):
    account_type = fields.String(required=True,
        error_messages={'required' : 'account_type is a required field'}
    )
    public_token = fields.String(required=True,
        error_messages={'required' : 'public_token is a required field'}
    )
    account_id = fields.String(required=True,
        error_messages={'required' : 'account_id is a required field'}
    )
    account_name = fields.String(required=True,
        error_messages={'required' : 'account_name is a required field'}
    )
    link_session_id = fields.String(required=True,
        error_messages={'required' : 'link_session_id is a required field'}
    )
    # TODO: We should make a nested schema to validate the fields in the accounts object
    accounts = fields.String(required=True,
        error_messages={'required' : 'accounts is a required field'}
    )
    institution_name = fields.String(required=True,
        error_messages={'required' : 'institution_name is a required field'}
    )
    institution_id = fields.String(required=True,
        error_messages={'required' : 'institution_id is a required field'}
    )

if __name__ == "__main__":
  handler(1,2)

# node -p "require('./handler.js').handler(1,2,3)"
# sam local invoke "AddAccount" -e .\test.json
# docker run --rm -v C:\Users\evan.carlin\Documents\personal\banter\infrastructure\banter-api-serverless\build:/var/task lambci/lambda:python3.6 lambdas/account/add/handler.handler
# pip install marshmallow --pre -t build (--pre is only for marshmallow exclued it for install for any other package)