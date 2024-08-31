locals {
  common_tags = {
    company     = var.company
    project     = var.project
    environment = var.environment
    createdby   = var.createdby
  }
}

# Local variables for Security VPC
locals {
  security_vpc_azs = slice(data.aws_availability_zones.available.names, 0, var.security_vpc_az_count)
  #security_public_cidr = cidrsubnet(var.security_vpc_cidr, 12, var.security_vpc_subnets_count)
  security_cidr_blocks = [for subnet in range(var.security_vpc_subnets_count) : cidrsubnet(var.security_vpc_cidr, 8, subnet)]
  # distribute each of the /24 among the availavbility zones
  security_wan_cidr        = [for subnet in range(var.security_vpc_az_count) : cidrsubnet(local.security_cidr_blocks[0], 4, subnet)]
  security_lan_cidr        = [for subnet in range(var.security_vpc_az_count) : cidrsubnet(local.security_cidr_blocks[1], 4, subnet)]
  security_ha-mgmt_cidr    = [for subnet in range(var.security_vpc_az_count) : cidrsubnet(local.security_cidr_blocks[2], 4, subnet)]
  security_lb_cidr         = [for subnet in range(var.security_vpc_az_count) : cidrsubnet(local.security_cidr_blocks[3], 4, subnet)]
  security_tgw-attach_cidr = [for subnet in range(var.security_vpc_az_count) : cidrsubnet(local.security_cidr_blocks[4], 4, subnet)]
}

# Local variables for Protected VPCs
locals {
  protected_vpc_azs = slice(data.aws_availability_zones.available.names, 0, var.protected_vpc_az_count)

  # protected vpc-1, lets keep x.0.0.0/24 for public if we need one
  protected_1_public_cidr     = [for subnet in range(var.protected_vpc_az_count) : cidrsubnet(var.protected_vpc_cidrs[0], 8, subnet + 0)][0]
  protected_1_resources_cidr  = [for subnet in range(var.protected_vpc_az_count) : cidrsubnet(var.protected_vpc_cidrs[0], 8, subnet + 1)]
  protected_1_apps_cidr       = [for subnet in range(var.protected_vpc_az_count) : cidrsubnet(var.protected_vpc_cidrs[0], 8, subnet + var.protected_vpc_az_count + 1)]
  protected_1_tgw_attach_cidr = [for subnet in range(var.protected_vpc_az_count) : cidrsubnet(var.protected_vpc_cidrs[0], 8, subnet + 2 * var.protected_vpc_az_count + 1)]

  # protected vpc-2
  protected_2_resources_cidr  = [for subnet in range(var.protected_vpc_az_count) : cidrsubnet(var.protected_vpc_cidrs[1], 8, subnet + 1)]
  protected_2_apps_cidr       = [for subnet in range(var.protected_vpc_az_count) : cidrsubnet(var.protected_vpc_cidrs[1], 8, subnet + var.protected_vpc_az_count + 1)]
  protected_2_tgw_attach_cidr = [for subnet in range(var.protected_vpc_az_count) : cidrsubnet(var.protected_vpc_cidrs[1], 8, subnet + 2 * var.protected_vpc_az_count + 1)]
}

# For the GRE-BGP tunnel from tgw-connect to the firewalls.

locals {
  tgw_connect_peer_1_GRE_address     = cidrhost(local.security_lan_cidr[0], 5) #LAN of firewall 1
  tgw_connect_peer_2_GRE_address     = cidrhost(local.security_lan_cidr[1], 5) #LAN of firewall 2
  tgw_connect_GRE_address_subnet     = cidrsubnet(var.transit_gateway_cidr_blocks[0], 6, 0)
  tgw_connect_GRE_address_for_peer_1 = cidrhost(local.tgw_connect_GRE_address_subnet, 1)
  tgw_connect_GRE_address_for_peer_2 = cidrhost(local.tgw_connect_GRE_address_subnet, 2)
}