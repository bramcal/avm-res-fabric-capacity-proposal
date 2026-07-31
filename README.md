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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9, < 2.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.11.0 |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) | ~> 0.4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.11.0 |
| <a name="provider_modtm"></a> [modtm](#provider\_modtm) | 0.4.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_interfaces"></a> [interfaces](#module\_interfaces) | Azure/avm-utl-interfaces/azure | 0.6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azapi_resource.lock](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.role_assignments](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.this](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [modtm_telemetry.this](https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry) | resource |
| [azapi_client_config.current](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_administration_members"></a> [administration\_members](#input\_administration\_members) | Fabric capacity administrators. Use a user principal name for an Entra user or an object ID for a service principal. | `set(string)` | n/a | yes |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | Controls whether anonymous module usage telemetry is enabled. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Fabric capacity. | `string` | n/a | yes |
| <a name="input_lock"></a> [lock](#input\_lock) | Management lock applied to the Fabric capacity. | <pre>object({<br/>    kind = string<br/>    name = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Fabric capacity. | `string` | n/a | yes |
| <a name="input_parent_id"></a> [parent\_id](#input\_parent\_id) | Resource ID of the resource group in which to create the Fabric capacity. | `string` | n/a | yes |
| <a name="input_resource_types"></a> [resource\_types](#input\_resource\_types) | AzAPI resource types used by this module. Override only when validating a supported API migration. | <pre>object({<br/>    fabric_capacities = optional(string, "Microsoft.Fabric/capacities@2023-11-01")<br/>  })</pre> | `{}` | no |
| <a name="input_retry"></a> [retry](#input\_retry) | Retry configuration for AzAPI resource operations. | <pre>object({<br/>    error_message_regex  = optional(list(string), ["409 Conflict", "429 Too Many Requests"])<br/>    interval_seconds     = optional(number, null)<br/>    max_interval_seconds = optional(number, null)<br/>  })</pre> | `{}` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | ARM role assignments to create on the Fabric capacity. | <pre>map(object({<br/>    name                                   = optional(string, null)<br/>    role_definition_id_or_name             = string<br/>    principal_id                           = string<br/>    description                            = optional(string, null)<br/>    skip_service_principal_aad_check       = optional(bool, false)<br/>    condition                              = optional(string, null)<br/>    condition_version                      = optional(string, null)<br/>    delegated_managed_identity_resource_id = optional(string, null)<br/>    principal_type                         = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Fabric F SKU for the capacity. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure tags applied to the Fabric capacity. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeouts for Fabric capacity, lock, and role-assignment operations. | <pre>object({<br/>    create = optional(string, "30m")<br/>    delete = optional(string, "30m")<br/>    read   = optional(string, "5m")<br/>    update = optional(string, "30m")<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_location"></a> [location](#output\_location) | Azure region of the Fabric capacity. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Fabric capacity. |
| <a name="output_resource"></a> [resource](#output\_resource) | Full AzAPI Fabric capacity resource. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | Azure resource ID of the Fabric capacity. |

### Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the [repository](https://aka.ms/avm/telemetry). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->