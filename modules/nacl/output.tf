#Returns the NACL for reference in parent modules

output "nacl" {
  value = aws_network_acl.network_acl
}

output "egress_rules" {
  value = aws_network_acl_rule.network_acl_egress_rules
}

output "ingress_rules" {
  value = aws_network_acl_rule.network_acl_ingress_rules
}

