#Completes the construction of the NACL we are creating
#First sets up the NACL, then adds the ingress and egress rules

locals {
  traffic_type_mappings = {
    "all" = {
      "to_port"   = 0
      "from_port" = 0
      "protocol"  = "all"
    }

    "http" = {
      "to_port"   = 80
      "from_port" = 80
      "protocol"  = "tcp"
    }

    "https" = {
      "to_port"   = 443
      "from_port" = 443
      "protocol"  = "tcp"
    }

    "ftp" = {
      "to_port"   = 21
      "from_port" = 21
      "protocol"  = "tcp"
    }

    "ssh" = {
      "to_port"   = 22
      "from_port" = 22
      "protocol"  = "tcp"
    }

    "telnet" = {
      "to_port"   = 23
      "from_port" = 23
      "protocol"  = "tcp"
    }

    "smtp" = {
      "to_port"   = 25
      "from_port" = 25
      "protocol"  = "tcp"
    }
   
    "web site response" = {
      "to_port"   = 1024
      "from_port" = 65535
      "protocol"  = "tcp"
    }

  }

  egress_rules = {
    for item in var.egress: item.rule_number => {
      #If "item.traffic_type" is set to null or "custom", we use the values set in local.custom_protocol_setup_egress for this rule. 
      #Otherwise we assume "item.traffic_type" is set to a value in local.item.traffic_type_mappings map.
      protocol        = item.item.traffic_type == null || item.item.traffic_type == "custom" ? local.custom_protocol_setup_egress[item.rule_number][0] : local.item.traffic_type_mappings[item.traffic_type]["protocol"]
 
      #Set to "allow" unless we have "deny_access" in options list
      action          = contains(item.options,"deny_access") ? "deny" : "allow"
   
      #Set to the external_ip_address value set in the rule if external_ip_address contains a "."
      cidr_block      = length(regexall("\\.",item.external_ip_address)) > 0 ? item.external_ip_address : null
      #Set to the external_ip_address value set in the rule if external_ip_address contains a ":"
      ipv6_cidr_block = length(regexall(":",item.external_ip_address)) > 0 ? item.external_ip_address : null

      #If "item.traffic_type" is set to null or "custom", we use the values set in local.custom_from_port_setup_egress for this rule. 
      #Otherwise we assume "item.traffic_type" is set to a value in local.item.traffic_type_mappings map.
      from_port       = item.traffic_type == null || item.traffic_type == "custom" ? local.custom_from_port_setup_egress[item.rule_number][0] : local.item.traffic_type_mappings[item.traffic_type]["from_port"]

      #If "item.traffic_type" is set to null or "custom", we use the values set in local.custom_to_port_setup_egress for this rule. 
      #Otherwise we assume "item.traffic_type" is set to a value in local.item.traffic_type_mappings map.
      to_port         = item.traffic_type == null || item.traffic_type == "custom" ? local.custom_to_port_setup_egress[item.rule_number][0] : local.item.traffic_type_mappings[item.traffic_type]["to_port"]


      #If "item.traffic_type" is set to null or "custom" and the protocol is "icmp", we use the values set in local.custom_icmp_type_setup_egress for this rule. 
      icmp_type       = (item.traffic_type == null || item.traffic_type == "custom") && protocol == "icmp" && length(local.custom_icmp_type_setup_egress[item.rule_number]) > 0 ? local.custom_icmp_type_setup_egress[item.rule_number][0] : null

      #If "item.traffic_type" is set to null or "custom" and the protocol is "icmp", we use the values set in local.custom_icmp_code_setup_egress for this rule. 
      icmp_code       = (item.traffic_type == null || item.traffic_type == "custom") && protocol == "icmp" && length(local.custom_icmp_code_setup_egress[item.rule_number]) > 0 ? local.custom_icmp_code_setup_egress[item.rule_number][0] : null
    }
  }

  ingress_rules = {
      #If "item.traffic_type" is set to null or "custom", we use the values set in local.custom_protocol_setup_egress for this rule. 
      #Otherwise we assume "item.traffic_type" is set to a value in local.item.traffic_type_mappings map.
    for item in var.ingress: item.rule_number => {
      protocol        = item.traffic_type == null || item.traffic_type == "custom" ? local.custom_protocol_setup_ingress[item.rule_number][0] : item.traffic_type_mappings[item.traffic_type]["protocol"]

      #Set to "allow" unless we have "deny_access" in options list
      action          = contains(item.options,"deny_access") ? "deny" : "allow"

      #Set to the external_ip_address value set in the rule if external_ip_address contains a "."
      cidr_block      = length(regexall("\\.",item.external_ip_address)) > 0 ? item.external_ip_address : null
      #Set to the external_ip_address value set in the rule if external_ip_address contains a ":"
      ipv6_cidr_block = length(regexall(":",item.external_ip_address)) > 0 ? item.external_ip_address : null

      #If "item.traffic_type" is set to null or "custom", we use the values set in local.custom_from_port_setup_ingress for this rule. 
      #Otherwise we assume "item.traffic_type" is set to a value in local.item.traffic_type_mappings map.
      from_port       = item.traffic_type == null || item.traffic_type == "custom" ? local.custom_from_port_setup_ingress[item.rule_number][0] : item.traffic_type_mappings[item.traffic_type]["from_port"]

      #If "item.traffic_type" is set to null or "custom", we use the values set in local.custom_to_port_setup_egress for this rule. 
      #Otherwise we assume "item.traffic_type" is set to a value in local.item.traffic_type_mappings map.
      to_port         = item.traffic_type == null || item.traffic_type == "custom" ? local.custom_to_port_setup_ingress[item.rule_number][0] : item.traffic_type_mappings[item.traffic_type]["to_port"]

      #If "item.traffic_type" is set to null or "custom" and the protocol is "icmp", we use the values set in local.custom_icmp_type_setup_ingress for this rule. 
      icmp_type       = (item.traffic_type == null || item.traffic_type == "custom") && protocol == "icmp" && length(local.custom_icmp_type_setup_ingress[item.rule_number]) > 0 ? local.custom_icmp_type_setup_ingress[item.rule_number][0] : null

      #If "item.traffic_type" is set to null or "custom" and the protocol is "icmp", we use the values set in local.custom_icmp_code_setup_ingress for this rule. 
      icmp_code       = (item.traffic_type == null || item.traffic_type == "custom") && protocol == "icmp" && length(local.custom_icmp_code_setup_ingress[item.rule_number]) > 0 ? local.custom_icmp_code_setup_ingress[item.rule_number][0] : null
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
