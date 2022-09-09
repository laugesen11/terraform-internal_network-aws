# Defines variables for setup of VPC
# Supported values:
#    - name                             - the name of this VPC we can reference in the parent module
#    - cidr_block                       - The IPv4 CIDR block we are assigning to this VPC (/16 to /28) 
#    - assign_generated_ipv6_cidr_block - Assigns a generated /64 IPv6 CIDR block to this VPC
#    - instance_tenancy                 - assigns the default instance tenancy (dedicated or default)
#    - enable_dns_support               - Enables DNS support in the VPC by AWS. Otherwise have to make custom setup
#    - enable_dns_hostname              - Enables DNS hostnames to be auto assignes to instances
#    - tags                             - Tags to help describe this VPC
#    - subnets                          - The subnets we will create in this VPC
#          - subnets sub variables:
#               - name              - name of subnet we can reference in parent module
#               - availability_zone - the availability zone this subnet will be placed in
#               - cidr_block        - IPv4 CIDR block we are assigning to this subnet
#               - ipv6_cidr_block   - IPv6 CIDR block we are assigning to this sunet
#               - tags              - Tags to help descript this subnet

variable "name" { 
  type = string
}

variable "cidr_block" {
  type = string
}

#Valid values include:
#  - "dedicated_tenancy = <true|false>"                - sets up the instance_tenancy to be "dedicated". If not set, instance_tenancy is set to "default", or shared tenancy
#  - "disable_dns_support = <true|false>"              - Overrides default setting that sets enable_dns_support to true
#  - "enable_dns_hostname = <true|false>"              - Overrides default setting that sets enable_dns_hostname to false
#  - "assign_generated_ipv6_cidr_block = <true|false>" - Assigns an IPv6 CIDR block
#  - "tags=map"
variable "options" {
  type    = map(string)
  default = null
}

variable "subnets" {
  type =  list(
    object({
      name                    = string
      #Only set to null if you also specify "ipv6_native" and setup an IPv CIDR block in options
      cidr_block              = string
      tags                    = map(string)
      #Sets optional values for subnets
      #Valid values include:
      #  - "assign_ipv6_address_on_creation = <true|false>" - indicates that network interfaces created in the specified subnet should be assigned an IPv6 address
      #  - "enable_dns64 = <true|false>" - Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations
      #  - "enable_resource_name_dns_aaaa_record_on_launch = <true|false>" - Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records
      #  - "enable_resource_name_dns_a_record_on_launch = <true|false>"    - Indicates whether to respond to DNS queries for instance hostnames with DNS A records
      #  - "ipv6_native = <true|false>"  - Indicates whether to create an IPv6-only subnet
      #  - "map_public_ip_on_launch = <true|false>"        - Specify true to indicate that instances launched into the subnet should be assigned a public IP address
      #  - "ipv6_cidr_block=<IPv6 CIDR block>"- The IPv6 network range for the subnet, in CIDR notation. The subnet size must use a /64 prefix length.
      #  - "availability_zone=<AWS Availability zone>"      - AZ for the subnet
      options = map(string)

    })
  )
}
