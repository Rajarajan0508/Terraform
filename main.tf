provider "aws" {
    region = "ap-south-1"
}

resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_instance" "first_instance" {
    ami = "ami-0b2ec65899cc867ef"
    instance_type = "m5.large"
    subnet_id = aws_subnet.subnet1.id
    vpc_security_group_ids = [aws_security_group.my_sg1.id]
    
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c echo my very first web server > /var/www/html/index.html'
                EOF

  tags = {
    Name = "my-web-server"
  }
}

resource "aws_security_group" "my_sg1" {
  vpc_id = aws_vpc.my-vpc.id

  name = "Allow-HTTP"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "public-Subnet"
    }
}

resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id 

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "subnet1" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "subnet2" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.subnet1.id
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.subnet2.id
}

