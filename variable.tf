variable "Project_Name" {
  type    = string
  default = "WebApp"
}

variable "aws_region" {
  type        = string
  description = "Provide the region name"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "Provide the VPC cide Range"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "Public Subnet cidr Range"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "Private_subnet_cidr" {
  type        = list(string)
  description = "Private Subnet cidr range"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "availability zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "environment" {
  type    = string
  default = "Dev"
}

variable "db_password" {
  description = "MySQL root/admin password"
  type        = string
  sensitive   = true
}

variable "domain_name" {
    type = string
    default = "domainname.com"
}