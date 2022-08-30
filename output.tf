#Set output values for this Terraform module. 
#Allows the root module to print outputs to CLI to confirm resource creation.
#Allows child module to expose a subset of its resource attributes to a parent module
#Outputs:
#
# - subnets                                    : map[<subnet name>] ->subnet information (look at aws_subnet documentation for return values)
# - vpcs                                       : map[<vpc name>] -> vpc information (look at aws_vpc documentation for return values)
# - egress_only_internet_gateways              : egress only internet gateway map (map[<vpc name>] -> EOGW info (look at aws_egress_only_internet_gateway documentation for return values)
# - internet_gateways                          : internet gateway map (map[<vpc name>] -> internet gateway info (look at aws_internet_gateway documentation for return values)
# - vpn_gateways                               : vpn_gateway  (map[<vpc name>] -> VPN gateway info  (look at aws_vpn_gateway documentation for return values)
# - vpc_id_to_egress_only_internet_gateway_map : map of VPC ID to associated egress only internet gateway ID (map[<vpc id>] = <EOIGW ID>)
# - vpc_id_to_internet_gateway_map             : map of VPC ID to associated internet gateway ID (map[<vpc id>] = <IGW ID>)
# - vpc_id_to_vpn_gateway_map                  : map of VPC ID to associated VPN gateway ID (map[<vpc id>] = <VPN GW ID>)


output "subnets" {
  value = values(module.vpcs)[*].subnets
}

output "egress_only_internet_gateways" {
  value = aws_egress_only_internet_gateway.egress_only_internet_gateways
}

output "internet_gateways" {
  value = aws_internet_gateway.internet_gateways
}

output "nat_gateways" {
  value = aws_nat_gateway.nat_gateways
}

output "transit_gateways" {
  value = aws_ec2_transit_gateway.transit_gateways
}

output "vpc_endpoints" {
  value = aws_vpc_endpoint.vpc_endpoints
}

output "vpc_peering_connections" {
  value = aws_vpc_peering_connection.vpc_peering_connections
}

output "vpn_gateways" {
  value = aws_vpn_gateway.vpn_gateways
}

output "nacls" {
  value = module.nacls
}

output "vpcs" {
   value = module.vpcs
}


output "vpc_id_to_egress_only_internet_gateway_map" {
  value = { for key,value in aws_egress_only_internet_gateway.egress_only_internet_gateways: value.vpc_id => value.id }
}

output "vpc_id_to_internet_gateway_map" {
  value = { for key,value in aws_internet_gateway.internet_gateways: value.vpc_id => value.id }
}

output "vpc_id_to_vpn_gateway_map" {
  value = { for key,value in aws_vpn_gateway.vpn_gateways: value.vpc_id => value.id }

}


