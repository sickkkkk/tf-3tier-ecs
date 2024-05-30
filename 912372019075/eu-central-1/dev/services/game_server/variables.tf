variable "container_name" {
  type        = string
  description = "Name of the container within the ECS service; used in task definitions and service configurations."
}

variable "cpu_size" {
  type        = number
  description = "Amount of CPU to allocate to the container; specified in ECS task definitions as 'CPU units'."
}

variable "env" {
  type        = string
  description = "Deploy environment"
}

variable "memory_size" {
  type        = number
  description = "Amount of memory to allocate to the container (in MiB); specified in ECS task definitions."
}

variable "project_name" {
  type        = string
  description = "Project name; used for resource grouping, naming, and tagging."
}

variable "region" {
  type        = string
  description = "Deploy region; AWS region where the resources will be deployed."
}

variable "root_domain_public_fqdn" {
  type        = string
  description = "Top-level root domain (e.g., 'example.com'); used for creating DNS records and service discovery."
}

variable "service_name" {
  type        = string
  description = "Name of the service; used for naming and tagging resources specific to this service."
}

variable "service_port" {
  type        = number
  description = "Network port on which the container will accept traffic; used for load balancer and service discovery configurations."
}

variable "version_tag" {
  type        = string
  description = "Version tag for the deployment; used to tag Docker images or as a parameter in resource tagging to identify version of deployed services."
}
