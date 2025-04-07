# Add an RDS Database (Using MySQL in Private Subnets)

# RDS Subnet Group – Uses the private subnets.
resource "aws_db_subnet_group" "tf_RDS_Sgroup" {
  name       = "${var.Project_Name}-RDS-DG"
  subnet_ids = aws_subnet.tf_Private_Subnet[*].id

  tags = {
    Name = "${var.Project_Name}-RDS-SG"
  }
}

# RDS Security Group – Allows inbound MySQL (port 3306) traffic from your application instances.
resource "aws_security_group" "tf_rds_sg" {
  name        = "${var.Project_Name}-rds-SG"
  description = "Allow MySQL access from app instances"
  vpc_id      = aws_vpc.tf_main.id

  tags = {
    Name = "${var.Project_Name}-rds-SG"
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.tf_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# RDS Instance using MySQL
resource "aws_db_instance" "tf_RDS" {
  identifier             = "${var.Project_Name}-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  storage_type           = "gp2"
  db_name                = "mydb"
  username               = "Admin"
  password               = "Admin123"
  vpc_security_group_ids = [aws_security_group.tf_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.tf_RDS_Sgroup.name
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false

  tags = {
    Name = "${var.Project_Name}-RDS"
  }

  monitoring_interval = 60 # seconds
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn

}

resource "aws_iam_role" "rds_monitoring_role" {
  name = "${var.Project_Name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_attach" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

