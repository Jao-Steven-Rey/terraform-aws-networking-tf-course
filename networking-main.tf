locals {
  public_subnets  = { for name, publicity in var.subnet_config : name => publicity if publicity.public == true }
  private_subnets = { for name, publicity in var.subnet_config : name => publicity if publicity.public == false }

  output_public_subnets = {
    for subnet in keys(local.public_subnets) : subnet => {
      cidr_block        = aws_subnet.module_subnet[subnet].cidr_block
      subnet_id         = aws_subnet.module_subnet[subnet].id
      availability_zone = aws_subnet.module_subnet[subnet].availability_zone
    }
  }

  output_private_subnets = {
    for subnet in keys(local.private_subnets) : subnet => {
      cidr_block        = aws_subnet.module_subnet[subnet].cidr_block
      subnet_id         = aws_subnet.module_subnet[subnet].id
      availability_zone = aws_subnet.module_subnet[subnet].availability_zone
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "module_vpc" {
  cidr_block = var.vpc_info.cidr

  tags = {
    Name = var.vpc_info.name
  }
}

resource "aws_subnet" "module_subnet" {
  for_each          = var.subnet_config
  vpc_id            = aws_vpc.module_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.azs

  lifecycle {
    precondition {
      condition = contains(data.aws_availability_zones.available.names, each.value.azs)

      # This is how you write an error message with multiple lines.
      error_message = <<-EOT
      The AZ "${each.value.azs}" provided for the subnet "${each.key}" is invalid.

      The current AWS region "${data.aws_availability_zones.available.id}" supports the following AZs:
      [${join(", ", data.aws_availability_zones.available.names)}]
      EOT
    }
    # The provided invalid AZ                     : each.value.azs
    # The subnet name of the invalid AZ           : each.key
    # The current AWS region                      : data.aws_availability_zones.available.id
    # The available AZs for the current AWS region: data.aws_availability_zones.available.names
  }

  tags = {
    Name      = "module_${each.key}"
    Publicity = each.value.public == true ? "public" : "private"
  }
}

resource "aws_internet_gateway" "module_igw" {
  # If the number of public subnets is at least one, then create ONE igw else, create none.
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.module_vpc.id

  tags = {
    Name = "module_igw"
  }
}

resource "aws_route_table" "public_rtb" {
  # If the number of public subnets is at least one, then create ONE public rtb else, create none.
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.module_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.module_igw[0].id # If an igw WAS created, then associate with the first and only one.
  }

  tags = {
    Name = "public_rtb"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.module_subnet[each.key].id # Associates subnets marked as "public" based on name-
  route_table_id = aws_route_table.public_rtb[0].id      # -with THE public rtb.
}