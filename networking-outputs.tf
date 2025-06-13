output "vpc_id" {
  value = aws_vpc.module_vpc.id
}

output "public_subnets" {
  value = local.output_public_subnets
}

output "private_subnets" {
  value = local.output_private_subnets
}

# output "visualizer" {
#   description = "Used to visualize variables I do not understand so feel free to change the value or comment out this block."
#   value       = { for name, publicity in var.subnet_config : name => publicity.public }
# }