[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot

function Resolve-Tool {
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string[]] $FallbackPaths
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    foreach ($fallbackPath in $FallbackPaths) {
        if (Test-Path -LiteralPath $fallbackPath -PathType Leaf) {
            return $fallbackPath
        }
    }

    throw "$Name is required. Install the pinned version documented in CONTRIBUTING.md."
}

function Invoke-Terraform {
    param(
        [Parameter(Mandatory)]
        [string[]] $Arguments,

        [Parameter(Mandatory)]
        [string] $FailureMessage
    )

    $output = @(& $terraform @Arguments 2>&1)
    if ($LASTEXITCODE -ne 0) {
        $output | ForEach-Object { Write-Host $_ }
        throw $FailureMessage
    }

    return $output
}

$terraform = Resolve-Tool -Name "terraform" -FallbackPaths @(
    "$env:LOCALAPPDATA/Microsoft/WinGet/Packages/Hashicorp.Terraform_Microsoft.Winget.Source_8wekyb3d8bbwe/terraform.exe"
)
$tflint = Resolve-Tool -Name "tflint" -FallbackPaths @(
    (Join-Path $repositoryRoot ".tools/tflint/tflint.exe")
)
$terraformDocs = Resolve-Tool -Name "terraform-docs" -FallbackPaths @(
    (Join-Path $repositoryRoot ".tools/terraform-docs/terraform-docs.exe")
)
$testPaths = @(
    "."
)
$examplePaths = @(
    "examples/default"
)

Push-Location $repositoryRoot
try {
    & $terraform fmt -check -recursive
    if ($LASTEXITCODE -ne 0) { throw "terraform fmt check failed." }

    & $tflint --init
    if ($LASTEXITCODE -ne 0) { throw "tflint initialization failed." }
    & $tflint --recursive --format compact
    if ($LASTEXITCODE -ne 0) { throw "tflint failed." }

    & $terraformDocs --version
    if ($LASTEXITCODE -ne 0) { throw "terraform-docs is unavailable." }
    & (Join-Path $PSScriptRoot "Update-TerraformDocs.ps1") -TerraformDocsPath $terraformDocs
    & (Join-Path $PSScriptRoot "Test-RepositoryPolicy.ps1")

    foreach ($testPath in $testPaths) {
        Write-Host "Testing $testPath"
        $null = Invoke-Terraform -Arguments @("-chdir=$testPath", "init", "-backend=false") -FailureMessage "terraform init failed for $testPath."
        $null = Invoke-Terraform -Arguments @("-chdir=$testPath", "validate") -FailureMessage "terraform validate failed for $testPath."
        $null = Invoke-Terraform -Arguments @("-chdir=$testPath", "test") -FailureMessage "terraform test failed for $testPath."
        Write-Host "Tests passed: $testPath"
    }

    foreach ($examplePath in $examplePaths) {
        Write-Host "Validating $examplePath"
        $previousTerraformDataDirectory = $env:TF_DATA_DIR
        $env:TF_DATA_DIR = Join-Path ([System.IO.Path]::GetTempPath()) "avm-res-fabric-capacity/$($examplePath -replace '[^a-zA-Z0-9]', '-')"
        try {
            $null = Invoke-Terraform -Arguments @("-chdir=$examplePath", "init", "-backend=false") -FailureMessage "terraform init failed for $examplePath."
            $null = Invoke-Terraform -Arguments @("-chdir=$examplePath", "validate") -FailureMessage "terraform validate failed for $examplePath."
            Write-Host "Valid configuration: $examplePath"
        }
        finally {
            $env:TF_DATA_DIR = $previousTerraformDataDirectory
        }
    }

    Write-Host "Local compliance checks passed."
}
finally {
    Pop-Location
}
