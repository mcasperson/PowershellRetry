$PublishParams = @{
    Path = 'C:\Users\Matthew\Development\PowershellRetry'
    NuGetApiKey = $env:PowershellGalleryApiKey
}

Publish-Module @PublishParams