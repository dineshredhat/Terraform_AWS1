resource "aws_security_group" "web" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."

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

    vpc_id = aws_vpc.my_vpc.id

}

resource "aws_instance" "web-1" {
    ami = "ami-02fe94dee086c0c37"
    availability_zone = "us-east-1a" #we have to change region
    instance_type = "t2.micro"
    key_name = "Test"
    vpc_security_group_ids = [aws_security_group.web.id]
    subnet_id = aws_subnet.public.id
    associate_public_ip_address = true
    source_dest_check = false
    depends_on = [aws_instance.database]

    tags = {
      Name = "WebServer"
    }

}
