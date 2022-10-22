resource "aws_api_gateway_rest_api" "app" {
  name = var.api_name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  disable_execute_api_endpoint = true
}
resource "aws_api_gateway_deployment" "app" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  depends_on = [
    aws_api_gateway_integration.root_any,
    aws_api_gateway_integration.proxy_any,
    aws_api_gateway_integration.proxy_options,
    aws_api_gateway_integration.root_options,
  ]
  stage_description = "setting file hash = ${md5(file("./app/api.tf"))}${md5(file("./app/api_root.tf"))}${md5(file("./app/api_proxy.tf"))}"
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "v1" {
  stage_name    = "v1"
  rest_api_id   = aws_api_gateway_rest_api.app.id
  deployment_id = aws_api_gateway_deployment.app.id
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
resource "aws_lambda_permission" "app" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.app.execution_arn}/*/*/*"
}
