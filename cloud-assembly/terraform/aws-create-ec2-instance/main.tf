/*
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}
*/

# Configure the AWS Provider
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  version = "~> 3.0"
  region  = "us-west-2"
}

resource "aws_instance" "this" {
  ami           = "ami-00e395aae50e633c7"
  instance_type = "t2.micro"
}

/*
resource "vra_deployment" "this" {
  name        = var.deployment_name
  description = var.deployment_description

  blueprint_id      = var.blueprint_id
  blueprint_version = var.blueprint_version
  project_id        = var.project_id

  inputs = {
    image = var.image
    size = var.size
    username = var.username
    password = var.password
    workloadType = var.workloadtype
  }

  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
  }
}
*/
