#Completes the constructions of the subnets and VPCs we are creating in this module

locals {
  #Set up the subnets we are building
  subnet_config = {
    for item in var.subnets: item.name => {
      "availability_zone"                = item.availability_zone
      "cidr_block"                       = item.cidr_block
      "ipv6_cidr_block"                  = item.ipv6_cidr_block
      "tags"                             = merge({"Name" = item.name},item.tags)
    }
  }

}

#Build our VPC
resource "aws_vpc" "vpc" {
  cidr_block                       = var.cidr_block
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostname              = var.enable_dns_hostname
  instance_tenancy                 = var.instance_tenancy
  tags                             = merge({"Name" = var.name}, var.tags)
}

#Build our subnets
resource "aws_subnet" "subnets" {
  vpc_id = aws_vpc.vpc.id

  for_each          = local.subnet_config
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block
  ipv6_cidr_block   = each.value.ipv6_cidr_block
  tags              = each.value.tags
}
