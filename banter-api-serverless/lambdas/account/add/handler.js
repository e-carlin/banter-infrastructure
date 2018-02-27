'use strict';
console.log('Loading hello world function');

const plaid = require('plaid');

const client_id='59dd926b4e95b872dbbb6cdf';
const secret='2e17db39ac71ebd3810b276801569e';
const public_key='74912a00575badb2f1b0f1b8bdfde2';
const plaid_env='sandbox';
 
exports.handler = function(event, context, callback) {
  console.log("EVENT: "+event);

  const plaidClient = new plaid.Client(client_id, secret, public_key, plaid.environments[plaid_env]);
  console.log("PlaidClient: "+ JSON.stringify(plaidClient));
  plaidClient.exchangePublicToken("abc123", function(error, tokenResponse) {
    if (error != null) {
      var msg = 'Could not exchange public_token!';
      console.log(msg + '\n' + error);
      console.log("RESP: "+tokenResponse);
      context.fail("Error exchanging public token");
    }
    else{
      ACCESS_TOKEN = tokenResponse.access_token;
      ITEM_ID = tokenResponse.item_id;
      console.log('Access Token: ' + ACCESS_TOKEN);
      console.log('Item ID: ' + ITEM_ID);
      context.succed("Success exchanging public token");
    }
  });
    
    // The output from a Lambda proxy integration must be 
    // of the following JSON object. The 'headers' property 
    // is for custom response headers in addition to standard 
    // ones. The 'body' property  must be a JSON string. For 
    // base64-encoded payload, you must also set the 'isBase64Encoded'
    // property to 'true'.
    // var response = {
    //     statusCode: 200,
    //     body: JSON.stringify({
    //       "hello" : "from add account"
    //     })
    // };
    // console.log("response: " + JSON.stringify(response))
    // callback(null, response);
};


// node -p "require('./handler.js').handler(1,2,3)"
// sam local invoke "AddAccount" -e .\test.json