resource "aws_security_group" "db" {
    name = "vpc_db"
    description = "Allow incoming database connection."

    ingress {
        from_port = 1433
        to_port = 1433
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
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
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = aws_vpc.my_vpc.id
}

resource "aws_db_subnet_group" "database" {
    subnet_ids = [aws_subnet.nated.id, aws_subnet.private2.id]  
}

resource "aws_instance" "database"{
  ami = "ami-02fe94dee086c0c37"
  availability_zone = "us-east-1a"
  instance_type = "t2.micro"
  key_name = "Test"
  tags = {
      Name = "Database server"
    }
  vpc_security_group_ids = [aws_security_group.db.id]
  subnet_id = aws_subnet.nated.id
  source_dest_check = false
}

resource "aws_db_instance" "db"{
   allocated_storage    = 20
   storage_type         = "gp2"
   engine               = "mysql"
   engine_version       = "5.7"
   instance_class       = "db.t2.micro"
   port                 = 3306
   name                 = "mydb"
   username             = "admin"
   password             = "alexy123"
   parameter_group_name = "default.mysql5.7"
   skip_final_snapshot  = "true"
   tags = {
      Name = "Mysql"
    }
    vpc_security_group_ids = [aws_security_group.db.id]
    db_subnet_group_name = aws_db_subnet_group.database.name
}

output "database_endpoint" {
  value = aws_db_instance.db.endpoint
}
Footer
© 2022 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
S
