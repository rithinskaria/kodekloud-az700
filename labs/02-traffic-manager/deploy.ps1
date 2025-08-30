$resourceGroup = "rg-az700-tm"
$randomSuffix = -join ((97..122) | Get-Random -Count 6 | % {[char]$_})
$appNamePrefix = "app-az700-tm-$randomSuffix"

$regions = @(
    @{ name = "eastus";       display = "East US";       location = "eastus" },
    @{ name = "westeurope";   display = "West Europe";   location = "westeurope" },
    @{ name = "southeastasia"; display = "Southeast Asia"; location = "southeastasia" }
)

Write-Host "Starting Traffic Manager demo prep deployment..." -ForegroundColor Cyan

if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    Write-Host "Creating resource group in East US" -ForegroundColor Cyan
    New-AzResourceGroup -Name $resourceGroup -Location $regions[0].location | Out-Null
}

$appUrls = @()

foreach ($region in $regions) {
    $planName = "plan-az700-tm-$($region.name)"
    $appName = "$appNamePrefix-$($region.name)"
    
    Write-Host "Creating App Service Plan in $($region.display)" -ForegroundColor Cyan
    
    $plan = New-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $planName -Location $region.location -Tier Free -WorkerSize Small
    
    Write-Host "Creating App Service: $appName" -ForegroundColor Cyan
    
    $app = New-AzWebApp -ResourceGroupName $resourceGroup -Name $appName -Location $region.location -AppServicePlan $planName
    
    $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Traffic Manager Demo - $($region.display)</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding-top: 20vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            margin: 0;
            height: 100vh;
        }
        h1 {
            font-size: 3em;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }
        .region {
            font-size: 1.5em;
            background: rgba(255,255,255,0.2);
            padding: 10px 20px;
            border-radius: 25px;
            display: inline-block;
            margin-top: 20px;
        }
        .info {
            margin-top: 30px;
            font-size: 1.1em;
            opacity: 0.9;
        }
    </style>
</head>
<body>
    <h1>Happy Learning from $($region.display)</h1>
    <div class="region">Region: $($region.display)</div>
    <div class="info">
        <p>App Service: $appName</p>
        <p>Location: $($region.location)</p>
        <p>This endpoint is ready for Traffic Manager configuration</p>
    </div>
</body>
</html>
"@

    $tempFile = [System.IO.Path]::GetTempFileName() + ".html"
    $htmlContent | Out-File -FilePath $tempFile -Encoding UTF8
    
    Write-Host "Deploying custom page to $appName" -ForegroundColor Cyan
    
    $zipFile = [System.IO.Path]::GetTempFileName() + ".zip"
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::Open($zipFile, [System.IO.Compression.ZipArchiveMode]::Create)
    $entry = $zip.CreateEntry("index.html")
    $entryStream = $entry.Open()
    $fileStream = [System.IO.File]::OpenRead($tempFile)
    $fileStream.CopyTo($entryStream)
    $fileStream.Close()
    $entryStream.Close()
    $zip.Dispose()
    
    Publish-AzWebApp -ResourceGroupName $resourceGroup -Name $appName -ArchivePath $zipFile -Force | Out-Null
    
    Remove-Item $tempFile -Force
    Remove-Item $zipFile -Force
    
    $appUrls += "https://$appName.azurewebsites.net"
    
    Write-Host "✓ Deployed: $appName in $($region.display)" -ForegroundColor Green
}

Write-Host "Deployment completed." -ForegroundColor Green
