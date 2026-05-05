variable "repositories" {
  type = map(object({
    image_tag_mutability = string
    scan_on_push         = bool
  }))
}
