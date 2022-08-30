#Current output values:
#  - vpc 
#  - subnets

output "vpc" {
  description = "The VPC resource created in this modul" 
  value       = aws_vpc.vpc
}

output "subnets" {
  description = "The list of subnets created in this resource"
  value       = aws_subnet.subnets
}
