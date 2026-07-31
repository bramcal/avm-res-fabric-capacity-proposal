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
