#Creates VPN gateways
#Dependencies:
#  - variables.tf - defines VPCs that contain VPN gateway, subnets that connect to VPN gateways, and the ASN number for the VPN gateway (set to null for default
#    - vpn_gateways variable
#  - vpc.tf       - creates VPCs to attach VPN gateways to

locals {
  #Get the list of VPCs with VPN gateways
  vpcs_with_vpn_gateways = [
    for item in var.vpc_setup:
      item.name if contains(item.options,"has_vpn_gateway")
  ]
  
  #If the setting "amazon_side_asn=<number>" is set in the options list for this VPC,
  #extract the AS Number from this input for use later
  vpcs_with_custom_asn = {
    for item in var.vpc_setup:
      #If the string matches "amazon_side_asn=<number>" pull the value of "<number>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.name => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*amazon_side_asn\\s*=\\s*\\S",option)) > 0
      ]
  }
}

#Build our VPN gateways
resource "aws_vpn_gateway" "vpn_gateways" {
  for_each         = toset(local.vpcs_with_vpn_gateways)
  vpc_id           = module.vpcs[each.key].vpc.id
  #amazon_side_asn  = each.value > 0 ? each.value : null
  amazon_side_asn = length(local.vpcs_with_custom_asn[each.key]) > 0 ? local.vpcs_with_custom_asn[each.key][0] : null
  tags             = {
    "Name" = "VPN gateway for VPC ${each.key}"
    "VPC"  = module.vpcs[each.key].vpc.id
  }
}

