# terraform-aws-networking-tf-course
Networking module performed under Lauro Müeller's course about Terraform.

This module manages the creation of VPCs and subnets, and whether the subnets are public or private.

Sample Usage:
```
module "networking" {
  source = "./modules/networking"

  vpc_info = {
    cidr = "10.0.0.0/16"
    name = "13-local-modules"
  }

  subnet_config = {
    subnet_1 = {
      cidr = "10.0.0.0/24"
      azs  = "ap-southeast-1a"
    }
    subnet_2 = {
      cidr   = "10.0.1.0/24"
      azs    = "ap-southeast-1b"
      public = true
    }
  }
}
```