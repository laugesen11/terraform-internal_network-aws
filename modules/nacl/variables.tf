#Variables to create NACL
#Variables include:
#  - name       - name of NACL
#  - subnet_ids - list of subnets assigning NACL to
#  - vpc_id     - VPC NACL is assigned to
#  - egress     - egress rules for NACL
#  - ingress    - ingress rules for NACL
#  - tags       - descriptive labels of resources

#VPC ID that this NACL is assigned to
variable "vpc_id" {
  type = string
}

#Subnets that this NACL is assigned to
variable "subnet_ids" {
  type = list(string)
}

#Give a name to the NACL for identification
variable "name" {
  type = string
}

#List of egress rules for NACL
variable "egress" {
  description = "Sets the egress (outbound) rules for the NACL"
  default = null

  type = list(
    object({  
      #Set the protocol to 'all' for all
      #Must set from_port and to_port to '0'
      protocol        = string
      rule_number     = number 
      #Determines if this allows access
      deny_access     = bool
      cidr_block      = string
      ipv6_cidr_block = string
      #Set to 0 if protocol set to 'all'
      from_port       = number
      #Set to 0 if protocol set to 'all'
      to_port         = number
      #Set to null if not setting ICMP protocol
      icmp_type       = string
      #Set to null if not setting ICMP protocol
      icmp_code       = string
    })
  )
}

#List of ingress rules for NACL
variable "ingress" {
  description = "Sets the ingress (inbound) rules for the NACL"
  default = null

  type = list(
    object({  
      #Set the protocol to 'all' for all
      #Must set from_port and to_port to '0'
      protocol        = string
      rule_number     = number 
      #Determines if this allows access
      deny_access     = bool
      cidr_block      = string
      ipv6_cidr_block = string
      #Set to 0 if protocol set to 'all'
      from_port       = number
      #Set to 0 if protocol set to 'all'
      to_port         = number
      #Set to null if not setting ICMP protocol
      icmp_type       = string
      #Set to null if not setting ICMP protocol
      icmp_code       = string
    })
  )
}

variable "tags" {
  type = map(string)
  default = {}
}
