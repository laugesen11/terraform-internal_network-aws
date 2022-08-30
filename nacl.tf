#Creates NACLs to set access permissions for subnets
#Dependancies:
#  - variables.tf - defines VPCs and subnets that NACLs are assigned to
#  Reads in:
#    - nacl_egress_rules variable
#    - nacl_ingress_rules variable
#  - vpc.tf       - creates VPCs we assign NACLs to

locals {
  #Get the VPCs we need to create NACLs for
  nacl_vpcs = {
    for item in var.nacl_egress_rules:
      #If we specified the VPC ID, we use that. If not, we pull the ID from the VPC module using the VPC name
      item.nacl_name => item.nacl_vpc_id != null ? item.nacl_vpc_id : module.vpcs[item.nacl_vpc_name].vpc.id
  }

  nacl_subnets = {
    #Gets the subnets we are creating NACLs in. i
    #We only use egress because it is expected you will set an ingress and egress rule for each subnet
    for item in var.nacl_ingress_rules:
      item.nacl_name => [
        for subnet in item.nacl_subnets: 
          #If we specified the VPC ID, we expect the subnet ID to be provided directly.
          #If not, we pull the subnet ID from the VPC module using the VPC name
          item.nacl_vpc_id == null ? module.vpcs[item.nacl_vpc_name].subnets[subnet].id : subnet
      ]
  }
  
  #Sets the egress rulese for this NACL
  nacl_egress_rules = {
    for item in var.nacl_egress_rules:
      item.nacl_name => item.nacl_rules
  }

  #Sets the ingress rulese for this NACL
  nacl_ingress_rules = {
    for item in var.nacl_ingress_rules:
      item.nacl_name => item.nacl_rules
  }

}

#Sets up all the NACls we need. 
#Using a nested module to allow for nested 'for_each' loops
module "nacls" {
  source     = "./modules/nacl"
  for_each   = local.nacl_vpcs
  vpc_id     = each.value
  name       = each.key
  subnet_ids = local.nacl_subnets[each.key]
  egress     = local.nacl_egress_rules[each.key]
  ingress    = local.nacl_ingress_rules[each.key]
  tags = {}
}
