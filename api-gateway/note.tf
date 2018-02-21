resource "aws_api_gateway_method" "notes_post_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.banter_api.id}"
  resource_id   = "${aws_api_gateway_resource.notes_resource.id}"
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.demo_auth.id}"
  request_models  {
      "application/json" = "user" #TODO: This should be the name of the notecreatemodel
  }
}

resource "aws_api_gateway_resource" "notes_resource" {
  path_part = "notes"
  parent_id = "${aws_api_gateway_rest_api.banter_api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.banter_api.id}"
}

resource "aws_lambda_function" "get_note_lambda" {
    filename = "get_note_lambda.zip"
    function_name = "get_note_lambda_tf"
    role = "${aws_iam_role.get_note_lambda_role.arn}"
    handler = "index.handler"
    runtime = "nodejs4.3"
    source_code_hash = "${base64sha256(file("get_note_lambda.zip"))}"

}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.banter_api.id}"
  resource_id = "${aws_api_gateway_resource.notes_resource.id}"
  http_method = "${aws_api_gateway_method.notes_post_method.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_model" "NoteCreateModel" {
  rest_api_id  = "${aws_api_gateway_rest_api.banter_api.id}"
  name         = "user"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = <<EOF
{
  "title": "Note Create Model",
  "type" : "object",
  "properties" : {
    "noteid" : {
       "type" : "string"
    },
    "note" : {
      "type" : "string"
    }
   },
  "required" : ["noteid", "note"]
}
EOF
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.banter_api.id}"
  resource_id             = "${aws_api_gateway_resource.notes_resource.id}"
  http_method             = "${aws_api_gateway_method.notes_post_method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.myregion}:lambda:path/2015-03-31/functions/${aws_lambda_function.get_note_lambda.arn}/invocations"

   request_templates {
    "application/json" = <<EOF
{
   "body" : #set($inputRoot = $input.path('$'))
{
"operation": "create",
"payload": {
    "Item" : 
    {
        "userid" : "$context.authorizer.principalId",
        "noteid" : "$inputRoot.noteid",
        "note" : "$inputRoot.note"
        }
},
"tableName" : "Notes"
}
}
EOF
}
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.banter_api.id}"
  resource_id = "${aws_api_gateway_resource.notes_resource.id}"
  http_method = "${aws_api_gateway_method.notes_post_method.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"

  # Transforms the backend JSON response to XML
  response_templates {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
  "message" : "Note created"
}
EOF
  }
}