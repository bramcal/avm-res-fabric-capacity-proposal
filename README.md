<!-- BEGIN_TF_DOCS -->
# Microsoft Fabric Capacity Resource Module Proposal

Creates one Azure Microsoft Fabric capacity with AzAPI and exposes AVM-style resource interfaces.

> [!IMPORTANT]
> This repository is an AVM-aligned draft, not a published or verified Azure Verified Module. It was extracted from the [avm-unified-data-platform-proposal](https://github.com/bramcal/avm-unified-data-platform-proposal) pattern repository so it can go through the official AVM resource-module proposal, review, and publication process independently. See [Azure Verified Modules — Contributing (Terraform)](https://azure.github.io/Azure-Verified-Modules/contributing/terraform/) for the requirements this repository is being checked against.

## Resource Contract

- Resource type: `Microsoft.Fabric/capacities@2023-11-01` by default.
- Parent: existing resource-group resource ID.
- SKU: supported Fabric F SKU with fixed `Fabric` tier.
- Administrators: Entra user UPNs or service-principal object IDs. Entra groups are not accepted by the capacity ARM API.
- Shared interfaces: `Azure/avm-utl-interfaces/azure` v0.6.0 for management locks and ARM role assignments.
- Operations: telemetry, tags, configurable retry behavior, and timeouts.
- Outputs: name, location, resource ID, and the full AzAPI resource.

Tenant settings are intentionally excluded. They are tenant-scoped Fabric API resources and are managed once by the data-management-landing-zone tenant-settings child module in the source pattern repository.

## Example

```hcl
module "capacity" {
  source = "git::https://github.com/bramcal/avm-res-fabric-capacity-proposal.git"

  administration_members = ["fabric-admin@contoso.com"]
  location               = "westeurope"
  name                   = "fcsharedprod"
  parent_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-fabric-prod"
  sku_name               = "F64"
  lock                   = { kind = "CanNotDelete" }
}
```

See [examples/default](examples/default) for a runnable configuration.

## Validation

```powershell
terraform init -backend=false
terraform validate
terraform test
```

Publication still requires the official AVM proposal, ownership metadata, compliance tooling, review, and live Azure integration evidence.
<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.11.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.4.0)
## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (~> 2.11.0)

- <a name="provider_modtm"></a> [modtm](#provider\_modtm) (~> 0.4.0)
## Resources

The following resources are used by this module:

- [azapi_resource.lock](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.role_assignments](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.this](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [modtm_telemetry.this](https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry) (resource)
- [azapi_client_config.current](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/client_config) (data source)
<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_administration_members"></a> [administration\_members](#input\_administration\_members)

Description: Fabric capacity administrators. Use a user principal name for an Entra user or an object ID for a service principal.

Type: `set(string)`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region for the Fabric capacity.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the Fabric capacity.

Type: `string`

### <a name="input_parent_id"></a> [parent\_id](#input\_parent\_id)

Description: Resource ID of the resource group in which to create the Fabric capacity.

Type: `string`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: Fabric F SKU for the capacity.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: Controls whether anonymous module usage telemetry is enabled.

Type: `bool`

Default: `true`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Management lock applied to the Fabric capacity.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_resource_types"></a> [resource\_types](#input\_resource\_types)

Description: AzAPI resource types used by this module. Override only when validating a supported API migration.

Type:

```hcl
object({
    fabric_capacities = optional(string, "Microsoft.Fabric/capacities@2023-11-01")
  })
```

Default: `{}`

### <a name="input_retry"></a> [retry](#input\_retry)

Description: Retry configuration for AzAPI resource operations.

Type:

```hcl
object({
    error_message_regex  = optional(list(string), ["409 Conflict", "429 Too Many Requests"])
    interval_seconds     = optional(number, null)
    max_interval_seconds = optional(number, null)
  })
```

Default: `{}`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: ARM role assignments to create on the Fabric capacity.

Type:

```hcl
map(object({
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
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Azure tags applied to the Fabric capacity.

Type: `map(string)`

Default: `{}`

### <a name="input_timeouts"></a> [timeouts](#input\_timeouts)

Description: Timeouts for Fabric capacity, lock, and role-assignment operations.

Type:

```hcl
object({
    create = optional(string, "30m")
    delete = optional(string, "30m")
    read   = optional(string, "5m")
    update = optional(string, "30m")
  })
```

Default: `{}`
## Outputs

The following outputs are exported:

### <a name="output_location"></a> [location](#output\_location)

Description: Azure region of the Fabric capacity.

### <a name="output_name"></a> [name](#output\_name)

Description: Name of the Fabric capacity.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: Full AzAPI Fabric capacity resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: Azure resource ID of the Fabric capacity.
## Modules

The following Modules are called:

### <a name="module_interfaces"></a> [interfaces](#module\_interfaces)

Source: Azure/avm-utl-interfaces/azure

Version: 0.6.0
## Notes

### Unsupported AVM extension resources (RMFR4)

[AVM resource-module spec RMFR4](https://azure.github.io/Azure-Verified-Modules/spec/RMFR4) requires resource modules to support `diagnostic_settings`, `role_assignments`, `lock`, `tags`, `managed_identities`, `private_endpoints`, and `customer_managed_key`, where the underlying Azure resource supports them. This module implements `role_assignments`, `lock`, and `tags`. It intentionally does **not** implement `diagnostic_settings`, `managed_identities`, `private_endpoints`, or `customer_managed_key`, because `Microsoft.Fabric/capacities` does not support them:

- **Managed identities** — the `Microsoft.Fabric/capacities` ARM schema (checked against both the `2023-11-01` GA and `2025-01-15-preview` API versions) has no `identity` block. There is no system-assigned or user-assigned identity to attach.
- **Private endpoints** — the resource schema exposes no `privateEndpointConnections` or `publicNetworkAccess` property, and Fabric's private-link surface (`Microsoft.Fabric/privateLinkServicesForFabric`) is a workspace-level concept, not a capacity-level one. A capacity cannot itself be the target of a private endpoint.
- **Customer-managed keys** — the resource schema has no encryption/CMK-related properties.
- **Diagnostic settings** — Azure Monitor does not publish supported metric or log categories for `Microsoft.Fabric/capacities`, so there is no `Microsoft.Insights/diagnosticSettings` target to wire up.

The published Microsoft-owned Bicep AVM module for the same resource type ([`avm/res/fabric/capacity`](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/fabric/capacity)) corroborates this: it implements only `name`, `location`, `tags`, `sku`, `administration.members`, `lock`, and telemetry — no identity, private endpoint, CMK, or diagnostic-settings support either.

If a future Fabric capacities API version adds any of these capabilities, this module should be updated to add the corresponding interface at that time.

### Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the [repository](https://aka.ms/avm/telemetry). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->