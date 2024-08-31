data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}


# protected-1 bastion host
resource "aws_instance" "protected-1-bation" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.aws-security-lab-public-key.key_name
  subnet_id                   = aws_subnet.protected-vpc-1-public.id
  vpc_security_group_ids      = ["${aws_security_group.bastion_allow-sg.id}"]
  associate_public_ip_address = true
  source_dest_check           = false

  tags = merge(local.common_tags, { Name = "Protected-1-Bastion-host" })
}

# protected-2 test host
resource "aws_instance" "protected-2-test" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.aws-security-lab-public-key.key_name
  subnet_id                   = aws_subnet.protected-vpc-2-apps-subnets[0].id
  vpc_security_group_ids      = ["${aws_security_group.protected-2-private-sg.id}"]
  associate_public_ip_address = false

  tags = merge(local.common_tags, { Name = "Protected-2-Test-host" })
}