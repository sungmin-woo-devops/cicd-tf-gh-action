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

resource "aws_subnet" "MyPubSN_2" {
  vpc_id = aws_vpc.MyVPC.id
  cidr_block = var.pub_subnet_cidr_blocks[1]
  availability_zone = var.azs[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "MyPubSN_2"
  }
}

resource "aws_subnet" "MyPrivSN_APP_1" {
  vpc_id = aws_vpc.MyVPC.id
  cidr_block = var.priv_subnet_cidr_blocks[0]
  availability_zone = var.azs[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "MyPrivSN_1"
  }
}

resource "aws_subnet" "MyPrivSN_APP_2" {
  vpc_id = aws_vpc.MyVPC.id
  cidr_block = var.priv_subnet_cidr_blocks[1]
  availability_zone = var.azs[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "MyPrivSN_2"
  }
}

resource "aws_subnet" "MyPrivSN_DB_1" {
  vpc_id = aws_vpc.MyVPC.id
  cidr_block = var.priv_subnet_cidr_blocks[2]
  availability_zone = var.azs[2]
  map_public_ip_on_launch = false
}

resource "aws_subnet" "MyPrivSN_DB_2" {
  vpc_id = aws_vpc.MyVPC.id
  cidr_block = var.priv_subnet_cidr_blocks[3]
  availability_zone = var.azs[3]
  map_public_ip_on_launch = false
}

resource "aws_route_table" "MyPubRT" {
  vpc_id = aws_vpc.MyVPC.id

  tags = {
    Name = "MyPubRT"
  }
}

resource "aws_route_table" "MyPrivRT" {
  vpc_id = aws_vpc.MyVPC.id

  tags = {
    Name = "MyPrivRT"
  }
}

resource "aws_eip" "lb" {
  domain   = "vpc"

  tags = {
    Name = "MyNAT_EIP"
  }
}

resource "aws_nat_gateway" "MyNAT" {
  allocation_id = aws_eip.lb.id
  subnet_id = aws_subnet.MyPubSN_1.id

  tags = {
    Name = "MyNAT"
  }

  depends_on = [aws_internet_gateway.MyIGW]
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

data "aws_ami" "amazon_linux_2023" {
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
  ami           = data.aws_ami.amazon_linux_2023.id
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
