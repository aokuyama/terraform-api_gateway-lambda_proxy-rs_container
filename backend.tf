terraform {
  required_version = "~> 1.0.0"
}
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
data "aws_caller_identity" "self" {}
data "template_file" "buildspec" {
  template = file("./buildspec.yml")

  vars = {
    region             = var.region
    app_dir            = var.app_dir
    build_tag          = "rust-build-release"
    tag                = "${aws_ecr_repository.app.name}:${var.tag_deploy}"
    repository_tag     = "${aws_ecr_repository.app.repository_url}:${var.tag_deploy}"
    docker_path_deploy = "./deploy/lambda/Dockerfile"
    docker_path_build  = "./deploy/lambda/build.dockerfile"
  }
}
module "dev" {
  source                      = "./app"
  region                      = var.region
  function_name               = "${var.function_name}-dev"
  function_image              = "${aws_ecr_repository.app.repository_url}:${var.tag_deploy}"
  api_name                    = "${var.api_name}-dev"
  zone_name                   = var.dev_zone_name
  api_domain                  = var.dev_api_domain
  cert_arn                    = var.dev_cert_arn
  jwk_url                     = var.jwk_url
  jwk_issuer                  = var.jwk_issuer
  access_control_allow_origin = var.access_control_allow_origin
}
