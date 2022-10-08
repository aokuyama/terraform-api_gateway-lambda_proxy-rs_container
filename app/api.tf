resource "aws_api_gateway_rest_api" "app" {
  name = var.api_name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  disable_execute_api_endpoint = true
}
resource "aws_api_gateway_method" "root_any" {
  authorization    = "NONE"
  http_method      = "ANY"
  resource_id      = aws_api_gateway_rest_api.app.root_resource_id
  rest_api_id      = aws_api_gateway_rest_api.app.id
  api_key_required = true
}
resource "aws_api_gateway_method_response" "root_any-200" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  resource_id = aws_api_gateway_rest_api.app.root_resource_id
  http_method = aws_api_gateway_method.root_any.http_method
  status_code = "200"
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
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  parent_id   = aws_api_gateway_rest_api.app.root_resource_id
  path_part   = "{proxy+}"
}
resource "aws_api_gateway_method" "proxy_any" {
  authorization    = "NONE"
  http_method      = "ANY"
  resource_id      = aws_api_gateway_resource.proxy.id
  rest_api_id      = aws_api_gateway_rest_api.app.id
  api_key_required = true
}
resource "aws_api_gateway_method_response" "proxy_any-200" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy_any.http_method
  status_code = "200"
}
resource "aws_api_gateway_integration" "proxy_any" {
  http_method             = aws_api_gateway_method.proxy_any.http_method
  resource_id             = aws_api_gateway_resource.proxy.id
  rest_api_id             = aws_api_gateway_rest_api.app.id
  type                    = "AWS_PROXY"
  cache_namespace         = aws_api_gateway_resource.proxy.id
  integration_http_method = aws_api_gateway_method.proxy_any.http_method
  uri                     = aws_lambda_function.app.invoke_arn
}
resource "aws_api_gateway_method_settings" "app" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  stage_name  = aws_api_gateway_stage.v1.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}
resource "aws_api_gateway_deployment" "app" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  depends_on = [
    aws_api_gateway_integration.root_any,
    aws_api_gateway_integration.proxy_any,
  ]
  stage_description = "setting file hash = ${md5(file("./app/api.tf"))}"
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "v1" {
  stage_name    = "v1"
  rest_api_id   = aws_api_gateway_rest_api.app.id
  deployment_id = aws_api_gateway_deployment.app.id
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = "$context.integrationErrorMessage $context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}
resource "aws_api_gateway_usage_plan" "standard" {
  name = "standard"
  api_stages {
    api_id = aws_api_gateway_rest_api.app.id
    stage  = aws_api_gateway_stage.v1.stage_name
  }
}
resource "aws_api_gateway_usage_plan_key" "standard" {
  key_id        = aws_api_gateway_api_key.app.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.standard.id
}
resource "aws_api_gateway_api_key" "app" {
  name = var.api_name
}
resource "aws_cloudwatch_log_group" "api_gateway" {
  name = "/aws/apigateway/${var.api_name}"
}
resource "aws_lambda_permission" "app" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.app.execution_arn}/*/*/*"
}
