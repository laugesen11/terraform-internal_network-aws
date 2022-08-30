# Terraform Private network layout module

- variable.tf                     - Declares variables that define entires network setup
- ouput.tf                        - file for output configuration
- provider.tf                     - file for provider configuration
- main.tf                         - Attaches subnets to route tables and verifies input
- egress_only_internet_gateway.tf - Creates egress only internet gateways for IPv6 addresses
- internet_gateway.tf             - Creates internet gateways
- nat_gateway.tf                  - Creates NAT gateways and EIPs 
- vpn_gateway.tf                  - Creates VPN Gateways 
- transit_gateway.tf              - Creates Transit Gateways and Transit Gateway VPC attachments (must have this to add Transit GW to route table)
- vpc_endpoint.tf                 - Creates VPC endpoints
- vpc_peering.tf                  - Creates VPC peering connections
- vpc.tf                          - Calls the VPC child module to creates VPCs and subnets
- nacl.tf                         - Calls the NACL child module to create and assign Network Access Control Lists
