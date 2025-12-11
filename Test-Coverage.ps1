<#
.SYNOPSIS
    Runs tests, checks for missing dependencies, collects coverage, and generates a report.

.DESCRIPTION
    This cmdlet runs dotnet test with specific filters for Namespaces, Classes, or Methods.
    It collects code coverage using XPlat Code Coverage and generates an HTML report using ReportGenerator.

.PARAMETER TestNamespace
    Part of the namespace to filter tests (e.g., "MyApp.UnitTests").
    Passed to dotnet test --filter "FullyQualifiedName~Value".

.PARAMETER TestClass
    The specific test class to run.
    Passed to dotnet test --filter "FullyQualifiedName~Value".

.PARAMETER TestMethod
    The specific test method to run.
    Passed to dotnet test --filter "FullyQualifiedName~Value".

.PARAMETER CoverNamespace
    The namespace of your actual code (not the test) to include in the coverage report.
    passed to ReportGenerator -classfilters:"+Value*"

.PARAMETER CoverClass
    The specific class of your actual code to include in the coverage report.
    passed to ReportGenerator -classfilters:"+*.Value"

.EXAMPLE
    .\Test-Coverage.ps1 -TestClass "OrderServiceTests" -CoverClass "OrderService"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, HelpMessage="Filter tests by Namespace.")]
    [string]$TestNamespace,

    [Parameter(Mandatory=$false, HelpMessage="Filter tests by Class name.")]
    [string]$TestClass,

    [Parameter(Mandatory=$false, HelpMessage="Filter tests by Method name.")]
    [string]$TestMethod,

    [Parameter(Mandatory=$false, HelpMessage="Filter coverage report by Namespace.")]
    [string]$CoverNamespace,

    [Parameter(Mandatory=$false, HelpMessage="Filter coverage report by Class.")]
    [string]$CoverClass
)

Set-Location $PSScriptRoot

# --- Configuration ---
$toolsDir       = Join-Path $PSScriptRoot ".tools"
$reportDir      = Join-Path $PSScriptRoot "coverage"
$testResultsDir = Join-Path $PSScriptRoot "TestResults"
$reportGenName  = "dotnet-reportgenerator-globaltool"

# --- 1. Prerequisite Check: Coverlet ---
# Scan for the package reference to avoid the confusing "Data collector not found" error
$projFiles = Get-ChildItem *.csproj -Recurse
if ($projFiles) {
    $hasCoverlet = Select-String -Path $projFiles.FullName -Pattern "coverlet.collector" -SimpleMatch -Quiet
    if (-not $hasCoverlet) {
        Write-Host "ERROR: Missing 'coverlet.collector' package." -ForegroundColor Red
        Write-Host "Run this in your test project: dotnet add package coverlet.collector" -ForegroundColor Yellow
        exit 1
    }
}

# --- 2. Setup: Install ReportGenerator locally (Portable) ---
if (-not (Test-Path "$toolsDir\reportgenerator.exe") -and -not (Test-Path "$toolsDir\reportgenerator")) {
    Write-Host "Installing ReportGenerator locally to '$toolsDir'..." -ForegroundColor Cyan
    dotnet tool install $reportGenName --tool-path $toolsDir
}

# --- 3. Cleanup ---
Write-Host "Cleaning up previous results..." -ForegroundColor Gray
if (Test-Path $reportDir) { Remove-Item $reportDir -Recurse -Force | Out-Null }
if (Test-Path $testResultsDir) { Remove-Item $testResultsDir -Recurse -Force | Out-Null }

# --- 4. Execution: Run Tests ---
Write-Host "Running tests..." -ForegroundColor Cyan

# Prepare Test Filter
# We use logic AND (&) so we can drill down: Namespace -> Class -> Method
$filterParts = @()
if (-not [string]::IsNullOrWhiteSpace($TestNamespace)) { $filterParts += "FullyQualifiedName~$TestNamespace" }
if (-not [string]::IsNullOrWhiteSpace($TestClass))     { $filterParts += "FullyQualifiedName~$TestClass" }
if (-not [string]::IsNullOrWhiteSpace($TestMethod))    { $filterParts += "FullyQualifiedName~$TestMethod" }

# Build Args
$testArgs = @("test", "--collect", "XPlat Code Coverage")

if ($filterParts.Count -gt 0) {
    $filterString = $filterParts -join "&"
    Write-Verbose "Applying Test Filter: $filterString"
    $testArgs += "--filter"
    $testArgs += $filterString
}

# Run Dotnet Test
& dotnet $testArgs

# Check exit code immediately
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed. Report generation skipped." -ForegroundColor Red
    exit $LASTEXITCODE
}

# --- 5. Reporting: Generate HTML ---
Write-Host "Tests finished. Generating report..." -ForegroundColor Cyan

# Determine the correct local executable path
$genCommand = "$toolsDir\reportgenerator"
if ($IsWindows) { $genCommand = "$toolsDir\reportgenerator.exe" }

# Prepare Coverage Filter (ReportGenerator -classfilters)
# Defaults to "+*" (include everything) if no params provided
$covFilters = @()
if (-not [string]::IsNullOrWhiteSpace($CoverNamespace)) { $covFilters += "+${CoverNamespace}*" }
if (-not [string]::IsNullOrWhiteSpace($CoverClass))     { $covFilters += "+*.${CoverClass}" }

$finalClassFilter = "+*"
if ($covFilters.Count -gt 0) {
    # Combine with semicolon (ReportGenerator syntax)
    $finalClassFilter = $covFilters -join ";"
}

Write-Verbose "Applying Coverage Filter: $finalClassFilter"

# Run ReportGenerator
& $genCommand -reports:"$testResultsDir\**\coverage.cobertura.xml" `
              -targetdir:$reportDir `
              -reporttypes:Html `
              -classfilters:$finalClassFilter

# --- 6. Finish ---
$reportFile = "$reportDir\index.html"
if (Test-Path $reportFile) {
    Write-Host "Success! Opening report: $reportFile" -ForegroundColor Green
    Invoke-Item $reportFile
} else {
    Write-Host "Report file not found. Something went wrong generating the report." -ForegroundColor Red
}
