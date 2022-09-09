#Creates the VPCs and the subnets they contain as defined by variable vpc_setup
#Dependencies:
#  - variables.tf - sets up VPC 

locals {
  #Set up the configurations for each VPC based on inputs
  vpc_config_map = {
    for item in var.vpc_setup: item.name => {
      "cidr_block"                       = item.cidr_block 
      "options"                          = item.options
      "amazon_side_asn"                  = lookup(item.options,"amazon_side_asn",null)
      "tags"                             = merge({"Name" = item.name},item.tags)
      "subnets"                          = item.subnets
    }
  }
}

#Build our VPCs
module "vpcs" {
  source                           = "./modules/vpc"
  for_each                         = local.vpc_config_map
  name                             = each.key
  tags                             = each.value.tags
  cidr_block                       = each.value.cidr_block
  options                          = each.value.options
  subnets                          = each.value.subnets
}
