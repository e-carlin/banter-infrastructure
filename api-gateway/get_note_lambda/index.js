'use strict';

console.log('Loading function');



/**
 * Provide an event that contains the following keys:
 *
 *   - operation: one of the operations in the switch statement below
 *   - tableName: required for operations that interact with DynamoDB
 *   - payload: a parameter to pass to the operation being performed
 */
exports.handler = (event, context, callback) => {
  
    const payload = event.payload;
    console.log("***** Returning payload *****")
    callback(null, payload);

};
