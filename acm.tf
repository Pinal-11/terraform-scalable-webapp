# Request SSL Certificate via ACM
resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = "app.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Environment = var.environment
    Project     = var.Project_Name
  }

  lifecycle {
    create_before_destroy = true
  }
}
