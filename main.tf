# 이전에 작업이 되었던 CI-CD 구현을 IaC(Terraform) 도구를 사용하여 코드화한다.
provider "aws" {
  region = var.region
}

resource "aws_vpc" "MyVPC" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "smallpod-vpc"
  }
}

resource "aws_internet_gateway" "MyIGW" {
  vpc_id = aws_vpc.MyVPC.id

  tags = {
    Name = "MyIGW"
  }
}

resource "aws_subnet" "MyPubSN_1" {
  vpc_id = aws_vpc.MyVPC.id
  cidr_block = var.pub_subnet_cidr_blocks[0]
  availability_zone = var.azs[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "MyPubSN_1"
  }
}

resource "aws_route_table" "MyPubRT" {
  vpc_id = aws_vpc.MyVPC.id
}

resource "aws_route_table_association" "MyPubRTAssoc" {
  subnet_id = aws_subnet.MyPubSN_1.id
  route_table_id = aws_route_table.MyPubRT.id
}

resource "aws_security_group" "MySG_22_80" {
  name        = "MySG_22_80"
  description = "Allow 22, 80 inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.MyVPC.id

  tags = {
    Name = "MySG_22_80"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_22" {
  security_group_id = aws_security_group.MySG_22_80.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_80" {
  security_group_id = aws_security_group.MySG_22_80.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.MySG_22_80.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_ami" "example" {
  most_recent      = true
  owners           = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

resource "aws_key_pair" "MyKeyPair" {
  key_name = "MyKeyPair"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "MyPubEC2_1" {
  ami           = data.aws_ami.example.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.MyPubSN_1.id
  vpc_security_group_ids = [aws_security_group.MySG_22_80.id]
  key_name = aws_key_pair.MyKeyPair.key_name

  user_data_replace_on_change = true
  user_data = <<-EOF
  #!/bin/bash
  sudo yum install -y httpd
  echo "<h1>Hello, World!</h1>" | sudo tee /var/www/html/index.html
  sudo systemctl enable --now httpd
  sudo systemctl start httpd
  EOF

  tags = {
    Name = "MyPubEC2_1"
  }
}
