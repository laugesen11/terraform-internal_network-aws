#Completes the constructions of the subnets and VPCs we are creating in this module

locals {
  #Set up the subnets we are building
  subnet_config = {
    for item in var.subnets: item.name => {
      #"availability_zone"                = item.availability_zone
      "cidr_block"                       = item.cidr_block
      #"ipv6_cidr_block"                  = item.ipv6_cidr_block
      "options"                          = item.options
      "tags"                             = merge({"Name" = item.name},item.tags)
    }
  }
  
  #Identifies if there is an availability zone specified
  #If the setting "availability_zone=<AWS Availability zone>" is set in options list for this subnet
  #extracts this value
  subnet_availability_zone = {
    for item in var.subnets:
      #If the string matches "availability_zone=<string>" pull the value of "<string>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.name => [ 
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*availability_zone\\s*=\\s*\\S",option)) > 0
      ]
  }

  #Identifies if there is an IPv6 CIDR block specified
  #If the setting "ipv6_cidr_block=<IPv6 CIDR block>" is set in options list for this subnet
  #extracts this value
  subnet_ipv6_cidr_block = {
    for item in var.subnets:
      #If the string matches "ipv6_cidr_block=<string>" pull the value of "<string>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.name => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*ipv6_cidr_block\\s*=\\s*\\S",option)) > 0
      ]
  }
}

#Build our VPC
resource "aws_vpc" "vpc" {
  cidr_block                       = var.cidr_block
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostname
  instance_tenancy                 = var.instance_tenancy
  tags                             = merge({"Name" = var.name}, var.tags)
}

#Build our subnets
resource "aws_subnet" "subnets" {
  for_each                                       = local.subnet_config
  vpc_id                                         = aws_vpc.vpc.id
  cidr_block                                     = each.value.cidr_block
  tags                                           = each.value.tags
  assign_ipv6_address_on_creation                = contains(each.value.options,"assign_ipv6_address_on_creation")
  enable_dns64                                   = contains(each.value.options,"enable_dns64")
  enable_resource_name_dns_aaaa_record_on_launch = contains(each.value.options,"enable_resource_name_dns_aaaa_record_on_launch")
  enable_resource_name_dns_a_record_on_launch    = contains(each.value.options,"enable_resource_name_dns_a_record_on_launch") 
  ipv6_native                                    = contains(each.value.options,"ipv6_native")
  map_public_ip_on_launch                        = contains(each.value.options,"map_public_ip_on_launch")
  availability_zone                              = length(local.subnet_availability_zone[each.key]) > 0 ? local.subnet_availability_zone[each.key][0] : null
  ipv6_cidr_block                                = length(local.subnet_ipv6_cidr_block[each.key]) > 0 ? local.subnet_ipv6_cidr_block[each.key][0] : null
}
