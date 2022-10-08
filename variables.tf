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
variable "zone_name" {
  type    = string
  default = "example.com"
}
variable "api_domain" {
  type    = string
  default = "example.com"
}
variable "cert_arn" {
  type = string
}
