provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "userdatabase-vpc"
  }
}

resource "aws_subnet" "subnet_id_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"
}

resource "aws_subnet" "subnet_id_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_2
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "aws_route_table_association_1" {
  subnet_id      = aws_subnet.subnet_id_1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "aws_route_table_association_2" {
  subnet_id      = aws_subnet.subnet_id_2.id
  route_table_id = aws_route_table.rt.id
}

# === Security Groups ===

# App Security Group
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow app traffic and DB access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.main.cidr_block]
  }
}

# MongoDB Security Group
resource "aws_security_group" "mongo_db_sg" {
  name        = "mongo-db-sg"
  description = "Allow MongoDB access from app and mongo-express"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [
      aws_security_group.app_sg.id,
      aws_security_group.mongo_express_sg.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Mongo Express Security Group
resource "aws_security_group" "mongo_express_sg" {
  name        = "mongo-express-sg"
  description = "Allow HTTP access and DB egress"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

# Application Load Balancer SG
resource "aws_security_group" "app_lb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Allow NFS traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [aws_security_group.mongo_db_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
