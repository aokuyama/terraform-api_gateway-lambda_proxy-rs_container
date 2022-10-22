variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}
variable "region" {
  type    = string
  default = "ap-northeast-1"
}
variable "function_name" {
  type    = string
  default = "api_lambda_proxy"
}
variable "project_name" {
  type    = string
  default = "api_lambda_proxy"
}
variable "api_name" {
  type    = string
  default = "api_lambda_proxy"
}
variable "docker_file" {
  type    = string
  default = "docker/lambda/Dockerfile"
}
variable "tag_deploy" {
  type    = string
  default = "deploy"
}
variable "branch-name_deploy" {
  type    = string
  default = "deploy"
}
variable "uri_repository" {
  type    = string
  default = "https://example.com/example/example.git"
}
variable "app_dir" {
  type    = string
  default = "."
}
variable "dev_zone_name" {
  type    = string
  default = "example.com"
}
variable "dev_api_domain" {
  type    = string
  default = "example.com"
}
variable "dev_cert_arn" {
  type = string
}
variable "jwk_url" {
  type    = string
  default = "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
}
variable "jwk_issuer" {
  type = string
}
variable "access_control_allow_origin" {
  type    = string
  default = "*"
}
