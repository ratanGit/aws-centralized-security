output "bastion-host-public-ip" {
    value = join("", tolist(["ssh -i ", "${local_file.ssh_private_key.filename}", " ubuntu@", "${aws_instance.protected-1-bation.public_dns}"]))
    description = "Bastion Host Public IP"
}

output "Test-host-private-ip" {
    value = join("", tolist(["Try pinging to the host in Protected-vpc-2 with IP:", "${aws_instance.protected-2-test.private_ip}", " ubuntu@"]))
    description = "Test-host-private-ip"
}