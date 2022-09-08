#Creates VPC Peering connections
#Dependancies:
#  - variables.tf 
#  Reads in:
#    - vpc_peering variable
#  - vpc.tf       - creates VPCs we are peering together

locals {
  #If the setting "peer_owner_id=<id>" is set in the options list for this VPC peering connection,
  #Extract the peer owner ID for this connection
  peer_owner_id_options = {
    for item in var.vpc_peering:
      #If the string matches "peer_owner_id=<id>" pull the value of "<id>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.name => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*peer_owner_id=\\s*\\S",option)) > 0
      ]
  }

  #If the setting "peer_region=<region>" is set in the options list for this VPC peering connection,
  #Extract the peer region for this connection
  peer_region_options = {
    for item in var.vpc_peering:
      #If the string matches "peer_region=<region>" pull the value of "<region>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.name => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*peer_region=\\s*\\S",option)) > 0
      ]
  }

  vpc_peering_config = {
    for item in var.vpc_peering: item.name => {
      #First we check if requestor_vpc_name_or_id matches the name of one of the VPCs we created
      #If so, we get the ID from that VPC. If not, we assume this is the VPC ID
      "requestor_vpc_id"                      = lookup(module.vpcs,item.requestor_vpc,null) != null ? module.vpcs[item.requestor_vpc].vpc.id : item.requestor_vpc
      "peer_vpc_id"                           = lookup(module.vpcs,item.peer_vpc,null) != null ? module.vpcs[item.peer_vpc].vpc.id : item.peer_vpc
      "peer_owner_id"                         = length(local.peer_owner_id_options[item.name]) > 0 ? local.peer_owner_id_options[item.name][0] : null
      "peer_region"                           = length(local.peer_region_options[item.name]) > 0 ? local.peer_region_options[item.name] : null
      "auto_accept"                           = contains(item.options,"auto_accept")
      "accepter_allow_remote_dns_resolution"  = contains(item.options,"accepter_allow_remote_dns_resolution")
      "requester_allow_remote_dns_resolution" = contains(item.options,"requester_allow_remote_dns_resolution")
      "tags"                                  = merge({"Name" = item.name},item.tags)
    }
  }
}

resource "aws_vpc_peering_connection" "vpc_peering_connections"{
  for_each      = local.vpc_peering_config
  peer_owner_id = each.value.peer_owner_id 
  peer_vpc_id   = each.value.peer_vpc_id
  vpc_id        = each.value.requestor_vpc_id
  auto_accept   = each.value.auto_accept
  peer_region   = each.value.peer_region
  tags          = each.value.tags

  accepter {
    allow_remote_vpc_dns_resolution = each.value.accepter_allow_remote_dns_resolution
  }

  requester {
    allow_remote_vpc_dns_resolution = each.value.requester_allow_remote_dns_resolution
  }
}
