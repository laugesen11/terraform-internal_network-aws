#Completes the construction of the NACL we are creating
#First sets up the NACL, then adds the ingress and egress rules

locals {
  egress_rules = {
    for item in var.egress: item.rule_number => {
      protocol        = item.protocol
      action          = item.deny_access ? "deny" : "allow"
      cidr_block      = item.cidr_block
      ipv6_cidr_block = item.ipv6_cidr_block
      from_port       = item.from_port
      to_port         = item.to_port
      icmp_type       = item.icmp_type
      icmp_code       = item.icmp_code
    }
  }

  ingress_rules = {
    for item in var.ingress: item.rule_number => {
      protocol        = item.protocol
      action          = item.deny_access ? "deny" : "allow"
      cidr_block      = item.cidr_block
      ipv6_cidr_block = item.ipv6_cidr_block
      from_port       = item.from_port
      to_port         = item.to_port
      icmp_type       = item.icmp_type
      icmp_code       = item.icmp_code
    }
  }
  
  #Make sure the tags have the name of the NACL set in the configuration, as well as the VPC ID
  tags = merge({"Name" = var.name, "VPC" = var.vpc_id},var.tags)
}

#Create NACL with specifications
resource "aws_network_acl" "network_acl" {
  vpc_id     = var.vpc_id
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : null
  tags       = local.tags
}

resource "aws_network_acl_rule" "network_acl_ingress_rules" {
  network_acl_id  = aws_network_acl.network_acl.id
  for_each        = local.ingress_rules
  protocol        = each.value.protocol
  rule_number     = each.key
  egress          = false
  rule_action     = each.value.action
  cidr_block      = each.value.cidr_block
  ipv6_cidr_block = each.value.ipv6_cidr_block
  from_port       = each.value.from_port
  to_port         = each.value.to_port
  icmp_type       = each.value.icmp_type
  icmp_code       = each.value.icmp_code
}

resource "aws_network_acl_rule" "network_acl_egress_rules" {
  network_acl_id = aws_network_acl.network_acl.id
  for_each        = local.egress_rules
  protocol        = each.value.protocol
  rule_number     = each.key
  egress          = true
  rule_action     = each.value.action
  cidr_block      = each.value.cidr_block
  ipv6_cidr_block = each.value.ipv6_cidr_block
  from_port       = each.value.from_port
  to_port         = each.value.to_port
  icmp_type       = each.value.icmp_type
  icmp_code       = each.value.icmp_code
}
