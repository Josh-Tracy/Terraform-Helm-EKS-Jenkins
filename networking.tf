resource "aws_vpc" "dev-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "development"
  }
}

# Subnets have to be allowed to automatically map public IP addresses for worker nodes
resource "aws_subnet" "dev1-subnet" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = var.dev1_subnet_cidr_block
  availability_zone       = var.dev1_subnet_az
  map_public_ip_on_launch = true

  tags = {
    Name = "dev1-subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"             = "1"
  }
}

resource "aws_subnet" "dev2-subnet" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = var.dev2_subnet_cidr_block
  availability_zone       = var.dev2_subnet_az
  map_public_ip_on_launch = true

  tags = {
    Name = "dev2-subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"             = "1"
  }
}

resource "aws_internet_gateway" "dev-gw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-gw"
  }
}

resource "aws_route_table" "dev-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.dev-gw.id
  }


  tags = {
    Name = "dev-rt"
  }
}

resource "aws_route_table_association" "dev1-sub-to-dev-rt" {
  subnet_id      = aws_subnet.dev1-subnet.id
  route_table_id = aws_route_table.dev-route-table.id
}

resource "aws_route_table_association" "dev2-sub-to-dev-rt" {
  subnet_id      = aws_subnet.dev2-subnet.id
  route_table_id = aws_route_table.dev-route-table.id
}

resource "aws_security_group" "allow-web-traffic" {
  name        = "allow_tls"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #     description      = "SSH"
  #     from_port        = 22
  #     to_port          = 22
  #     protocol         = "tcp"
  #     cidr_blocks      = ["0.0.0.0/0"]
  #   }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-web"
  }
}

resource "aws_network_interface" "dev-server-nic" {
  subnet_id       = aws_subnet.dev1-subnet.id
  private_ips     = var.dev1_subnet_nic_private_ip
  security_groups = [aws_security_group.allow-web-traffic.id]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.dev-server-nic.id
  associate_with_private_ip = aws_network_interface.dev-server-nic.private_ip
  depends_on                = [aws_internet_gateway.dev-gw]
}
