output "vpc_id" {
  value = aws_vpc.metacity_vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.metacity_vpc.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.metacity_public[*].id
  description = "The IDs of the public subnets in the VPC"

}

output "private_subnet_ids" {
  value = aws_subnet.metacity_private[*].id
  description = "The IDs of the private subnets in the VPC"
}

output "private_subnet_azs" {
  value = aws_subnet.metacity_private[*].availability_zone
  description = "The availability zones of the private subnets in the VPC"
}