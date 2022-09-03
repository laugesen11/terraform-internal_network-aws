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
      #Check if we can pull the ID from the VPC module using the VPC name. If not, we assume this is the VPC ID
      item.nacl_name => lookup(module.vpcs,item.vpc,null) != null ? module.vpcs[item.vpc].vpc.id : item.vpc
  }

  nacl_subnets = {
    #Gets the subnets we are creating NACLs in. i
    #We only use egress because it is expected you will set an ingress and egress rule for each subnet
    for item in var.nacl_ingress_rules:
      item.nacl_name => [
        for subnet in item.nacl_subnets: 
          #Check if we can pull the VPC ID from the VPC module using the VPC name. If so, we try to pull the subnet from here
          #If not, we assume this is the ID of an existing subnet
          #item.nacl_vpc_id == null ? module.vpcs[item.nacl_vpc_name].subnets[subnet].id : subnet
          lookup(module.vpcs,item.vpc,null) == null ? subnet : ( lookup(module.vpcs[item.vpc].subnets,subnet,null) != null ? module.vpcs[item.vpc].subnets[subnet].id : subnet )
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
