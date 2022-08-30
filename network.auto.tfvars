vpc_setup=[
  { 
    name                             = "Larry test VPC"
    cidr_block                       = "10.0.0.0/16"
    assign_generated_ipv6_cidr_block = false
    tags                             = { "Env" : "Test" }
    has_vpn_gateway                  = true
    has_internet_gateway             = true
    has_egress_only_internet_gateway = true
    amazon_side_asn = -1
    subnets = [
    {
        name              = "Larry Test Subnet"
        availability_zone = null
        cidr_block        = "10.0.0.0/24"
        ipv6_cidr_block   = null
        tags              = { "Env" : "Test" }
      },
      {
        name              = "Larry Test Subnet 2"
        availability_zone = null
        cidr_block        = "10.0.1.0/24"
        ipv6_cidr_block   = null
        tags              = { "Env" : "Test" }
      },
      {
        name              = "Larry Test Subnet 3"
        availability_zone = null
        cidr_block        = "10.0.2.0/24"
        ipv6_cidr_block   = null
        tags              = { "Env" : "Test" }
      }
    ]
  },
  { 
    name                             = "Larry test VPC 2"
    cidr_block                       = "192.168.0.0/16"
    assign_generated_ipv6_cidr_block = false
    tags                             = { "Env" : "Test" }
    has_vpn_gateway                  = true
    has_internet_gateway             = true
    has_egress_only_internet_gateway = true
    amazon_side_asn = -1
    subnets = [
      {
        name              = "Larry Test Subnet 4"
        availability_zone = null
        cidr_block        = "192.168.0.0/24"
        ipv6_cidr_block   = null
        tags              = { "Env" : "Test" }
      },
    ],
  }, 
]

nacl_egress_rules = [
  {
    nacl_name     = "default"
    nacl_vpc_name = "Larry test VPC"
    nacl_vpc_id   = null
    nacl_subnets  = ["Larry Test Subnet 3"]
    nacl_rules = [ 
      {
        protocol        = "all"
        rule_number     = 100
        deny_access     = false
        cidr_block      = "0.0.0.0/0"
        ipv6_cidr_block = null
        from_port       = 0
        to_port         = 0
        icmp_type       = null
        icmp_code       = null
      },
    ],
  },
]

nacl_ingress_rules = [
  {
    nacl_name     = "default"
    nacl_vpc_name = "Larry test VPC"
    nacl_vpc_id   = null
    nacl_subnets  = ["Larry Test Subnet 3"]
    nacl_rules = [ 
      {
        protocol        = "all"
        rule_number     = 100
        deny_access     = false
        cidr_block      = "0.0.0.0/0"
        ipv6_cidr_block = null
        from_port       = -1
        to_port         = -1
        icmp_type       = null
        icmp_code       = null
      },
    ],
  },
]

nat_gateways = [
  {
    name              = "sample NAT gateway"
    has_elastic_ip    = true
    is_public         = true
    tags              = { "Type" = "Example" }
    vpc_name          = "Larry test VPC"
    subnet_name_or_id = "Larry Test Subnet 3"
  },
]

vpc_peering = [
  {
    name = "sample VPC peering"
    requestor_vpc_name_or_id              = "Larry test VPC"
    peer_vpc_name_or_id                   = "Larry test VPC 2"
    peer_owner_id                         = null
    auto_accept                           = true
    peer_region                           = null
    accepter_allow_remote_dns_resolution  = false
    requester_allow_remote_dns_resolution = false
    tags                                  = { "Name" : "VPC peering example" }
  },
]

vpc_endpoints = [
  {
    name                = "Sample S3 Gateway endpoint"
    service_name        = "com.amazonaws.us-east-1.s3"
    vpc_id              = null
    vpc_name            = "Larry test VPC"
    auto_accept         = true
    private_dns_enabled = true
    security_group_ids  = null
    vpc_endpoint_type   = "Gateway"
    tags                = { "Type" = "Sample" }

    subnets = [
      {
        name = "Larry Test Subnet"
        id = null
      },
    ]
  },
]

transit_gateways = [
  {
    name                                   = "sample transit gateway"
    description                            = "sample transit gateway"
    tags                                   = {"Type" = "Sample"}
    amazon_side_asn                        = null
    auto_accept_shared_attachments         = false
    enable_default_route_table_association = false
    enable_default_route_table_propagation = false
    enable_dns_support                     = true
    enable_vpn_ecmp_support                = false
  },
]

transit_gateway_vpc_attachments = [
  {
    name                                                   = "sample transit gateway to Larry test VPC attachment"
    transit_gateway_name_or_id                             = "sample transit gateway"
    vpc_name                                               = "Larry test VPC"
    subnets                                                = ["Larry Test Subnet"]
    vpc_id                                                 = null
    tags                                                   = { "Type" = "Example, do not use" }
    enable_appliance_mode_support                          = false
    enable_dns_support                                     = true
    enable_ipv6_support                                    = false
    enable_transit_gateway_default_route_table_association = false
    enable_transit_gateway_default_route_table_propagation = false
  },
]
