# A Security Group for the ALB (allowing inbound HTTP/HTTPS)
# A Security Group for EC2 (allowing traffic from ALB only)
# The Application Load Balancer
# Target Group + Listener to forward traffic to EC2 instances

# ALB

resource "aws_lb" "tf_ALB" {
  name               = "${var.Project_Name}-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf_ALB-sg.id]
  subnets            = aws_subnet.tf_Public_Subnet[*].id

  enable_deletion_protection = true

  tags = {
    Environment = "${var.Project_Name}-alb"
  }

  access_logs {
    bucket = aws_s3_bucket.tf-static_assets.bucket
    enabled = true
    prefix = "ALB-Logs"
  }
}

# ALB Target Group
resource "aws_lb_target_group" "tf_Target_Group" {
  name     = "${var.Project_Name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf_main.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = 200
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.Project_Name}-TG"
  }
}

# Target Group listener
resource "aws_lb_listener" "tf_ALB_listener" {
  load_balancer_arn = aws_lb.tf_ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_Target_Group.arn
  }
  
  
} 

# Security Group for ALB
resource "aws_security_group" "tf_ALB-sg" {
    name        = "${var.Project_Name}-ALB-SG"
    description = "Allow HTTP access"
    vpc_id      = aws_vpc.tf_main.id

    tags = {
        Name = "${var.Project_Name}-ALB-SG"
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = [ "0.0.0.0/0" ]
    }

}


# Security Group for EC2
resource "aws_security_group" "tf_ec2_sg" {
    name        = "${var.Project_Name}-EC2-SG"
    description = "Allow Traffic from ALB only"
    vpc_id      = aws_vpc.tf_main.id

    tags = {
        Name = "${var.Project_Name}-EC2-SG"
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [ aws_security_group.tf_ALB-sg.id ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        security_groups = [ aws_security_group.tf_ALB-sg.id ]
    }

}

# Add HTTPS Support Using ACM & ALB Listener
# configure:
    # A public ACM certificate
    # Modify the ALB listener to include HTTPS (443)
    # Add HTTP to HTTPS redirection (optional, but good practice)


#  Add HTTPS Listener to ALB

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.tf_ALB.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.ssl_cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_Target_Group.arn
  }
}

# (Optional) Redirect HTTP to HTTPS

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.tf_ALB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
