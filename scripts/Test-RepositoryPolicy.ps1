[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
    ".github/CODEOWNERS",
    ".github/workflows/compliance.yml",
    ".github/workflows/terraform.yml",
    ".gitignore",
    ".terraform-docs.yml",
    ".tflint.hcl",
    "CONTRIBUTING.md",
    "LICENSE",
    "README.md",
    "SECURITY.md"
)

foreach ($relativePath in $requiredFiles) {
    $path = Join-Path $repositoryRoot $relativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required repository file is missing: $relativePath"
    }
}

$lockFile = Join-Path $repositoryRoot "examples/default/.terraform.lock.hcl"
if (-not (Test-Path -LiteralPath $lockFile -PathType Leaf)) {
    throw "The examples/default dependency lock file must be committed: $lockFile"
}

& git -C $repositoryRoot check-ignore --quiet -- $lockFile
if ($LASTEXITCODE -eq 0) {
    throw "The examples/default dependency lock file must not be ignored: $lockFile"
}

& git -C $repositoryRoot check-ignore --quiet -- ".terraform.lock.hcl"
if ($LASTEXITCODE -ne 0) {
    throw "The root module dependency lock file must be ignored because this module is sourced, not initialized directly."
}

$directAzureResources = Get-ChildItem -Path $repositoryRoot -Recurse -File -Filter "*.tf" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch "[\\/]\.terraform[\\/]" } |
    Select-String -Pattern '^resource\s+"azurerm_'
if ($directAzureResources) {
    $locations = $directAzureResources | ForEach-Object { "$($_.Path):$($_.LineNumber)" }
    throw "Direct AzureRM resources are not allowed in this AzAPI-based resource module:`n$($locations -join "`n")"
}
