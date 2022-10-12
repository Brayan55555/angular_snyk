data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2_example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "aws_key"
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "web-server"
  }
  provisioner "remote-exec" {
    script = "./bar.sh"
  }
  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("/home/brayan/Jhooq/keys/aws/aws_key")
      timeout     = "4m"
   }
}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 0
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "-1"
     security_groups  = []
     self             = false
     to_port          = 0
  }
  ]
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI97mrEfZjs+ZgLk9IFm7g4LZWWD1l6qPxVSz5YxwYo+qljiSsCinsOOhV4zlhKmt0+13Wei8YtIHVkEA1HF3t2V9qy6kVQFX0QKF09JqPC2wfRdfqVWEukEHbCrj4wwU42mVBna873OhuEMS5qUU+V0XSKEcvmv3plCx9qvpEHOCKMWZ3x5bsZK/0dpzha7X56QOAlU1xQc9ZDVjJsAOXMQmKmrIWvWVEk3SVtnxY7Esvg98WtL14nx4vYzF3T9L6pmngqCdiFJD4cLU9yYXUJ1X7N3jLUMeEcyAEac6kiMBuV/N7hv3h3QntWkkjoOmeUwjjlFUUcYun0mAUXw2z brayan@LAPTOP-9JKE2OM"
}

output "public_ip" {
  value       = aws_instance.ec2_example.public_ip
}