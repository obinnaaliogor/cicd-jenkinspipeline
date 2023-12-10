data "aws_ami" "ami" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "name"
    values = ["packer-with-jenkins-script-ami"]
  }
}

output "ami_id" {
  value = data.aws_ami.ami.id
}

# ami-0eb5cbeafda02c2e5
resource "aws_instance" "jenkins-server" {
  ami = data.aws_ami.ami.id
  instance_type = "t2.medium"
  key_name = "k8s"

  lifecycle {
    ignore_changes = [ ami ]
  }

  tags = {
    "Name"        = "Jenkins Server",
    "Environment" = "Production",
    "Application" = "MyApp"
    # Add any other tags as needed
  }
}

provider "aws" {
  region = "us-east-1"
}