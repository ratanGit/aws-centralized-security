# Management Access to Security VPC
resource "aws_security_group" "public_allow" {
  name        = "Public Allow"
  description = "Public Allow traffic"
  vpc_id      = aws_vpc.security-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "mgmt-PublicAccess-sg" })
}
resource "aws_security_group" "private_allow" {
  name        = "Private Allow"
  description = "Private Allow traffic"
  vpc_id      = aws_vpc.security-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "security-private-sg" })
}
# protected VPC Bastion access--------------------------------------------------
resource "aws_security_group" "bastion_allow-sg" {
  name        = "Protected-Bastion-Allow"
  description = "Bastion Allow traffic"
  vpc_id      = aws_vpc.protected-vpcs[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "prtoected-1-Bastion-sg" })
}

resource "aws_security_group" "protected-2-private-sg" {
  name        = "Protected-2-Private-Allow"
  description = "Private Allow traffic"
  vpc_id      = aws_vpc.protected-vpcs[1].id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"] #[aws_vpc.protected-vpcs[0].cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "private-sg" })
}