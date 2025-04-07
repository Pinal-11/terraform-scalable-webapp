resource "aws_vpc" "tf_main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.Project_Name}-VPC"
  }
}

resource "aws_internet_gateway" "tf_gw" {
  vpc_id = aws_vpc.tf_main.id
}

resource "aws_subnet" "tf_Public_Subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.tf_main.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.Project_Name}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "tf_Private_Subnet" {
  count             = 2
  vpc_id            = aws_vpc.tf_main.id
  cidr_block        = var.Private_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  # map_public_ip_on_launch = false, By default id false so no need to mention this argument

  tags = {
    Name = "${var.Project_Name}-private-${count.index + 1}"
  }
}

# Provides an Elastic IP resource.
resource "aws_eip" "tf_nat" {
  count  = 1
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.tf_nat[0].id
  subnet_id     = aws_subnet.tf_Public_Subnet[0].id
}

resource "aws_route_table" "tf_route_table_public" {
  vpc_id = aws_vpc.tf_main.id
}

resource "aws_route" "tf_route_public" {
  route_table_id         = aws_route_table.tf_route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_gw.id
}

resource "aws_route_table_association" "tf_public_route_table" {
  count          = 2
  subnet_id      = aws_subnet.tf_Public_Subnet[count.index].id
  route_table_id = aws_route_table.tf_route_table_public[count.index].id
}

resource "aws_route_table" "tf_route_table_private" {
  vpc_id = aws_vpc.tf_main.id
}

resource "aws_route" "tf_route_private" {
  route_table_id         = aws_route_table.tf_route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_gw.id
}

resource "aws_route_table_association" "tf_private_route_table" {
  count          = 2
  subnet_id      = aws_subnet.tf_Private_Subnet[count.index].id
  route_table_id = aws_route.tf_route_private[count.index].id
}
