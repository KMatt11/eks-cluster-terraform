###### vpc/outputs.tf 

output "public_subnets" {
  value = aws_subnet.eks_public_subnets.*.id
}

output "private_subnets" {
  value = aws_subnet.eks_private_subnets.*.id
}

output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}