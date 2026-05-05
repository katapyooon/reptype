variable "db_identifier" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "max_allocated_storage" {
  type    = number
  default = 0
}

variable "storage_type" {
  type    = string
  default = "gp2"
}

variable "storage_encrypted" {
  type    = bool
  default = true
}

variable "username" {
  type = string
}

variable "subnet_group_name" {
  type = string
}

variable "subnet_group_description" {
  type    = string
  default = "Managed by Terraform"
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "copy_tags_to_snapshot" {
  type    = bool
  default = true
}

variable "enabled_cloudwatch_logs_exports" {
  type    = list(string)
  default = []
}
