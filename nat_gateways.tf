#Creates NAT gateways and necessary elastic IP addresses
#Dependancies:
#  - variables.tf - defines VPCs that need egress only internet gateways. 
#  Reads in:
#    - nat_gateways variable
#  - vpc.tf       - creates VPCs and subnets we place NAT Gateway in

locals{
  nat_gateways_config = {  
    for item in var.nat_gateways: item.name => {
      "has_elastic_ip" = item.has_elastic_ip
      "is_public" = item.is_public
      "tags" = item.tags

      #If we specify the VPC name, we use that value to determine the subnet ID from this module
      #subnet_name_or_id will be assumed to be the name of a subnet set in this module. 
      #If vpc_name is null, we assume subnet_name_or_id is the ID of a subnet
      "subnet" = item.vpc_name != null ? module.vpcs[item.vpc_name].subnets[item.subnet_name_or_id].id : item.subnet_name_or_id
    }
  }
 
  #List of NAT Gateway names that need elastic IP address
  elastic_ips_to_make = [
    for item in var.nat_gateways: 
      item.name if item.has_elastic_ip
  ]
}

#Create our elastic IP addresses
resource "aws_eip" "eips_for_nat_gateways" {
  for_each = toset(local.elastic_ips_to_make)
  vpc      = true
  tags     = {
    "Subnet ID"        = "${local.nat_gateways_config[each.key].subnet}"
    "NAT Gateway name" = "${each.key}" 
  }
}

#Create our NAT gateways
resource "aws_nat_gateway" "nat_gateways" {
  for_each          = local.nat_gateways_config
  allocation_id     = each.value.has_elastic_ip ? aws_eip.eips_for_nat_gateways[each.key].id : null
  connectivity_type = each.value.is_public ? "public" : "private"
  subnet_id         = each.value.subnet
  tags              = each.value.tags
}

