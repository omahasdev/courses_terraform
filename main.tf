provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-*-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "terraform_security" {
  name = "Jenkins Security Group"
  description = "terraform security group"

  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "private-aws-demo"

  vpc_security_group_ids = [ aws_security_group.terraform_security.id ]

  tags = {
    Name = "Jenkins Server"
    Application = "jenkins"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/private-aws-demo.pem")
    host = self.public_ip
  }

  # install java

  provisioner "file" {    
    source = "scripts/install-java8.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
      "rm /tmp/setup.sh",
    ]
  }

  # install docker

  provisioner "file" {
    source = "scripts/install-docker.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
      "rm /tmp/setup.sh",
    ]
  }

  # install jenkins

  provisioner "file" {
    source = "scripts/install-jenkins.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
      "rm /tmp/setup.sh",
    ]
  }

  # configure jenkins with docker

  provisioner "file" {
    source = "scripts/configure-jenkins-docker.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
      "rm /tmp/setup.sh",
    ]
  }

}
