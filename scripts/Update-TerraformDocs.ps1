[CmdletBinding()]
param(
    [string] $TerraformDocsPath
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$terraformDocs = if ($TerraformDocsPath) {
    $TerraformDocsPath
}
else {
    (Get-Command terraform-docs -ErrorAction Stop).Source
}
$modulePaths = @(
    "."
)

Push-Location $repositoryRoot
try {
    foreach ($modulePath in $modulePaths) {
        & $terraformDocs --config .terraform-docs.yml $modulePath
        if ($LASTEXITCODE -ne 0) {
            throw "terraform-docs failed for $modulePath."
        }
    }
}
finally {
    Pop-Location
}
