#Creates VPC Endpoints
#Dependancies:
#  - variables.tf - defines VPCs and subnet that we are assigning these endpoints to
#  Reads in:
#    - vpc_endpoints variable
#  - vpc.tf       - creates VPCs and subnets we place VPC Endpoint in

locals {
  vpc_enpoints_config = { 
    for item in var.vpc_endpoints: item.name => {
      "service_name"        = item.service_name
      #See if we have an entry in the VPC module for the value of 'vpc_name_or_id'. If not, we assume this is the VPC ID itself
      "vpc_id"              = item.vpc_id != null ? item.vpc_id : module.vpcs[item.vpc_name].vpc.id  
      "auto_accept" = item.auto_accept
      "private_dns_enabled" = item.vpc_endpoint_type != "Gateway" ? item.private_dns_enabled : null
      "security_group_ids"  = item.security_group_ids
      "vpc_endpoint_type"   = item.vpc_endpoint_type
      "tags"                = item.tags
 
      #Subnet IDs are only allowed for Interface and GatewayLoadBalancer type VPC Endpoints
      "subnet_ids" = item.vpc_endpoint_type == "Gateway" ? null : [
        for subnet in item.subnets:
          #Need to define vpc_name to use the 'name' option
          subnet.id != null ? subnet.id : module.vpcs[item.vpc_name].subnets[subnet.name].id
      ]
    }
  }
}

#Make VPC endpoint resources
resource "aws_vpc_endpoint" "vpc_endpoints" {
  for_each            = local.vpc_enpoints_config
  service_name        = each.value.service_name
  vpc_id              = each.value.vpc_id
  auto_accept         = each.value.auto_accept
  private_dns_enabled = each.value.private_dns_enabled
  security_group_ids  = each.value.security_group_ids
  vpc_endpoint_type   = each.value.vpc_endpoint_type
  subnet_ids          = each.value.subnet_ids
  tags                = each.value.tags
}
