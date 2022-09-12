#Creates NAT gateways and necessary elastic IP addresses
#Dependancies:
#  - variables.tf - defines VPCs that need egress only internet gateways. 
#  Reads in:
#    - nat_gateways variable
#  - vpc.tf       - creates VPCs and subnets we place NAT Gateway in

locals{

  nat_gateways_config = {  
    for item in var.nat_gateways: item.name => {
      "is_public" = contains(item.options,"is_public")
      "options"   = item.options
      #If we specify the VPC name, we use that value to determine the subnet ID from this module
      #subnet_name_or_id will be assumed to be the name of a subnet set in this module. 
      #If vpc_name is null, we assume subnet_name_or_id is the ID of a subnet
      "subnet" = length([for subnet in values(module.vpcs)[*].subnets: subnet[item.subnet].id if contains(keys(subnet),item.subnet)]) > 0 ? element([for subnet in values(module.vpcs)[*].subnets: subnet[item.subnet].id if contains(keys(subnet),item.subnet)],0) : item.subnet
      "tags"      = lookup(item.options,"tags",null) == null ? {} : {
                      for tag in split(",",item.options["tags"]):
                        element(split("=",tag),0) => element(split("=",tag),1)
                    }
    }
  }
 
  #List of NAT Gateway names that need elastic IP address
  elastic_ips_to_make = [
    for item in var.nat_gateways: 
      item.name if contains(item.options,"make_elastic_ip")
  ]
  
  #List of NAT gateway names with existing EIP ID submitted
  #If the setting "elastic_ip_id=<id>" is set, we capture that value
  elastic_ip_ids = {
    for item in var.nat_gateways:
      #If the string matches  "elastic_ip_id=<id>" pull the value of "<id>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.name => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*elastic_ip_id\\s*=\\s*\\S",option)) > 0
      ]
  }
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
  allocation_id     = lookup(aws_eip.eips_for_nat_gateways,each.key,null) != null ? aws_eip.eips_for_nat_gateways[each.key].id : lookup(each.value.options,"elastic_ip_id",null)
  connectivity_type = each.value.is_public ? "public" : "private"
  subnet_id         = each.value.subnet
  tags              = merge({"Name" = each.key},each.value.tags)
}

