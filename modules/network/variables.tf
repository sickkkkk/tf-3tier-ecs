variable metacity_vpc_cidr {}
variable region {}
variable env {}
variable vpc_endpoint_ssm_sg_id {
  type = string
  default =""
  description = "ID of SSM endpoints security group"
}