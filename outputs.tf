# MyPubEC2_1
output "MyPubEC2_1_public_ip" {
  value = aws_instance.MyPubEC2_1.public_ip
}

output "MyPubEC2_1_public_dns" {
  value = aws_instance.MyPubEC2_1.public_dns
}