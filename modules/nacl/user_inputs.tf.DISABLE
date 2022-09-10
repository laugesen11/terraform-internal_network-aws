#Handles the below user inputs:
#  egress and ingress rules options set in the "options list":
#  - "icmp_type=<string>"   - sets the ICMP type if handling ICMP
#  - "icmp_code=<string>"   - sets the ICMP code if handling ICMP
#  - "from_port=<number>"   - sets the minimum port range for custom setup. Set to '0' for all. If not set, set equal to "to_port"
#  - "to_port=<number>"     - sets the max port port range for custom setup. Set to '0' for all. If not set, set equal to "to_port"
#  - "protocol=<string>"    - sets the protocol if we want to handle all that ourselves. Can set to 'all' for all protocols
#

locals{

  #Identifies if we specified a custom protocol in the "options" list for the egress rules
  #This value is ONLY read if "traffic_type" is set to null or custom
  custom_protocol_setup_egress = {
    for item in var.egress:
      #If the string matches "protocol" pull the value of "<string>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.rule_number => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*protocol=\\s*\\S",option)) > 0
      ]
  }

  #Identifies if we specified a custom protocol in the "options" list for the ingress rules
  #This value is ONLY read if "traffic_type" is set to null or custom
  custom_protocol_setup_ingress = {
    for item in var.ingress:
      #If the string matches "protocol" pull the value of "<string>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.rule_number => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*protocol=\\s*\\S",option)) > 0
      ]
  }

  #Identifies if we specified a custom lower port range of "from_port" in the "options" list for the egress rules
  #If this is not set, we will set to have the same value as "to_port". If neither are set, both ports are set to null to make this fail
  #This value is ONLY read if "traffic_type" is set to null or custom
  custom_from_port_setup_egress = {
    for item in var.egress:
      #If the string matches "from_port=<number>" pull the value of "<number>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.rule_number => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*from_port=\\s*\\S",option)) > 0
      ]
  }

  #Identifies if we specified a custom lower port range of "from_port" in the "options" list for the ingress rules
  #If this is not set, we will set to have the same value as "to_port". If neither are set, both ports are set to null to make this fail
  #This value is ONLY read if "traffic_type" is set to null or custom
  custom_from_port_setup_ingress = {
    for item in var.ingress:
      #If the string matches "from_port=<number>" pull the value of "<number>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.rule_number => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*from_port=\\s*\\S",option)) > 0
      ]
  }

  #Identifies if we specified a custom lower port range of "to_port" in the "options" list for the egress rules
  #This value is ONLY read if "traffic_type" is set to null or custom
  custom_to_port_setup_egress = {
    for item in var.egress:
      #If the string matches "to_port=<number>" pull the value of "<number>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.rule_number => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*to_port=\\s*\\S",option)) > 0
      ]
  }

  #Identifies if we specified a custom lower port range of "to_port" in the "options" list for the egress rules
  #This value is ONLY read if "traffic_type" is set to null or custom
  custom_to_port_setup_ingress = {
    for item in var.ingress:
      #If the string matches "to_port=<number>" pull the value of "<number>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.rule_number => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*to_port=\\s*\\S",option)) > 0
      ]
  }

  #Identifies if we specified a ICMP type in the "options" list for the egress rules
  #This value is ONLY read if "traffic_type" is set to null or custom
  custom_icmp_type_setup_egress = {
    for item in var.egress:
      #If the string matches "icmp_type=<string>" pull the value of "<string>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.rule_number => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*icmp_type=\\s*\\S",option)) > 0
      ]
  }

  #Identifies if we specified a ICMP type in the "options" list for the ingress rules
  #This value is ONLY read if "traffic_type" is set to null or custom
  custom_icmp_type_setup_ingress = {
    for item in var.ingress:
      #If the string matches "icmp_type=<string>" pull the value of "<string>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.rule_number => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*icmp_type=\\s*\\S",option)) > 0
      ]
  }

  #Identifies if we specified a custom ICMP code in the "options" list for the egress rules
  #This value is ONLY read if "traffic_type" is set to null or custom
  custom_icmp_code_setup_egress = {
    for item in var.egress:
      #If the string matches "icmp_code=<string>" pull the value of "<string>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.rule_number => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*icmp_code=\\s*\\S",option)) > 0
      ]
  }

  #Identifies if we specified a custom ICMP code in the "options" list for the ingress rules
  #This value is ONLY read if "traffic_type" is set to null or custom
  custom_icmp_code_setup_ingress = {
    for item in var.ingress:
      #If the string matches "icmp_code=<string>" pull the value of "<string>"
      #WARNING: While this makes a list, we will only use the first value, so please do not set multiple values to prevent confusion
      item.rule_number => [
        for option in item.options:
          chomp(trimspace(element(split("=",option),1))) if length(regexall("\\s*\\s*icmp_code=\\s*\\S",option)) > 0
      ]
  }
}
