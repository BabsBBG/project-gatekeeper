variable "tenant_id" {
  description = "e5fbf8c4-7404-49e6-8332-76ef38e737d6"
  type        = string
}

variable "tenant_domain" {
  description = "bbgseclab.onmicrosoft.com"
  type        = string
}

variable "subscription_id" {
  description = "8192c661-6d74-4268-b706-58fda4ed4182"
  type        = string
}

variable "initial_password" {
  description = "Helix@Gatekeeper2026!"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "resource_group" {
  description = "Name of the resource group for Azure resources"
  type        = string
  default     = "hlx-rg-gatekeeper"
}