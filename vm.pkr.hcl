# Base AMI is amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-gp2
variable "ami_id" {
  type    = string
  default = "ami-0cff7528ff583bf9a"
}

locals {
    app_name = "kops-kubectl"
}

source "amazon-ebs" "kops" {
  ami_name      = "${local.app_name}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami    = "${var.ami_id}"
  ssh_username  = "ec2-user"
  tags = {
    Env  = "DEV"
    Name = "${local.app_name}"
  }
}

build {
  sources = ["source.amazon-ebs.kops"]

  provisioner "shell" {
    script = "scripts/script.sh"
  }

  post-processor "shell-local" {
    inline = ["echo foo"]
  }
}