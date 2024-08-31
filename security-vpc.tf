# 1. create VPCs
resource "aws_vpc" "security-vpc" {
  cidr_block           = var.security_vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = var.secuirty_vpc_name })
}
resource "aws_internet_gateway" "security-vpc-igw" {
  vpc_id = aws_vpc.security-vpc.id
  tags   = merge(local.common_tags, { Name = "${var.secuirty_vpc_name}-igw" })
}
# Public Subnets............................
resource "aws_subnet" "security-vpc-wan-subnets" {
  count                   = length(local.security_vpc_azs)
  vpc_id                  = aws_vpc.security-vpc.id
  cidr_block              = local.security_wan_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = local.security_vpc_azs[count.index]

  tags = merge(local.common_tags, { Name = "security-${var.security_vpc_public_subnet_names[0]}-${local.security_vpc_azs[count.index]}" })
}
resource "aws_subnet" "security-vpc-ha-subnets" {
  count                   = length(local.security_vpc_azs)
  vpc_id                  = aws_vpc.security-vpc.id
  cidr_block              = local.security_ha-mgmt_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = local.security_vpc_azs[count.index]

  tags = merge(local.common_tags, { Name = "security-${var.security_vpc_public_subnet_names[1]}-${local.security_vpc_azs[count.index]}" })
}
# Security private Subnets............................
resource "aws_subnet" "security-vpc-lan-subnets" {
  count                   = var.security_vpc_az_count
  vpc_id                  = aws_vpc.security-vpc.id
  cidr_block              = local.security_lan_cidr[count.index]
  availability_zone       = local.security_vpc_azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, { Name = "security-${var.security_vpc_private_subnet_names[0]}-${local.security_vpc_azs[count.index]}" })
}
resource "aws_subnet" "security-vpc-internal_lb-subnets" {
  count             = var.security_vpc_az_count
  vpc_id            = aws_vpc.security-vpc.id
  cidr_block        = local.security_lb_cidr[count.index]
  availability_zone = local.security_vpc_azs[count.index]

  tags = merge(local.common_tags, { Name = "security-${var.security_vpc_private_subnet_names[1]}-${local.security_vpc_azs[count.index]}" })
}
resource "aws_subnet" "security-vpc-tgw_attach-subnets" {
  count             = var.security_vpc_az_count
  vpc_id            = aws_vpc.security-vpc.id
  cidr_block        = local.security_tgw-attach_cidr[count.index]
  availability_zone = local.security_vpc_azs[count.index]

  tags = merge(local.common_tags, { Name = "security-${var.security_vpc_private_subnet_names[2]}-${local.security_vpc_azs[count.index]}" })
}

