resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "ssh_private_key" {
  filename        = "aws-security-lab.pem"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0400"

}
resource "aws_key_pair" "aws-security-lab-public-key" {
  #key_name_prefix = "aws-security-lab-"
  key_name   = "aws-security-lab"
  public_key = tls_private_key.ssh_key.public_key_openssh
}