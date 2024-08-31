# route tables Security VPC
resource "aws_route_table" "security-rt-public" {
  vpc_id = aws_vpc.security-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.security-vpc-igw.id
  }

  tags = merge(local.common_tags, { Name = "${var.secuirty_vpc_name}-rt-public" })
}
# route table association Security VPC
resource "aws_route_table_association" "security-rt-association-wan" {
  count          = length(local.security_vpc_azs)
  subnet_id      = element(aws_subnet.security-vpc-wan-subnets.*.id, count.index)
  route_table_id = aws_route_table.security-rt-public.id
}
resource "aws_route_table_association" "security-rt-association-ha" {
  count          = length(local.security_vpc_azs)
  subnet_id      = element(aws_subnet.security-vpc-ha-subnets.*.id, count.index)
  route_table_id = aws_route_table.security-rt-public.id
}

#private route table for lan subnets
resource "aws_route_table" "security-rt-lan" {
  vpc_id = aws_vpc.security-vpc.id
  route {
    cidr_block         = local.tgw_connect_GRE_address_subnet
    transit_gateway_id = aws_ec2_transit_gateway.security-tgw.id
  }
  depends_on = [aws_ec2_transit_gateway.security-tgw]

  tags = merge(local.common_tags, { Name = "${var.secuirty_vpc_name}-rt-lan" })
}
#private route table association
resource "aws_route_table_association" "security-rt-association-lan" {
  count          = length(local.security_vpc_azs)
  subnet_id      = element(aws_subnet.security-vpc-lan-subnets.*.id, count.index)
  route_table_id = aws_route_table.security-rt-lan.id
}
#private route table for internal_lb subnets
resource "aws_route_table" "security-rt-internal-lb" {
  vpc_id = aws_vpc.security-vpc.id

  tags = merge(local.common_tags, { Name = "${var.secuirty_vpc_name}-rt-internal-lb" })
}
#private route table association for internal_lb subnets
resource "aws_route_table_association" "security-rt-association-internal-lb" {
  count          = length(local.security_vpc_azs)
  subnet_id      = element(aws_subnet.security-vpc-internal_lb-subnets.*.id, count.index)
  route_table_id = aws_route_table.security-rt-internal-lb.id
}
#private route table for tgw_attach subnets
resource "aws_route_table" "security-rt-tgw_attach" {
  vpc_id = aws_vpc.security-vpc.id

  tags = merge(local.common_tags, { Name = "${var.secuirty_vpc_name}-rt-tgw_attach" })
}
#private route table association for tgw_attach subnets
resource "aws_route_table_association" "security-rt-association-tgw_attach" {
  count          = length(local.security_vpc_azs)
  subnet_id      = element(aws_subnet.security-vpc-tgw_attach-subnets.*.id, count.index)
  route_table_id = aws_route_table.security-rt-tgw_attach.id
}

