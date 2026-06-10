variable "tenant_domain" {
  type = string
}

variable "initial_password" {
  type      = string
  sensitive = true
}