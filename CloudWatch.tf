# Enable Monitoring & Logging with CloudWatch
# This is where you gain observability into your infrastructure — super helpful for debugging, performance monitoring, and alerting.

# EC2 instance-level logging to CloudWatch

resource "aws_iam_role" "ec2_cw_agent_role" {
  name = "${var.Project_Name}-cw-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_agent_attach" {
  role       = aws_iam_role.ec2_cw_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_cw_profile" {
  name = "${var.Project_Name}-cw-agent-profile"
  role = aws_iam_role.ec2_cw_agent_role.name
}

