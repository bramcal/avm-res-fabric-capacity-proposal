variable "administration_members" {
  type        = set(string)
  description = "Entra user UPNs or service-principal object IDs that administer the Fabric capacity."
}

variable "location" {
  type        = string
  description = "Azure region for the Fabric capacity."
}

variable "name" {
  type        = string
  description = "Name of the Fabric capacity."
}

variable "parent_id" {
  type        = string
  description = "Resource ID of the existing resource group."
}

variable "sku_name" {
  type        = string
  description = "Fabric F SKU for the capacity."
  default     = "F2"
  nullable    = false
}