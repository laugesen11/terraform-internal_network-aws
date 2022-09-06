#Creates Transit gateways 
#Dependancies:
#  - vpc.tf - defines VPCs and subnets for attachments
#  - variables.tf - defines transit gateways
#  Reads in:
#    - transit_gateways variable
#    - transit_gateway_vpc_attachment variable

locals {
  #If the setting "amazon_side_asn=<number>" is set in the options list for this transit gateway,
  #extract the AS Number from this input for use later
  transit_gw_with_custom_asn = {
    for item in var.transit_gateways:
      #If the string matches "amazon_side_asn=<number>" pull the value of "<number>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.name => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*amazon_side_asn\\s*=\\s*\\S",option)) > 0
      ]
  }
  
  #Configurations for transit gateways
  transit_gateway_config = var.transit_gateways != null ? {
    for item in var.transit_gateways: item.name => {
      "description"                            = "Transit gateway named ${item.name}"
      "amazon_side_asn"                        = length(local.transit_gw_with_custom_asn[item.name]) > 0 ? local.transit_gw_with_custom_asn[item.name][0] : null
      "auto_accept_shared_attachments"         = contains(item.options,"auto_accept_shared_attachments") ? "enable" : "disable"
      "enable_default_route_table_association" = contains(item.options,"enable_default_route_table_association") ? "enable" : "disable"
      "enable_default_route_table_propagation" = contains(item.options,"enable_default_route_table_propagation") ? "enable" : "disable"
      "enable_dns_support"                     = contains(item.options,"enable_dns_support") ? "enable" : "disable"
      "enable_vpn_ecmp_support"                = contains(item.options,"enable_vpn_ecmp_support") ? "enable" : "disable"
      "tags"                                   = merge({"Name" = item.name},item.tags)
    } 
  } : {}
}

resource "aws_ec2_transit_gateway" "transit_gateways" {
  for_each                        = local.transit_gateway_config
  description                     = each.value.description
  amazon_side_asn                 = each.value.amazon_side_asn
  auto_accept_shared_attachments  = each.value.auto_accept_shared_attachments 
  default_route_table_association = each.value.enable_default_route_table_association 
  default_route_table_propagation = each.value.enable_default_route_table_propagation 
  dns_support                     = each.value.enable_dns_support 
  vpn_ecmp_support                = each.value.enable_vpn_ecmp_support 
  tags                            = each.value.tags
}

locals{
  #Configuration for transit gateway VPC attachments
  transit_gateway_vpc_attachments_config = var.transit_gateway_vpc_attachments != null ? {
    for item in var.transit_gateway_vpc_attachments: item.name => {
      #If item.transit_gateway_name_or_id resolves to an entry in the transit gateways we created here, use that ID
      #Otherwise we assume this is the ID of an external transit gateway
      "transit_gateway_id" = lookup(aws_ec2_transit_gateway.transit_gateways,item.transit_gateway,null) != null ? aws_ec2_transit_gateway.transit_gateways[item.transit_gateway].id : item.transit_gateway

      #If item.vpc_id is not null, we use that value. Otherwise, we resolve item.vpc_name using the VPCs created in module.vpcs in vpc.tf
      "vpc_id"                                          = lookup(module.vpcs,item.vpc,null) != null ? module.vpcs[item.vpc].vpc.id : item.vpc
      "tags"                                            = merge({"Name" = item.name}, item.tags)
      "appliance_mode_support"                          = contains(item.options,"appliance_mode_support") ? "enable" : "disable"
      "dns_support"                                     = contains(item.options,"disable_dns_support") ? "disable" : "enable"
      "ipv6_support"                                    = contains(item.options,"ipv6_support") ? "enable" : "disable"
      "transit_gateway_default_route_table_association" = contains(item.options,"transit_gateway_default_route_table_association")
      "transit_gateway_default_route_table_propagation" = contains(item.options,"transit_gateway_default_route_table_propagation")
      #If we can resolve a value for item.vpc in module.vpcs, we will attempt to resolve this subnet entry to a subnet name in module.vpcs
      #If one or either cannot be resolved, we assume this is a subnet ID
      "subnet_ids"  = [
        for subnet in item.subnets: 
          lookup(module.vpcs,item.vpc,null) == null ? subnet : (lookup(module.vpcs[item.vpc].subnets,subnet,null) != null ? module.vpcs[item.vpc_name].subnets[subnet].id : subnet ) 
      ]
    }
  } : {}
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_vpc_attachments"{
  for_each                                        = local.transit_gateway_vpc_attachments_config
  transit_gateway_id                              = each.value.transit_gateway_id
  vpc_id                                          = each.value.vpc_id
  appliance_mode_support                          = each.value.appliance_mode_support
  dns_support                                     = each.value.dns_support
  ipv6_support                                    = each.value.ipv6_support
  transit_gateway_default_route_table_association = each.value.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = each.value.transit_gateway_default_route_table_propagation
  subnet_ids                                      = each.value.subnet_ids
  tags                                            = each.value.tags
}
