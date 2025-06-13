output "vpc_id" {
  description = "Outputs our VPC's ID."
  value = aws_vpc.module_vpc.id
}

output "public_subnets" {
  description = "Outputs our public subnets' CIDR block, ID, and availability zone."
  value = local.output_public_subnets
}

output "private_subnets" {
  description = "Outputs our private subnets' CIDR block, ID, and availability zone."
  value = local.output_private_subnets
}

# output "visualizer" {
#   description = "Used to visualize variables I do not understand so feel free to change the value or comment out this block."
#   value       = { for name, publicity in var.subnet_config : name => publicity.public }
# }