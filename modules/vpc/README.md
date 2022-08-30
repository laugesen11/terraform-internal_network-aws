Terraform module to create VPCs and subnets they contain.

Files include:
- variable.tf                - sets up the input values to the VPC and subnets
- output.tf                  - returns the VPC and subnet resources created to the parent module
- main.tf                    - Computes local maps for resources to create VPCs and subnets
