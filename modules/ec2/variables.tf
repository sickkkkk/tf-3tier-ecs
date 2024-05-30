variable env {}
variable region {}
variable min_instance_count {}
variable desired_count {}
variable max_instance_count {}
variable instance_type {}
variable iam_instance_profile_arn {}
variable sg_id {}
variable instance_kp_name {}
variable ami_id {}
variable nametag_prefix {}
variable vpc_subnet_groups {
  type = list(string)
}
variable templated_userdata_script {
  type = string
  description = "Templated user data script input from root module"
}
variable is_bastion_host {
  type = bool
  description = "Tag value to mark bastion host"
  default = false
}