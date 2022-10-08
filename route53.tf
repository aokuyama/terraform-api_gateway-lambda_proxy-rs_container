resource "aws_route53_record" "api" {
  name    = var.api_domain
  type    = "A"
  zone_id = data.aws_route53_zone.selected.zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
  }
}
resource "aws_api_gateway_domain_name" "api" {
  domain_name              = var.api_domain
  regional_certificate_arn = var.cert_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.app.id
  stage_name  = aws_api_gateway_stage.v1.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
  base_path   = aws_api_gateway_stage.v1.stage_name
}
