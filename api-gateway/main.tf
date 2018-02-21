# Variables
variable "myregion" {
    default = "us-east-1"
}
variable "accountId" {
    default = "928275755985"
}

# API Gateway
resource "aws_api_gateway_rest_api" "banter_api" {
  name = "BanterDev Api Gateway 1"
  description = "Description for gateway 1"
}

resource "aws_api_gateway_resource" "notes_resource" {
  path_part = "notes"
  parent_id = "${aws_api_gateway_rest_api.banter_api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.banter_api.id}"
}

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

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.banter_api.id}"
  resource_id = "${aws_api_gateway_resource.notes_resource.id}"
  http_method = "${aws_api_gateway_method.notes_post_method.http_method}"
  status_code = "200"
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


resource "aws_lambda_function" "get_note_lambda" {
    filename = "get_note_lambda.zip"
    function_name = "get_note_lambda_tf"
    role = "${aws_iam_role.get_note_lambda_role.arn}"
    handler = "lambda.lambda_handler"
    runtime = "nodejs4.3"
    source_code_hash = "${base64sha256(file("get_note_lambda.zip"))}"

}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get_note_lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.banter_api.id}/*/${aws_api_gateway_method.notes_post_method.http_method}${aws_api_gateway_resource.notes_resource.path}"
}

# IAM
resource "aws_iam_role" "get_note_lambda_role" {
  name = "myrole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "get_note_lambda_invocation_policy" {
  name = "default"
  role = "${aws_iam_role.get_note_lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }
  ]
}
EOF
}


resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = "${aws_iam_role.invocation_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "arn:aws:lambda:us-east-1:928275755985:function:cup_authorizer"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }
  ]
}
EOF
}

resource "aws_api_gateway_authorizer" "demo_auth" {
  name                   = "demo_auth"
  rest_api_id            = "${aws_api_gateway_rest_api.banter_api.id}"
  authorizer_uri         = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:928275755985:function:cup_authorizer/invocations"
  authorizer_credentials = "${aws_iam_role.invocation_role.arn}"
}