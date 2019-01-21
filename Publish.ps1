$PublishParams = @{
    Path = "$(Get-Location)\PowershellRetry"
    NuGetApiKey = $env:PowershellGalleryApiKey
}

# There is no way to exclude files, so move the files were are interested in to a temporary location
mkdir PowershellRetry
mkdir PowershellRetry/Public
cp PowershellRetry.psd1 PowershellRetry
cp PowershellRetry.psm1 PowershellRetry
cp Public/Retry.ps1 PowershellRetry/Public

# Publish the module
Publish-Module @PublishParams

# Clear the temporary files
rm -Recurse PowershellRetry