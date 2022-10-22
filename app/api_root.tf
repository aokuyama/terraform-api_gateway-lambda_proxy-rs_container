resource "aws_api_gateway_method" "root_any" {
  authorization    = "NONE"
  http_method      = "ANY"
  resource_id      = aws_api_gateway_rest_api.app.root_resource_id
  rest_api_id      = aws_api_gateway_rest_api.app.id
  api_key_required = true
}
resource "aws_api_gateway_method_response" "root_any-200" {
  rest_api_id         = aws_api_gateway_rest_api.app.id
  resource_id         = aws_api_gateway_rest_api.app.root_resource_id
  http_method         = aws_api_gateway_method.root_any.http_method
  status_code         = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
resource "aws_api_gateway_integration" "root_any" {
  http_method             = aws_api_gateway_method.root_any.http_method
  resource_id             = aws_api_gateway_rest_api.app.root_resource_id
  rest_api_id             = aws_api_gateway_rest_api.app.id
  type                    = "AWS_PROXY"
  cache_namespace         = aws_api_gateway_rest_api.app.root_resource_id
  integration_http_method = aws_api_gateway_method.root_any.http_method
  uri                     = aws_lambda_function.app.invoke_arn
}

resource "aws_api_gateway_method" "root_options" {
  rest_api_id   = aws_api_gateway_rest_api.app.id
  resource_id   = aws_api_gateway_rest_api.app.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "root_options-200" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  resource_id = aws_api_gateway_rest_api.app.root_resource_id
  http_method = aws_api_gateway_method.root_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_integration_response" "root_options" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  resource_id = aws_api_gateway_rest_api.app.root_resource_id
  http_method = aws_api_gateway_method.root_options.http_method
  status_code = aws_api_gateway_method_response.root_options-200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "${var.access_control_allow_origin == "*" ? "'*'" : var.access_control_allow_origin}"
  }
}
resource "aws_api_gateway_integration" "root_options" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  resource_id = aws_api_gateway_rest_api.app.root_resource_id
  http_method = aws_api_gateway_method.root_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}
