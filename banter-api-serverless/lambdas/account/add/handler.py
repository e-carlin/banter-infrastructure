import json
from json import JSONDecodeError
import logging
from plaid import Client
from marshmallow import Schema, fields, ValidationError
import boto3

# TODO: Move to env vars
PLAID_CLIENT_ID = '59dd926b4e95b872dbbb6cdf'
PLAID_SECRET_KEY = '2e17db39ac71ebd3810b276801569e'
PLAID_PUBLIC_KEY = '74912a00575badb2f1b0f1b8bdfde2'
PLAID_ENV = 'sandbox'

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    logger.info('Handler called. Event: {}'.format(event))

    try:
      parsed_data = parse_request(event.body, AddAccountSchema)
    except ValidationError as err:
        logger.error(
            "ValidationError thrown when parsing request. Error: {}".format(err))
        return {
          'status': 400,
          'body': json.dumps(event)
        }
    except JSONDecodeError as err:
        logger.error(
            "JSONDevodeErrror thrown when parsing request. Error: {}".format(err))
        return {
          'status': 400,
          'body': json.dumps(event)
        }


    logger.info("The plaid link_session_id is '{}'".format(
        parsed_data['link_session_id']))  # Plaid docs recommend logging this

    # exchange_response = exchange_public_token(parsed_data['public_token'])

    return {
        'status': 200,
        'body': json.dumps(event)
    }


def exchange_public_token(public_token):
    logger.info(
        "Trying to exchange public token with Plaid. Token: {}".format(public_token))
    client = get_plaid_client()
    try:
        exchange_response = client.Item.public_token.exchange(public_token)
        logger.debug(
            "Received response from Plaid '{}'".format(exchange_response))
        logger.info("Succesfully exchanged Plaid public token for an access token and item id!. Response: {}".format(
            exchange_response))
        return exchange_response
    except Exception as e:
        logger.error(
            "Error exchanging public token with Plaid. Exception: {}".format(e))
        raise Exception("There was an error exchanging the public token.")


def get_plaid_client():
    try:
        client = Client(client_id=PLAID_CLIENT_ID,
                        secret=PLAID_SECRET_KEY,
                        public_key=PLAID_PUBLIC_KEY,
                        environment=PLAID_ENV)
        return client
    except Exception as e:
        logger.error(
            'Exception raised when trying to create Plaid client. Exception: {}'.format(e))
        raise Exception("Error creating Plaid client")


def parse_request(request, schema):
    schema = schema()
    data = schema.load(request)
    logger.info('Parsed request is: {}'.format(data))
    return data


class InstitutionSchema(Schema):
    # "institution":{"name":"Cy-Co Federal Credit Union","institution_id":"ins_102361"}
    name = fields.String(required=True,
                         error_messages={
                             'required': 'name is a required field'}
                         )
    institution_id = fields.String(required=True,
                                   error_messages={
                                       'required': 'institution_id is a required field'}
                                   )


class AddAccountSchema(Schema):
    # account_type = fields.String(required=True,
    #                              error_messages={
    #                                  'required': 'account_type is a required field'}
    #                              )
    public_token = fields.String(required=True,
                                 error_messages={
                                     'required': 'public_token is a required field'}
                                 )
    link_session_id = fields.String(required=True,
                                    error_messages={
                                        'required': 'link_session_id is a required field'}
                                    )
    institution = fields.Nested(InstitutionSchema,
                                required=True,
                                error_messages={
                                    'required': 'institution is a required field'}
                                )
    # account_id = fields.String(required=True,
    #                            error_messages={
    #                                'required': 'account_id is a required field'}
    #                            )
    # account_name = fields.String(required=True,
    #                              error_messages={
    #                                  'required': 'account_name is a required field'}
    #                              )
    # # TODO: We should make a nested schema to validate the fields in the accounts object
    # accounts = fields.String(required=True,
    #                          error_messages={
    #                              'required': 'accounts is a required field'}
    #                          )
    # institution_name = fields.String(required=True,
    #                                  error_messages={
    #                                      'required': 'institution_name is a required field'}
    #                                  )
    # institution_id = fields.String(required=True,
    #                                error_messages={
    #                                    'required': 'institution_id is a required field'}
    #                                )


if __name__ == "__main__":
    handler(1, 2)


# METADATA: {"institution":{"name":"Cy-Co Federal Credit Union","institution_id":"ins_102361"},"account":{"id":"KvKGWW7D7VckDJ8Jz8gmszyZjLmJ8vCgA41b9","name":"Plaid CD","type":"depository"},"account_id":"KvKGWW7D7VckDJ8Jz8gmszyZjLmJ8vCgA41b9","accounts":[{"id":"KvKGWW7D7VckDJ8Jz8gmszyZjLmJ8vCgA41b9","name":"Plaid CD","type":"depository"},{"id":"lxGpooPnP1uqPoLodLayTdl3RPb95pi1dDR8y","name":"Plaid Saving","type":"depository"}],"link_session_id":"e1c918a3-5466-4ee9-b7d8-9adc2a2e4fa0","public_token":"public-sandbox-ef7792f0-766e-426d-bea4-8ca38efb3ac2"}

# node -p "require('./handler.js').handler(1,2,3)"
# sam local invoke "AddAccount" -e .\test.json
# docker run --rm -v C:\Users\evan.carlin\Documents\personal\banter\infrastructure\banter-api-serverless\build:/var/task lambci/lambda:python3.6 lambdas/account/add/handler.handler
# pip install marshmallow --pre -t build (--pre is only for marshmallow exclued it for install for any other package)
