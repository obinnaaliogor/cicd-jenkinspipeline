packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon-linux" {
  ami_name      = "packer-with-jenkins-script-ami"
  instance_type = "t2.micro"
  region        = "us-east-1"

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"

  tags = {
    "Name"        = "Jenkins Server",
    "Environment" = "Production",
    "Application" = "MyApp"
    # Add any other tags as needed
  }
}

build {
  name    = "jenkins-packer"
  sources = ["source.amazon-ebs.amazon-linux"]
  provisioner "shell" {
    script = "./jenkins-script.sh"
  }
}
