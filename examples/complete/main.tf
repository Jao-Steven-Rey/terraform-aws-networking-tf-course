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
    # Public subnets are indicated by having its public attribute set to true.
    subnet_2 = {
      cidr   = "10.0.1.0/24"
      azs    = "ap-southeast-1b"
      public = true
    }
  }
}