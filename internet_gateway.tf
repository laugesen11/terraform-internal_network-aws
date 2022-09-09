#Create our internet gateways
#Dependancy:
#  variable.tf - defines VPCs that need a Internet gateway
#    - vpc_setup variable 'has_internet_gateway' option
#  vpc.tf      - creates VPC to assign gateway to

locals{
  #Gets the list of VPCs we need internet gateways for
  vpcs_with_internet_gateways = [
    for item in var.vpc_setup:
      item.name if lookup(item.options,"has_internet_gateway",false)
  ]
}

#Build our internet gateways
resource "aws_internet_gateway" "internet_gateways" {
  for_each = toset(local.vpcs_with_internet_gateways)
  vpc_id   = module.vpcs[each.value].vpc.id
  tags     = {
    "Name" = "Internet gateway for VPC ${each.value}"
    "VPC"  = module.vpcs[each.value].vpc.id
  }
}

