# Defines variables for setup of VPC
# Supported values:
#    - name                             - the name of this VPC we can reference in the parent module
#    - cidr_block                       - The IPv4 CIDR block we are assigning to this VPC (/16 to /28) 
#    - assign_generated_ipv6_cidr_block - Assigns a generated /64 IPv6 CIDR block to this VPC
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

variable "assign_generated_ipv6_cidr_block" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
}

variable "subnets" {
  type =  list(
    object({
      name                    = string
      availability_zone       = string
      cidr_block              = string
      ipv6_cidr_block         = string
      tags                    = map(string)
    })
  )
}
