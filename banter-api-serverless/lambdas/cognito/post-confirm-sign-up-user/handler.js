exports.handler = function(event, context) {

    // console.log("HERE WE ARE: "+JSON.stringify(event));
    // // Return result to Cognito
    // context.done(null, event);
    context.succeed(event);
};