#Creates our egress only interney gateways
#Dependancies:
#  - variables.tf - defines VPCs that need egress only internet gateways
#    - vpc_setup variable 'has_egress_only_internet_gateway' option
#  - vpc.tf       - creates VPCs we assign egress only internet gateways to

locals {
  #Gets the list of VPCs we need egress only internet gateways for
  vpcs_with_egress_only_internet_gateways = [
    for item in var.vpc_setup:
      item.name if lookup(item.options,"has_egress_only_internet_gateway",false)
  ]
}

#Build our egress only internet gateways
resource "aws_egress_only_internet_gateway" "egress_only_internet_gateways" {
  for_each = toset(local.vpcs_with_egress_only_internet_gateways)
  vpc_id   = module.vpcs[each.value].vpc.id
  tags     = {
    "Name" = "Egress Only Internet gateway for VPC ${each.value}"
    "VPC"  = module.vpcs[each.value].vpc.id
  }
}

