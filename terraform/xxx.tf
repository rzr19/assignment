provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.name}_vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.name}_subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}_gw"
  }
}

resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.name}_rt"
  }
}

resource "aws_key_pair" "xxxkey" {
  key_name   = "xxxkey"
  public_key = file("key.pub")
}

resource "aws_security_group" "xxxsg" {
  name        = "${var.name}_sg"
  description = "fw"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name}_sg"
  }
}

data "aws_ami" "xxxami" {
  owners      = ["self"]
  most_recent = true
  name_regex  = "^xxxami.*"
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "xxx" {
  key_name      = aws_key_pair.xxxkey.key_name
  ami           = data.aws_ami.xxxami.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet.id
  user_data     = file("cloud_init.sh")
  tags = {
    Name = "TestXXX"
  }
  vpc_security_group_ids = [
    aws_security_group.xxxsg.id
  ]
  provisioner "remote-exec" {
    inline = [
       "sudo cloud-init status --wait"
  ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("key")
      host        = self.public_ip
    }
  }
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 20
  }
}

resource "aws_eip" "eip" {
  vpc      = true
  instance = aws_instance.xxx.id
}
