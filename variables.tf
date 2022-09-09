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
       #  - "has_vpn_gateway = <true|false>"                  - sets up a Virtual Private gateway (VPN gateway) to this VPC
       #  - "has_internet_gateway = <true|false>"             - sets up an Internet gateway to this VPC
       #  - "has_egress_only_internet_gateway = <true|false>" - sets up an Egress Only Internet gateway to this VPC
       #  - "dedicated_tenancy = <true|false>"                - sets up the instance_tenancy to be "dedicated". If not set, instance_tenancy is set to "default", or shared tenancy
       #  - "disable_dns_support = <true|false>"              - Overrides default setting that sets enable_dns_support to true
       #  - "enable_dns_hostname = <true|false>"              - Overrides default setting that sets enable_dns_hostname to false
       #  - "assign_generated_ipv6_cidr_block = <true|false>" - Assigns an IPv6 CIDR block
       #  - "amazon_side_asn=<number>"         - sets up a custom Amaon side ASN for use with VPN gateway. If notdd set, AWS will set a default value
       options                          = map(string)
       tags                             = map(string)
       
       subnets = list(
         object({
           name              = string
           cidr_block        = string
           #Sets optional values for subnets
           #Valid values include:
           #  - "assign_ipv6_address_on_creation = <true|false>"                - indicates that network interfaces created in the specified subnet should be assigned an IPv6 address
           #  - "enable_dns64 = <true|false>"                                   - Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations
           #  - "enable_resource_name_dns_aaaa_record_on_launch = <true|false>" - Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records
           #  - "enable_resource_name_dns_a_record_on_launch = <true|false>"    - Indicates whether to respond to DNS queries for instance hostnames with DNS A records
           #  - "ipv6_native = <true|false>"                                    - Indicates whether to create an IPv6-only subnet
           #  - "map_public_ip_on_launch = <true|false>"                        - Specify true to indicate that instances launched into the subnet should be assigned a public IP address
           #  - "ipv6_cidr_block=<IPv6 CIDR block>"              - The IPv6 network range for the subnet, in CIDR notation. The subnet size must use a /64 prefix length.
           #  - "availability_zone=<AWS Availability zone>"      - AZ for the subnet
           options = map(string)
           tags    = map(string)
         })
       )
     })
  )
}

variable "nacl_setup" {
  description = "Determine the Network Access Control List egress (outbound) traffic rules"
  default = null

  type = list(
      object({
        nacl_name     = string

        #Set to use VPC created in this module. 
        #Must set this value to use subnet names for nacl_subnets
        vpc = string

        #Can be set to subnet IDs or names used in this module
        subnets  = list(string)

        nacl_rules    = list(object({
          #Set's the traffic type
          #Set to null or "custom" to set protocol, to_port, and from_port yourself
          #Valid options include:
          #  - "all"                - All traffic from the source (to_port,from_port=0, protocol="all")
          #  - "http"               - HTTP traffic from the source (to_port,from_port=80, protocol="tcp")
          #  - "https"              - HTTPS traffic from the source (to_port,from_port=443, protocol="tcp")
          #  - "ssh"                - SSH traffic from the source (to_port,from_port=22, protocol="tcp")
          #  - "telnet"             - Telnet traffic from the source (to_port,from_port=23, protocol="tcp")
          #  - "smtp"               - SMTP traffic from the source (to_port,from_port=25, protocol="tcp")
          #  - "web site response"  - Traffic from ephemeral ports, usually a responce to a web page(from_port=1024,to_port=65535,protocol="tcp")
          traffic_type        = string

          #Sets the priority of the rule
          rule_number     = number

          #Sets the IPv4 or IPv6 address of the external IP address we are recieving traffic from or directing traffic to
          #We use pattern matching on this value to determine which it is
          external_cidr_range = string

 
          #Sets optional settings for rules
          #Valid values include:
          #  - "deny_access" - set this rule to deny access
          #  - "is_ingress"  - set this rule to be an ingress. Otherwise, this will be an egress rule
          #  - "icmp_type=<string>"   - sets the ICMP type if handling ICMP
          #  - "icmp_code=<string>"   - sets the ICMP code if handling ICMP
          #  - "from_port=<number>"   - sets the minimum port range for custom setup. Set to '0' for all. If not set, set equal to "to_port"
          #  - "to_port=<number>"     - sets the max port port range for custom setup. Set to '0' for all. If not set, set equal to "to_port"
          #  - "protocol=<string>"    - sets the protocol if we want to handle all that ourselves. Can set to 'all' for all protocols 
          options         = list(string)
        })
      )
    })
  )
}

variable "nat_gateways" {
  description = "Creates NAT gateways in the VPC identified"
  default     = null

  type = list(
    object({
      name           = string
      
      #Sets optional values
      #Valid values include:
      #  - "make_elastic_ip"    - make a new elastic IP and attach to this NAT gateway
      #  - "is_public"          - makes this a public NAT Gateway. Otherwise this is private
      #  - "elastic_ip_id=<id>" - attached already created elastic IP to this NAT gateway
      #  - "vpc_name=<string>"  - allows us to pull the subnet value from the vpc module using the name of a VPC defined in the internal_network module
      options        = list(string)   
 
      #Need both of these values set to use a subnet name set in this module
      #If not, assumes you are using the subnet name
      subnet = string
      tags           = map(string)
    })
  )
  
}

variable "vpc_peering" {
  description = "Sets up a VPC peering connection between two VPCs"
  default     = null

  type = list(
    object({
      #Name for the connection
      name          = string 
       
      #Use the VPC name from this module or an external VPC ID
      requestor_vpc = string

      #Use the VPC name from this module or an external VPC ID
      peer_vpc      = string
      
      #Sets optional values
      #Valid values include:
      #  - "auto_accept" - Accept the peering (both VPCs need to be in the same AWS account and region).
      #  - "accepter_allow_remote_dns_resolution" - Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC
      #  - "requester_allow_remote_dns_resolution" - Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC
      #  - "peer_region=<region>" - region of the accepter VPC of the VPC Peering Connection (auto_accept must be false)
      #  - "peer_owner_id=<id>" - The AWS account ID of the owner of the peer VPC. Defaults to the account ID the AWS provider is currently connected to.
      options       = list(string)     

      tags                                  = map(string) 
    })
  )
}

#variable "vpc_endpoints" {
#  description = "Sets up VPC endpoint"
#  default     = null
#  type = list(
#    object({
#      name                = string
# 
#      #Specify the AWS service this endpoint is for
#      service_name        = string
#
#      #The VPC this is assigned to
#      vpc                 = string
#
#      #Sets optional values
#      #Valid values include:
#      #  - "auto_accept" - Accept the VPC endpoint (the VPC endpoint and service need to be in the same AWS account).
#      #  - "private_dns_enabled" -  (AWS services and AWS Marketplace partner services only) Whether or not to associate a private hosted zone with the specified VPC. Applicable for endpoints of type Interface. 
#      #  - "ip_address_type=<ipv4|ipv6|dual stack>" - The IP address type for the endpoint. Valid values are ipv4, dualstack, and ipv6.
#      #  - "security_groupsi=<list of security groups>" - list of security groups to associate with this endpoint. Applicable for endpoints of type Interface. Can be security group defined here or external security group  
#      #  - "subnets=<list of subnets>" - list of subnets this endpoint is for. Applicable for endpoints of type GatewayLoadBalancer and Interface. Can be for subnets defined here or externally  
#      #  - "route_table_ids=<route_table_ids>" - One or more route table IDs. Applicable for endpoints of type Gateway.
#      #  - "vpc_endpoint_type=<Gateway|Interface|GatewayLoadBalancer>" - The VPC endpoint type. Gateway, GatewayLoadBalancer, or Interface. Defaults to Gateway.
#      #  - "dns_record_ip_type=<ipv4|dualstack|service-defined|ipv6>" 
#      options             = list(string)
#      tags                = map(string)
#    })
#  )
#}

variable "transit_gateways" {
  description = "Defines Transit Gateway setup"
  default     = null

  type = list(
    object({
      name                                   = string 
      tags                                   = map(string)    
      
      #Sets optional values for transit gateway
      #  Valid values:
      #    - "amazon_side_asn=<number>"               - Set if you have a specific ASN you need to use. 
      #    - "auto_accept_shared_attachments"         - Whether resource attachment requests are automatically accepted
      #    - "enable_default_route_table_association" - Whether resource attachments are automatically associated with the default association route table
      #    - "enable_default_route_table_propagation" - Whether resource attachments automatically propagate routes to the default propagation route table 
      #    - "enable_dns_support"                     - Whether DNS support is enabled
      #    - "enable_vpn_ecmp_support"                - Whether VPN Equal Cost Multipath Protocol support is enabled
      options                                = list(string)
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
      transit_gateway            = string
      #If entry matches a name in the "vpc_setup" variable, we use that. Otherwise we expect this is a VPC IS
      vpc                        = string
      #If we can resolve a name in "vpc_setup" variable, we use that ID. Otherwise we expect this is a subnet ID
      subnets                    = list(string)
      tags                       = map(string)

      #Sets optional values for transit gateway VPC attachment
      #  Valid values:
      #    - "enable_appliance_mode_support" - If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow
      #    - "disable_dns_support" - Whether DNS support is enabled
      #    - "enable_ipv6_support" - Whether IPv6 support is enabled
      #    - "enable_transit_gateway_default_route_table_association" - Boolean whether the VPC Attachment should be associated with the EC2 Transit Gateway association default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways 
      #    - "enable_transit_gateway_default_route_table_propagation" - Boolean whether the VPC Attachment should propagate routes with the EC2 Transit Gateway propagation default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways
      options                    = list(string)
    })
  )
}


