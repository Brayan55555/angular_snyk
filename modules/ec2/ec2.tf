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
      private_key = file("/home/brayan/Jhooq/Keys/aws/aws_key")
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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCniI3qeHykvDXyTMx6qqfF6bKkXAVRKL1aVQasZ/YUgLCAfv9olF5lq/ySQ8a91qZPhEGg1UiP7cnLHbbOEUVEW5+jYnaG/yKMiw6BwkyBCYbdf8CyRQ1Miaclu0BLtyu4P7lA+XII8GfJvm5Vjt46tpMzTPlxz5Ag9S7DAe/0Grt3NibxF2wYxP8rK64bavHMgy5BadXixJn81WsEH2vzsETMVx3s0xiAFS1+VFntFkVoR7jYf6JIRJW176LhFljmVaZpBhHdjgI0cYRe8Z9JUtl/UzjFU4UJHmqM6llgNAFVkuJqyZv9SI/hW3Ecy5gVgfysJEEAc+ovTFfwISWV brayan@DESKTOP-PMTFEG8"
}

output "public_ip" {
  value       = aws_instance.ec2_example.public_ip
}