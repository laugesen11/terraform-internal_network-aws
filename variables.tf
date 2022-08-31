#Declare variables. 
#
#We have declared the below variables:
#
#VPC SETUP VARIABLES:
#  vpc_setup    - Sets up the VPCs we want to create.
#    Sub variable:
#      subnets - creates subnets within this VPC
# 
#NACL SETUP VARIABLES:
#  nacl_egress_rules  - sets the egress rules for NACLs
#  nacl_ingress_rules - sets the ingress rules for NACLs
#
#NETWORK ITEM SETUP VARIABLES:
#  nat_gateways  - sets up NAT gateways
#  vpc_peering   - sets up VPC peering connections
#  vpc_endpoints - sets up VPC endpoints
#  
#
#

#Base setup for VPC
variable "vpc_setup" {
  description = "Sets up the VPCs in our network. Need to set the name, cidr_block, tags, amazon_side_asn (set to below 0 to disable), ipv6_enabled, and has_vpn_gateway"
  default = null

  type = list(
     object({
       name                             = string
       cidr_block                       = string
       #Sets up options values for VPC
       #Valid values include:
       #  - "has_vpn_gateway"                  - sets up a Virtual Private gateway (VPN gateway) to this VPC
       #  - "has_internet_gateway"             - sets up an Internet gateway to this VPC
       #  - "has_egress_only_internet_gateway" - sets up an Egress Only Internet gateway to this VPC
       #  - "dedicated_tenancy"                - sets up the instance_tenancy to be "dedicated". If not set, instance_tenancy is set to "default", or shared tenancy
       #  - "disable_dns_support"              - Overrides default setting that sets enable_dns_support to true
       #  - "enable_dns_hostname"              - Overrides default setting that sets enable_dns_hostname to false
       #  - "assign_generated_ipv6_cidr_block" - Assigns an IPv6 CIDR block
       #  - "amazon_side_asn=<number>"         - sets up a custom Amaon side ASN for use with VPN gateway. If notdd set, AWS will set a default value
       options                          = list(string)
       tags                             = map(string)
 
       subnets = list(
         object({
           name              = string
           #Set to null to let AWS auto assign
           availability_zone = string
           cidr_block        = string
           ipv6_cidr_block   = string
           tags              = map(string)
         })
       )
     })
  )
}

variable "nacl_egress_rules" {
  description = "Determine the Network Access Control List egress (outbound) traffic rules"
  default = null

  type = list(
      object({
        nacl_name     = string

        #Set to use VPC created in this module. 
        #Must set this value to use subnet names for nacl_subnets
        nacl_vpc_name = string

        #Set to use VPC created outside this module
        #nacl_vpc_id will override nacl_vpc_name if set, do not use both
        nacl_vpc_id   = string

        #Can be set to subnet IDs or names used in this module
        #MUST set nacl_vpc_name to use subnet name, or this will fail
        nacl_subnets  = list(string)

        nacl_rules    = list(object({
          #Can set to 'all' for all protocols
          #Must set from_port and to_port to '0'
          protocol        = string
          rule_number     = number
          deny_access     = bool
          cidr_block      = string
          ipv6_cidr_block = string

          #Set to 0 if protocol set to 'all'
          from_port       = number

          #Set to 0 if protocol set to 'all'
          to_port         = number
   
          #Only use if setting rule for ICMP protocol
          icmp_type       = string
          icmp_code       = string
        })
      )
    })
  )
}

variable "nacl_ingress_rules" {
  description = "Determine the Network Access Control List ingress (outbound) traffic rules"
  default = null

  type = list(
    object({
      nacl_name = string

      #Set to use VPC created in this module. 
      #Must set this value to use subnet names for nacl_subnets
      nacl_vpc_name = string

      #Set to use VPC created outside this module
      #nacl_vpc_id will override nacl_vpc_name if set, do not use both
      nacl_vpc_id   = string

      #Can be set to subnet IDs or names used in this module
      #MUST set nacl_vpc_name to use subnet name, or this will fail
      nacl_subnets  = list(string)

      nacl_rules = list(object({
        #Can set to 'all' for all protocols
        #Must set from_port and to_port to '0'
        protocol        = string
        rule_number     = number
        deny_access     = bool
        cidr_block      = string
        ipv6_cidr_block = string

        #Set to 0 if protocol set to 'all'
        from_port       = number

        #Set to 0 if protocol set to 'all'
        to_port         = number
   
        #Only use if setting rule for ICMP protocol
        icmp_type       = string
        icmp_code       = string
      }))
    })
  )
}

variable "nat_gateways" {
  description = "Creates NAT gateways in the VPC identified"
  default     = null

  type = list(
    object({
      name           = string
      has_elastic_ip = bool
      is_public      = bool
      tags           = map(string)
 
      #Need both of these values set to use a subnet name set in this module
      #If not, assumes you are using the subnet name
      vpc_name          = string
      subnet_name_or_id = string
    })
  )
  
}

variable "vpc_peering" {
  description = "Sets up a VPC peering connection between two VPCs"
  default     = null

  type = list(
    object({
      #Name for the connection
      name                                  = string 
       
      #Use the VPC name from this module or an external VPC ID
      requestor_vpc_name_or_id              = string

      #Use the VPC name from this module or an external VPC ID
      peer_vpc_name_or_id                   = string
      peer_owner_id                         = string
      auto_accept                           = bool
      peer_region                           = string
      accepter_allow_remote_dns_resolution  = bool
      requester_allow_remote_dns_resolution = bool
      tags                                  = map(string) 
    })
  )
}

variable "vpc_endpoints" {
  description = "Sets up VPC endpoint"
  default     = null
  type = list(
    object({
      name                = string
 
      #Specify the AWS service this endpoint is for
      service_name        = string
      auto_accept         = bool
      private_dns_enabled = bool
      security_group_ids  = list(string)
   
      #Below settings determine how we pull subnet and VPC ID values
      #Will use this value if not set to null
      #Will IGNORE vpc_name if vpc_id is not null
      vpc_id              = string
      
      #Set this value to allow lookups of names of subnets in this module
      #Must set vpc_name to the name of a VPC set in this module
      vpc_name            = string

      #Can be "Gateway", "GatewayLoadBalancer", or "Interface"
      vpc_endpoint_type   = string
      tags                = map(string)

      #Specifies the subnet this endpoint is for
      #Can use the name of a subnet in this file, or the ID if you know it
      subnets             = list(
        object({
          name = string
          id   = string
        })
      )
    })
  )
}

variable "transit_gateways" {
  description = "Defines Transit Gateway setup"
  default     = null

  type = list(
    object({
      name                                   = string 
      description                            = string 
      tags                                   = map(string)    
      #Set if you have a specific ASN you need to use. If not, set to null to use AWS automatically assigned ASN
      amazon_side_asn                        = number
      auto_accept_shared_attachments         = bool
      enable_default_route_table_association = bool
      enable_default_route_table_propagation = bool
      enable_dns_support                     = bool
      enable_vpn_ecmp_support                = bool
    })
  )
}

variable "transit_gateway_vpc_attachments" {
  description = "Establishes connection between transit gateway and a VPC. Must have this in place before adding transit gateway to route table"
  default     = null

  type = list(
    object({
      name                       = string
      #If entry matches a name in the "transit_gateways" variable, we use that ID
      #Otherwise we assume this is the ID of an external transit gateway
      transit_gateway_name_or_id = string
      #Entry must matche a name in the "vpc_setup" variable
      #MUST use this value if intending to use subnet names as defined in 'vpc_setup' with 'subnets' setting below
      vpc_name                   = string
      #If defined, we ignore 'vpc_name' and cannot use subnet names as defined in 'vpc_setup'
      vpc_id                     = string
      #Is vpc_name is defined (and vpc_id is not), can use subnets names as defined in 'vpc_setup' variable
      #If not, all entries must be a valid subnet ID
      subnets                    = list(string)
      tags                       = map(string)

      #For all the settings below, a value of 'true' will enable this setting.
      #Look at the transit gateway attachment documentation to understand what this setting does
      enable_appliance_mode_support                          = bool
      enable_dns_support                                     = bool
      enable_ipv6_support                                    = bool
      enable_transit_gateway_default_route_table_association = bool
      enable_transit_gateway_default_route_table_propagation = bool
    })
  )
}


