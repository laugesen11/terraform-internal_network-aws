#Creates VPC Peering connections
#Dependancies:
#  - variables.tf 
#  Reads in:
#    - vpc_peering variable
#  - vpc.tf       - creates VPCs we are peering together

locals {
  vpc_peering_config = {
    for item in var.vpc_peering: item.name => {
      #First we check if requestor_vpc_name_or_id matches the name of one of the VPCs we created
      #If so, we get the ID from that VPC. If not, we assume this is the VPC ID
      "requestor_vpc_id"                      = lookup(module.vpcs,item.requestor_vpc_name_or_id,null) != null ? module.vpcs[item.requestor_vpc_name_or_id].vpc.id : item.requestor_vpc_name_or_id
      "peer_vpc_id"                           = lookup(module.vpcs,item.peer_vpc_name_or_id,null) != null ? module.vpcs[item.peer_vpc_name_or_id].vpc.id : item.peer_vpc_name_or_id
      "peer_owner_id"                         = item.peer_owner_id 
      "auto_accept"                           = item.auto_accept
      "peer_region"                           = item.peer_region
      "accepter_allow_remote_dns_resolution"  = item.accepter_allow_remote_dns_resolution
      "requester_allow_remote_dns_resolution" = item.requester_allow_remote_dns_resolution
      "tags"                                  = item.tags
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
