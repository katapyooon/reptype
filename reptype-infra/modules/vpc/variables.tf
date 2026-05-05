variable "cidr_block" {
  type = string
}

variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {}
}
