resource "aws_lambda_function" "app" {
  function_name = var.function_name
  memory_size   = 128
  timeout       = 3
  image_uri     = var.function_image
  package_type  = "Image"
  role          = aws_iam_role.iam_for_lambda.arn
  environment {
    variables = {
      "JWK_URL"                     = var.jwk_url
      "JWK_ISSUER"                  = var.jwk_issuer
      "ACCESS_CONTROL_ALLOW_ORIGIN" = var.access_control_allow_origin
    }
  }
}
resource "aws_iam_role" "iam_for_lambda" {
  path = "/service-role/"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    aws_iam_policy.policy_for_lambda.arn,
  ]
}
resource "aws_iam_policy" "policy_for_lambda" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action   = "logs:CreateLogGroup"
          Effect   = "Allow"
          Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:*"
        },
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/lambda/${var.function_name}:*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}
