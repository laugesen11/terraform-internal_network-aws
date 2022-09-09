#Completes the constructions of the subnets and VPCs we are creating in this module

locals {
  #Set up the subnets we are building
  subnet_config = {
    for item in var.subnets: item.name => {
      "cidr_block" = item.cidr_block
      "options"    = item.options
      "tags"       = merge({"Name" = var.name}, item.tags)
    }
  }
}

#Build our VPC
resource "aws_vpc" "vpc" {
  cidr_block                       = var.cidr_block
  assign_generated_ipv6_cidr_block = lookup(var.options,"assign_generated_ipv6_cidr_block",false)
  enable_dns_support               = lookup(var.options,"disable_dns_support",false)
  enable_dns_hostnames             = lookup(var.options,"enable_dns_hostname",false)
  instance_tenancy                 = lookup(var.options,"dedicated_tenancy","default") 
  tags                             = merge({"Name" = var.name}, var.tags)
}

#Build our subnets
resource "aws_subnet" "subnets" {
  for_each                                       = local.subnet_config
  vpc_id                                         = aws_vpc.vpc.id
  cidr_block                                     = each.value.cidr_block
  assign_ipv6_address_on_creation                = contains(each.value.options,"assign_ipv6_address_on_creation")
  enable_dns64                                   = contains(each.value.options,"enable_dns64")
  enable_resource_name_dns_aaaa_record_on_launch = contains(each.value.options,"enable_resource_name_dns_aaaa_record_on_launch")
  enable_resource_name_dns_a_record_on_launch    = contains(each.value.options,"enable_resource_name_dns_a_record_on_launch") 
  ipv6_native                                    = contains(each.value.options,"ipv6_native")
  map_public_ip_on_launch                        = contains(each.value.options,"map_public_ip_on_launch")
  availability_zone                              = lookup(each.value.options,"availability_zone",null)
  ipv6_cidr_block                                = lookup(each.value.options,"ipv6_cidr_block",null)
  tags                                           = each.value.tags
}
