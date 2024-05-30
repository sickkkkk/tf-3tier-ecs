variable cluster_name {
  type = string
  description = "Name of backend cluster"
}

variable env {
  type = string
  description = "Environment description"
}

variable region {
  type        = string
  description = "Default region for resource allocation"
}

variable service_discovery_private_fqdn {
  type = string
  description = "Internal FQDN for service discovery"
}

variable "vpc_id" {
  type = string
}
