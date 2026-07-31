output "location" {
  description = "Azure region of the Fabric capacity."
  value       = azapi_resource.this.location
}

output "name" {
  description = "Name of the Fabric capacity."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "Full AzAPI Fabric capacity resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "Azure resource ID of the Fabric capacity."
  value       = azapi_resource.this.id
}