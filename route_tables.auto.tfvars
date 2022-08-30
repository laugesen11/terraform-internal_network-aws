route_tables = [
  {
    name             = "sample route table"
    vpc_name_or_id   = "Larry test VPC"
    propagating_vgws = null
    tags             = {}

    routes = [
      {
        cidr_block                 = "0.0.0.0/0"
        ipv6_cidr_block            = null
        destination_prefix_list_id = null
        type                       = "internet gateway"
        destination_name           = null
        destination_id             = null
      },
      {
        cidr_block                 = null
        ipv6_cidr_block            = "::/0"
        destination_prefix_list_id = null
        type                       = "egress only internet gateway"
        destination_name           = null
        destination_id             = null
      },
      {
        cidr_block                 = "192.16.0.0/28"
        ipv6_cidr_block            = null
        destination_prefix_list_id = null
        type                       = "vpn gateway"
        destination_name           = null
        destination_id             = null
      },
      {
        cidr_block                 = "192.16.1.0/28"
        ipv6_cidr_block            = null
        destination_prefix_list_id = null
        type                       = "nat gateway"
        destination_name           = "sample NAT gateway"
        destination_id             = null
      },
      {
        cidr_block                 = "192.16.2.0/28"
        ipv6_cidr_block            = null
        destination_prefix_list_id = null
        type                       = "vpc peering"
        destination_name           = "sample VPC peering"
        destination_id             = null
      },
      {
        cidr_block                 = "192.16.3.0/28"
        ipv6_cidr_block            = null
        destination_prefix_list_id = null
        type                       = "vpc endpoint"
        destination_name           = "Sample S3 Gateway endpoint"
        destination_id             = null
      },
      {
        cidr_block                 = "192.16.4.0/28"
        ipv6_cidr_block            = null
        destination_prefix_list_id = null
        type                       = "transit gateway"
        destination_name           = "sample transit gateway"
        destination_id             = null
      },
    ]
  },
]

