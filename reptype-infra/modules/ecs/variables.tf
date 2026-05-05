variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "task_family" {
  type = string
}

variable "task_cpu" {
  type = string
}

variable "task_memory" {
  type = string
}

variable "network_mode" {
  type    = string
  default = "awsvpc"
}

variable "requires_compatibilities" {
  type    = list(string)
  default = ["FARGATE"]
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type    = string
  default = null
}

variable "container_definitions" {
  type        = string
  description = "JSON encoded container definitions"
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "target_group_arn" {
  type = string
}

variable "load_balancer_container_name" {
  type    = string
  default = "nginx"
}

variable "load_balancer_container_port" {
  type    = number
  default = 80
}

variable "capacity_provider" {
  type    = string
  default = "FARGATE_SPOT"
}

variable "capacity_provider_weight" {
  type    = number
  default = 100
}

variable "platform_version" {
  type    = string
  default = "1.4.0"
}

variable "cpu_architecture" {
  type    = string
  default = "X86_64"
}

variable "operating_system_family" {
  type    = string
  default = "LINUX"
}

variable "enable_ecs_managed_tags" {
  type    = bool
  default = true
}

variable "enable_execute_command" {
  type    = bool
  default = true
}
