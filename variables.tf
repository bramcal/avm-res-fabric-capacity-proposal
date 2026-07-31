variable "administration_members" {
  type        = set(string)
  description = "Fabric capacity administrators. Use a user principal name for an Entra user or an object ID for a service principal."
  nullable    = false

  validation {
    condition = length(var.administration_members) > 0 && alltrue([
      for member in var.administration_members :
      can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", member)) ||
      can(regex("(?i)^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$", member))
    ])
    error_message = "administration_members must contain at least one Entra user UPN or service-principal object ID."
  }
}

variable "enable_telemetry" {
  type        = bool
  description = "Controls whether anonymous module usage telemetry is enabled."
  default     = true
  nullable    = false
}

variable "location" {
  type        = string
  description = "Azure region for the Fabric capacity."
  nullable    = false
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  description = "Management lock applied to the Fabric capacity."
  default     = null

  validation {
    condition     = var.lock == null || contains(["CanNotDelete", "ReadOnly"], var.lock.kind)
    error_message = "lock.kind must be CanNotDelete or ReadOnly."
  }
}

variable "name" {
  type        = string
  description = "Name of the Fabric capacity."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,62}$", var.name))
    error_message = "name must be 3-63 lowercase letters or numbers and start with a lowercase letter."
  }
}

variable "parent_id" {
  type        = string
  description = "Resource ID of the resource group in which to create the Fabric capacity."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id))
    error_message = "parent_id must be a valid resource-group resource ID."
  }
}

variable "resource_types" {
  type = object({
    fabric_capacities = optional(string, "Microsoft.Fabric/capacities@2023-11-01")
  })
  description = "AzAPI resource types used by this module. Override only when validating a supported API migration."
  default     = {}
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), ["409 Conflict", "429 Too Many Requests"])
    interval_seconds     = optional(number, null)
    max_interval_seconds = optional(number, null)
  })
  description = "Retry configuration for AzAPI resource operations."
  default     = {}
  nullable    = false
}

variable "role_assignments" {
  type = map(object({
    name                                   = optional(string, null)
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  description = "ARM role assignments to create on the Fabric capacity."
  default     = {}
  nullable    = false
}

variable "sku_name" {
  type        = string
  description = "Fabric F SKU for the capacity."
  nullable    = false

  validation {
    condition     = contains(["F2", "F4", "F8", "F16", "F32", "F64", "F128", "F256", "F512", "F1024", "F2048"], var.sku_name)
    error_message = "sku_name must be a supported Fabric F SKU."
  }
}

variable "tags" {
  type        = map(string)
  description = "Azure tags applied to the Fabric capacity."
  default     = {}
  nullable    = false
}

variable "timeouts" {
  type = object({
    create = optional(string, "30m")
    delete = optional(string, "30m")
    read   = optional(string, "5m")
    update = optional(string, "30m")
  })
  description = "Timeouts for Fabric capacity, lock, and role-assignment operations."
  default     = {}
  nullable    = false
}