#Creates the VPCs and the subnets they contain as defined by variable vpc_setup
#Dependencies:
#  - variables.tf - sets up VPC 

locals {
  #Set up the configurations for each VPC based on inputs
  vpc_config_map = {
    for item in var.vpc_setup: item.name => {
      "cidr_block"                       = item.cidr_block 
      "assign_generated_ipv6_cidr_block" = item.assign_generated_ipv6_cidr_block
      "tags"                             = merge({"Name" = item.name}, item.tags)
      "subnets"                          = item.subnets
    }
  }
}

#Build our VPCs
module "vpcs" {
  source                           = "./modules/vpc"
  for_each                         = local.vpc_config_map
  name                             = each.key
  cidr_block                       = each.value.cidr_block
  assign_generated_ipv6_cidr_block = each.value.assign_generated_ipv6_cidr_block
  tags                             = each.value.tags
  subnets                          = each.value.subnets
}
