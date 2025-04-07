

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Attach this IAM policy to the EC2 instance role:
resource "aws_iam_policy" "read_db_secret" {
  name = "${var.Project_Name}-read-db-secret"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "secretsmanager:GetSecretValue"
        ],
        Resource: aws_secretsmanager_secret.db_credentials.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_read_secret" {
  role       = aws_iam_role.ec2_cw_agent_role.name
  policy_arn = aws_iam_policy.read_db_secret.arn
}

# Launch Template (EC2 config: AMI, instance type, SG)
resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.Project_Name}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.tf_ec2_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.Project_Name}-ec2"
    }
  }
}

# ASG
resource "aws_autoscaling_group" "tf-ASG" {
  name = "${var.Project_Name}-ASG"

  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = aws_subnet.tf_Private_Subnet[*].id

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"

  }

  tag {
    key                 = "Name"
    value               = "${var.Project_Name}-ec2"
    propagate_at_launch = true
  }

}
