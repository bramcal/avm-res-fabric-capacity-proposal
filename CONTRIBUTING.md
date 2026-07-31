# Contributing

This repository is a proposal-stage Azure Verified Module (AVM) resource module for `Microsoft.Fabric/capacities`. Do not describe it as an Azure Verified Module until it completes the official AVM proposal, review, and publication process at [Azure/Azure-Verified-Modules](https://azure.github.io/Azure-Verified-Modules/contributing/terraform/).

## Required Checks

Install Terraform 1.15.8, TFLint 0.64.0, and terraform-docs 0.24.0. The local script discovers tools on `PATH`, Terraform installed by WinGet, and repository-local TFLint and terraform-docs binaries under the ignored `.tools` directory.

Run the complete local gate before submitting a change:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
./scripts/Test-LocalCompliance.ps1
```

The script runs formatting, TFLint, generated-reference and repository-policy checks, and validation and mocked tests for the root module and the `examples/default` example. It never runs `terraform apply`.

Do not commit a dependency lock file for this repository's own root module, because consumers source it through `source = "..."` instead of initializing it directly. Commit the lock file only for the directly initialized `examples/default` configuration.

## Generated References

Regenerate the module reference after changing resources, inputs, outputs, or provider requirements:

```powershell
./scripts/Update-TerraformDocs.ps1
```

Review generated changes and rerun the command to confirm it is idempotent.

## Security and Scope

Never commit environment identifiers or credentials. This module creates exactly one `Microsoft.Fabric/capacities` resource plus its associated lock and role assignments through shared AVM interfaces; it intentionally excludes tenant-wide Fabric settings, which are tenant-scoped and managed elsewhere.
