# Store DB Credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.Project_Name}/db_credentials"
  description = "MySQL credentials for ${var.Project_Name}"

  tags = {
    Environment = var.environment
    Project     = var.Project_Name
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = var.db_password  # Replace with a strong secret or Terraform var
  })
}
