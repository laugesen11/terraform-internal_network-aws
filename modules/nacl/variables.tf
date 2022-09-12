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

variable "egress" {
  description = "Sets the egress (outbound) rules for the NACL"
  default = null

  type = list(
    object({  
          #Set's the traffic type
          #Set to null or "custom" to set protocol, to_port, and from_port yourself
          #Valid options include:
          #  - "all"                - All traffic to the destination (to_port,from_port=0, protocol="all")
          #  - "http"               - HTTP traffic to the destination (to_port,from_port=80, protocol="tcp")
          #  - "https"              - HTTPS traffic to the destination (to_port,from_port=443, protocol="tcp")
          #  - "ftp"                - FTP traffic to the destination (to_port,from_port=21, protocol="tcp")
          #  - "ssh"                - SSH traffic to the destination (to_port,from_port=22, protocol="tcp")
          #  - "telnet"             - Telnet traffic to the destination (to_port,from_port=23, protocol="tcp")
          #  - "smtp"               - SMTP traffic to the destination (to_port,from_port=25, protocol="tcp")
          #  - "web site response"  - Traffc to ephemeral ports, usually a response to a web page(from_port=1024,to_port=65535,protocol="tcp")
          traffic_type        = string

          #Sets the priority of the rule
          rule_number     = number

          #Sets the IPv4 or IPv6 address of the external IP address we are recieving traffic from or directing traffic to
          #We use pattern matching on this value to determine which it is
          external_cidr_range = string

          #Sets optional settings for rules
          #Valid values include:
          #  - "deny_access" - set this rule to deny access
          #  - "icmp_type=<string>"   - sets the ICMP type if handling ICMP
          #  - "icmp_code=<string>"   - sets the ICMP code if handling ICMP
          #  - "from_port=<number>"   - sets the minimum port range for custom setup. Set to '0' for all. If not set, set equal to "to_port"
          #  - "to_port=<number>"     - sets the max port port range for custom setup. Set to '0' for all. If not set, set equal to "to_port"
          #  - "protocol=<string>"    - sets the protocol if we want to handle all that ourselves. Can set to 'all' for all protocols
          options         = map(string)
    })
  )
}

variable "ingress" {
  description = "Sets the ingress (inbound) rules for the NACL"
  default = null

  type = list(
    object({  
          #Set's the traffic type
          #Set to null or "custom" to set protocol, to_port, and from_port yourself
          #Valid options include:
          #  - "all"                - All traffic from the source (to_port,from_port=0, protocol="all")
          #  - "http"               - HTTP traffic from the source (to_port,from_port=80, protocol="tcp")
          #  - "https"              - HTTPS traffic from the source (to_port,from_port=443, protocol="tcp")
          #  - "ssh"                - SSH traffic from the source (to_port,from_port=22, protocol="tcp")
          #  - "telnet"             - Telnet traffic from the source (to_port,from_port=23, protocol="tcp")
          #  - "smtp"               - SMTP traffic from the source (to_port,from_port=25, protocol="tcp")
          #  - "web site response"  - Traffic from ephemeral ports, usually a response to a web page(from_port=1024,to_port=65535,protocol="tcp")
          traffic_type        = string

          #Sets the priority of the rule
          rule_number         = number

          #Sets the IPv4 or IPv6 address of the external IP address we are recieving traffic from or directing traffic to
          #We use pattern matching on this value to determine which it is
          external_cidr_range = string

          #Sets optional settings for rules
          #Valid values include:
          #  - "deny_access"=<true|false> - set this rule to deny access
          #  - "icmp_type"="<string>"   - sets the ICMP type if handling ICMP
          #  - "icmp_code"="<string>"   - sets the ICMP code if handling ICMP
          #  - "from_port"="<number>"   - sets the minimum port range for custom setup. Set to '0' for all. If not set, set equal to "to_port"
          #  - "to_port"="<number>"     - sets the max port port range for custom setup. Set to '0' for all. If not set, set equal to "to_port"
          #  - "protocol"="<string>"    - sets the protocol if we want to handle all that ourselves. Can set to 'all' for all protocols
          options             = map(string)
    })
  )
}

variable "tags" {
  type = map(string)
  default = {}
}
