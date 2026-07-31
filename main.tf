data "azapi_client_config" "current" {}

module "interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.6.0"

  enable_telemetry                 = var.enable_telemetry
  lock                             = var.lock
  role_assignment_definition_scope = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  role_assignments                 = var.role_assignments
}

resource "azapi_resource" "this" {
  type      = var.resource_types.fabric_capacities
  name      = var.name
  parent_id = var.parent_id
  location  = var.location
  tags      = var.tags
  body = {
    properties = {
      administration = {
        members = sort(tolist(var.administration_members))
      }
    }
    sku = {
      name = var.sku_name
      tier = "Fabric"
    }
  }
  replace_triggers_refs = []
  response_export_values = [
    "id",
    "location",
    "name",
    "properties",
    "sku",
  ]
  retry = var.retry

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}

resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  type                   = module.interfaces.lock_azapi.type
  name                   = coalesce(module.interfaces.lock_azapi.name, "lock-${var.lock.kind}")
  parent_id              = azapi_resource.this.id
  body                   = module.interfaces.lock_azapi.body
  replace_triggers_refs  = []
  response_export_values = []
  retry                  = var.retry

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}

resource "azapi_resource" "role_assignments" {
  for_each = module.interfaces.role_assignments_azapi

  type                   = each.value.type
  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  body                   = each.value.body
  replace_triggers_refs  = []
  response_export_values = []
  retry                  = var.retry

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}