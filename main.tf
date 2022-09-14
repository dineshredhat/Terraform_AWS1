terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 3.0"
    }
  }
}
provider "aws" {
region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "My VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My VPC - Internet Gateway"
  }
}

resource "aws_route_table" "my_vpc_us_east_1a_public" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }

    tags = {
        Name = "Public Subnet Route Table."
    }
}

resource "aws_route_table_association" "my_vpc_us_east_1a_public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.my_vpc_us_east_1a_public.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_sg"
  description = "Allow SSH inbound connections"
  vpc_id = aws_vpc.my_vpc.id

   ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 1433
        to_port = 1433
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress { 
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
  tags = {
    Name = "allow_ssh_sg"
  }
}

resource "aws_subnet" "nated" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "NAT-ed Subnet"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_eip" "nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_route_table" "my_vpc_us_east_1a_nated" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.gw.id
    }

    tags = {
        Name = "Main Route Table for NAT-ed subnet"
    }
}

resource "aws_route_table_association" "my_vpc_us_east_1a_nated" {
    subnet_id = aws_subnet.nated.id
    route_table_id = aws_route_table.my_vpc_us_east_1a_nated.id
}

resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = aws_vpc.my_vpc.id

    ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "Bastion_pro"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCw+9XBWbkRcMZUYPWpVxup/ypnlxQo+o3xMQ0P610EsPMBFyT7xo6yXy+qoKvKD+EXEYKhO5t/pBUupdcS9jXn5248b7JMpJsU//my0cYSnvnA3rOI41MC5yCJOPj8WEG2vV1KfHlS6RpY3eEH00urSWZqbetsvqdKL5Yrj6W3BxPvmHaKbXKzk0wEMLJIJA587xdU8Wl6utMtvvPJbzVwOHDS6MG1vkO3i3jr9sDOVx2DpiRH/3YhTEeVompxlt8SIwzQ50/wekNkxERI94nylbqSut/XeyKO2PZIBOUa73YK3uBaOY8nIY1SWAckCJudM+dJ5k7yFD9XbRTXvpbQSHO6yQj/bjpH0P8DIb7Fj+C5rLPdMXadfvg797dPVFQyvGtGDY8VfAmSRZoYmtigc4VubGWutK84bIlV4I1iWeTZ2qu3fPBGmmJnPMiXIR1ZGvVVHiT8xf+jX5g1B1Wsw8T8caVgwbk2NvMq8lcA9ecwhjTH8yw/yI6SvwLXs80== Techino@Techino"
  }  

resource "aws_instance" "my_instance" {
  ami           = "ami-02fe94dee086c0c37"
  instance_type = "t2.micro"
  key_name = "Test"
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true

  tags = {
    Name = "My Instance"
  }
}
