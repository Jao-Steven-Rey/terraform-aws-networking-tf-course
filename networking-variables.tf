variable "vpc_info" {
  type = object({
    cidr = string
    name = string
  })

  validation {
    condition     = can(cidrnetmask(var.vpc_info.cidr))
    error_message = "Invalid VPC CIDR block. It must look something like this: '10.0.0.0/16'."
  }
}

variable "subnet_config" {
  type = map(object({
    cidr   = string
    azs    = string
    public = optional(bool, false) # Subnets are  private by default.
  }))

  validation {
    condition     = alltrue([for cidr in values(var.subnet_config) : can(cidrnetmask(cidr.cidr))])
    error_message = "At least one subnet CIDR block is invalid. It must look something like this: '10.0.0.0/24'."
  }
}