#Creates NACLs to set access permissions for subnets
#Dependancies:
#  - variables.tf - defines VPCs and subnets that NACLs are assigned to
#  Reads in:
#    - nacl_egress_rules variable
#    - nacl_ingress_rules variable
#  - vpc.tf       - creates VPCs we assign NACLs to

locals {
  #Get the VPCs we need to create NACLs for
  nacl_setup = {
    for item in var.nacl_setup:
      #Check if we can pull the ID from the VPC module using the VPC name. If not, we assume this is the VPC ID
      item.nacl_name => {
        "vpc"     = lookup(module.vpcs,item.vpc,null) != null ? module.vpcs[item.vpc].vpc.id : item.vpc
        "tags"    = merge({"Name" = item.name},item.tags)

        "subnets" = [
          for subnet in item.subnets: 
            #Check if we can pull the VPC ID from the VPC module using the VPC name. If so, we try to pull the subnet from here
            #If not, we assume this is the ID of an existing subnet
            lookup(module.vpcs,item.vpc,null) == null ? subnet : ( lookup(module.vpcs[item.vpc].subnets,subnet,null) != null ? module.vpcs[item.vpc].subnets[subnet].id : subnet )
        ]
      }
  }

  #Sets the egress rulese for this NACL
  nacl_egress_rules = {
    for item in var.nacl_setup:
      item.nacl_name => [
        for rule in item.nacl_rules: 
          rule if lookup(rule.options,"is_ingress","false") != "true"
      ]
  }

  #Sets the ingress rulese for this NACL
  nacl_ingress_rules = {
    for item in var.nacl_setup:
      item.nacl_name => [
        for rule in item.nacl_rules: 
          rule if lookup(rule.options,"is_ingress","false") == "true"

      ]
  }

}

#Sets up all the NACls we need. 
#Using a nested module to allow for nested 'for_each' loops
module "nacls" {
  source     = "./modules/nacl"
  for_each   = local.nacl_setup
  vpc_id     = each.value.vpc
  name       = each.key
  subnet_ids = each.value.subnets
  egress     = local.nacl_egress_rules[each.key]
  ingress    = local.nacl_ingress_rules[each.key]
  tags       = each.value.tags 
}
