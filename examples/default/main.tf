module "fabric_capacity" {
  source = "../.."

  administration_members = var.administration_members
  location               = var.location
  name                   = var.name
  parent_id              = var.parent_id
  sku_name               = var.sku_name
}

output "resource_id" {
  description = "Resource ID of the Fabric capacity."
  value       = module.fabric_capacity.resource_id
}