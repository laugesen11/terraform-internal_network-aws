#Creates Transit gateways 
#Dependancies:
#  - vpc.tf - defines VPCs and subnets for attachments
#  - variables.tf - defines transit gateways
#  Reads in:
#    - transit_gateways variable
#    - transit_gateway_vpc_attachment variable

locals {
  #Configurations for transit gateways
  transit_gateway_config = var.transit_gateways != null ? {
    for item in var.transit_gateways: item.name => {
      "description"                            = item.description
      "amazon_side_asn"                        = item.amazon_side_asn
      "auto_accept_shared_attachments"         = item.auto_accept_shared_attachments
      "enable_default_route_table_association" = item.enable_default_route_table_association
      "enable_default_route_table_propagation" = item.enable_default_route_table_propagation
      "enable_dns_support"                     = item.enable_dns_support
      "enable_vpn_ecmp_support"                = item.enable_vpn_ecmp_support
      "tags"                                   = merge({"Name" = item.name},item.tags)
    } 
  } : {}
}

resource "aws_ec2_transit_gateway" "transit_gateways" {
  for_each                        = local.transit_gateway_config
  description                     = each.value.description
  amazon_side_asn                 = each.value.amazon_side_asn
  auto_accept_shared_attachments  = each.value.auto_accept_shared_attachments ? "enable" : "disable"
  default_route_table_association = each.value.enable_default_route_table_association ? "enable" : "disable"
  default_route_table_propagation = each.value.enable_default_route_table_propagation ? "enable" : "disable"
  dns_support                     = each.value.enable_dns_support ? "enable" : "disable"
  vpn_ecmp_support                = each.value.enable_vpn_ecmp_support ? "enable" : "disable"
  tags                            = each.value.tags
}

locals{
  #Configuration for transit gateway VPC attachments
  transit_gateway_vpc_attachments_config = var.transit_gateway_vpc_attachments != null ? {
    for item in var.transit_gateway_vpc_attachments: item.name => {
      #If item.transit_gateway_name_or_id resolves to an entry in the transit gateways we created here, use that ID
      #Otherwise we assume this is the ID of an external transit gateway
      "transit_gateway_id" = lookup(aws_ec2_transit_gateway.transit_gateways,item.transit_gateway_name_or_id,null) != null ? aws_ec2_transit_gateway.transit_gateways[item.transit_gateway_name_or_id].id : item.transit_gateway_name_or_id

      #If item.vpc_id is not null, we use that value. Otherwise, we resolve item.vpc_name using the VPCs created in module.vpcs in vpc.tf
      "vpc_id"                                          = item.vpc_id != null ? item.vpc_id : module.vpcs[item.vpc_name].vpc.id
      "tags"                                            = merge({"Name" = item.name}, item.tags)
      "appliance_mode_support"                          = item.enable_appliance_mode_support ? "enable" : "disable"
      "dns_support"                                     = item.enable_dns_support ? "enable" : "disable"
      "ipv6_support"                                    = item.enable_ipv6_support ? "enable" : "disable"
      "transit_gateway_default_route_table_association" = item.enable_transit_gateway_default_route_table_association
      "transit_gateway_default_route_table_propagation" = item.enable_transit_gateway_default_route_table_propagation
      #If item.vpc_id is not null, we assume all these values are subnets IDs and apply them directly. 
      #If item.vpc_id is null, we use item.vpc_name in module.vpcs to attempt to resolve the entry as a subnet name. 
      #If we cannot find a subnet by that name, we assume this entry is a subnet ID
      "subnet_ids"  = [
        for subnet in item.subnets: 
          item.vpc_id != null ? subnet : (lookup(module.vpcs[item.vpc_name].subnets,subnet,null) != null ? module.vpcs[item.vpc_name].subnets[subnet].id : subnet)
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
