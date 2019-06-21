param (
    [string]$NuGetApiKey = $env:PowershellGalleryApiKey,
    [string]$Path = "$(Get-Location)\PowershellRetry"
)

# There is no way to exclude files, so move the files were are interested in to a temporary location
If (Test-Path PowershellRetry){
    Remove-Item -Recurse PowershellRetry
}
mkdir PowershellRetry
mkdir PowershellRetry/Public
cp PowershellRetry.psd1 PowershellRetry
cp PowershellRetry.psm1 PowershellRetry
cp Public/Retry.ps1 PowershellRetry/Public

# Publish the module
Publish-Module -Path $Path -NuGetApiKey $NuGetApiKey -Force

# Clear the temporary files
Remove-Item -Recurse PowershellRetry