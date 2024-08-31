resource "aws_vpc" "protected-vpcs" {
  count                = length(var.protected_vpc_names)
  cidr_block           = var.protected_vpc_cidrs[count.index]
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(local.common_tags, { Name = "${var.protected_vpc_names[count.index]}" })
}
resource "aws_internet_gateway" "protected-vpcs-igws" {
  count  = length(var.protected_vpc_names)
  vpc_id = aws_vpc.protected-vpcs[count.index].id
  tags   = merge(local.common_tags, { Name = "${var.protected_vpc_names[count.index]}-igw" })
}
# lets creat a public subnet for testing using a Bastion host-----------------------------------------
resource "aws_subnet" "protected-vpc-1-public" {

  vpc_id                  = aws_vpc.protected-vpcs[0].id
  cidr_block              = local.protected_1_public_cidr
  availability_zone       = local.protected_vpc_azs[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "${var.protected_vpc_names[0]}-public-subnet" })
}

# Protected VPC -1 Private subnets.................................
resource "aws_subnet" "protected-vpc-1-resources-subnets" {
  count                   = var.protected_vpc_az_count
  vpc_id                  = aws_vpc.protected-vpcs[0].id
  cidr_block              = local.protected_1_resources_cidr[count.index]
  availability_zone       = local.protected_vpc_azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, { Name = "${var.protected_vpc_names[0]}-private-${local.protected_vpc_azs[count.index]}" })
}

# Protected VPC -1 TGW-Attach subnets.................................
resource "aws_subnet" "protected-vpc-1-tgw_attach-subnets" {
  count                   = var.protected_vpc_az_count
  vpc_id                  = aws_vpc.protected-vpcs[0].id
  cidr_block              = local.protected_1_tgw_attach_cidr[count.index]
  availability_zone       = local.protected_vpc_azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, { Name = "${var.protected_vpc_names[0]}-${var.protected_vpc_subnet_names[2]}-${local.protected_vpc_azs[count.index]}" })
}
# Protected VPC - 1 routing table.................................
resource "aws_route_table" "protected-vpc-private-route-table" {
  vpc_id = aws_vpc.protected-vpcs[0].id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.security-tgw.id
  }

  depends_on = [aws_ec2_transit_gateway.security-tgw]
  tags       = merge(local.common_tags, { Name = "${var.protected_vpc_names[0]}-private-rt" })
}
# Routing table association
resource "aws_route_table_association" "protected-vpc-1-resources-subnets" {
  count          = var.protected_vpc_az_count
  subnet_id      = aws_subnet.protected-vpc-1-resources-subnets[count.index].id
  route_table_id = aws_route_table.protected-vpc-private-route-table.id
}
resource "aws_route_table_association" "protected-vpc-1-tgw_attach-subnets" {
  count          = var.protected_vpc_az_count
  subnet_id      = aws_subnet.protected-vpc-1-tgw_attach-subnets[count.index].id
  route_table_id = aws_route_table.protected-vpc-private-route-table.id
}
# Protected VPC -1 route table for a Bastion host used for testing
resource "aws_route_table" "protected-1-rt-public" {
  vpc_id = aws_vpc.protected-vpcs[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.protected-vpcs-igws[0].id
  }

  tags = merge(local.common_tags, { Name = "${var.protected_vpc_names[0]}-public-rt" })
}
resource "aws_route_table_association" "protected-1-rt-association-public" {
  subnet_id      = aws_subnet.protected-vpc-1-public.id
  route_table_id = aws_route_table.protected-1-rt-public.id
}

# Protected VPV 2 resources--------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "protected-vpc-2-resources-subnets" {
  count                   = var.protected_vpc_az_count
  vpc_id                  = aws_vpc.protected-vpcs[1].id
  cidr_block              = local.protected_2_resources_cidr[count.index]
  availability_zone       = local.protected_vpc_azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, { Name = "${var.protected_vpc_names[1]}-${var.protected_vpc_subnet_names[0]}-${local.protected_vpc_azs[count.index]}" })
}

resource "aws_subnet" "protected-vpc-2-apps-subnets" {
  count                   = var.protected_vpc_az_count
  vpc_id                  = aws_vpc.protected-vpcs[1].id
  cidr_block              = local.protected_2_apps_cidr[count.index]
  availability_zone       = local.protected_vpc_azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, { Name = "${var.protected_vpc_names[1]}-${var.protected_vpc_subnet_names[1]}-${local.protected_vpc_azs[count.index]}" })
}

resource "aws_subnet" "protected-vpc-2-tgw_attach-subnets" {
  count                   = var.protected_vpc_az_count
  vpc_id                  = aws_vpc.protected-vpcs[1].id
  cidr_block              = local.protected_2_tgw_attach_cidr[count.index]
  availability_zone       = local.protected_vpc_azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, { Name = "${var.protected_vpc_names[1]}-${var.protected_vpc_subnet_names[2]}-${local.protected_vpc_azs[count.index]}" })
}
# Protected VPC routing table.................................
resource "aws_route_table" "protected-vpc-2-private-route-table" {
  vpc_id = aws_vpc.protected-vpcs[1].id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.security-tgw.id
  }

  depends_on = [aws_ec2_transit_gateway.security-tgw]
  tags       = merge(local.common_tags, { Name = "${var.protected_vpc_names[1]}-private-rt" })
}
# Routing table association
resource "aws_route_table_association" "protected-vpc-2-resources-subnets" {
  count          = var.protected_vpc_az_count
  subnet_id      = aws_subnet.protected-vpc-2-resources-subnets[count.index].id
  route_table_id = aws_route_table.protected-vpc-2-private-route-table.id
}
resource "aws_route_table_association" "protected-vpc-2-apps-subnets" {
  count          = var.protected_vpc_az_count
  subnet_id      = aws_subnet.protected-vpc-2-apps-subnets[count.index].id
  route_table_id = aws_route_table.protected-vpc-2-private-route-table.id
}
resource "aws_route_table_association" "protected-vpc-2-tgw_attach-subnets" {
  count          = var.protected_vpc_az_count
  subnet_id      = aws_subnet.protected-vpc-2-tgw_attach-subnets[count.index].id
  route_table_id = aws_route_table.protected-vpc-2-private-route-table.id
}
