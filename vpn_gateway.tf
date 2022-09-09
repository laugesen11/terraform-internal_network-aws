#Creates VPN gateways
#Dependencies:
#  - variables.tf - defines VPCs that contain VPN gateway, subnets that connect to VPN gateways, and the ASN number for the VPN gateway (set to null for default
#    - vpn_gateways variable
#  - vpc.tf       - creates VPCs to attach VPN gateways to

locals {
  #Get the list of VPCs with VPN gateways
  vpcs_with_vpn_gateways = [
    for item in var.vpc_setup:
      item.name if lookup(item.options,"has_vpn_gateway",false)
  ]
}

#Build our VPN gateways
resource "aws_vpn_gateway" "vpn_gateways" {
  for_each         = toset(local.vpcs_with_vpn_gateways)
  vpc_id           = module.vpcs[each.key].vpc.id
  amazon_side_asn  = lookup(local.vpc_config_map[each.key],"amazon_side_asn",null)
  tags             = {
    "Name" = "VPN gateway for VPC ${each.key}"
    "VPC"  = module.vpcs[each.key].vpc.id
  }
}

