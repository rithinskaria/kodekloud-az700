$resourceGroup = "rg-az700-waf-simple"
$primaryLocation = "eastus"
$secondaryLocation = "westeurope"
$randomSuffix = -join ((1..6) | ForEach-Object { [char](97 + (Get-Random -Maximum 26)) })
$appServicePlan1Name = "asp-waf-primary-$randomSuffix"
$appServicePlan2Name = "asp-waf-secondary-$randomSuffix"
$appService1Name = "webapp-waf-primary-$randomSuffix"
$appService2Name = "webapp-waf-secondary-$randomSuffix"
Write-Host "Starting simple XSS vulnerable web app deployment..." -ForegroundColor Cyan
Write-Host "Using suffix: $randomSuffix" -ForegroundColor Yellow
Write-Host "This creates vulnerable apps that work with XSS attacks" -ForegroundColor Gray
Write-Host "Creating resource group: $resourceGroup" -ForegroundColor Cyan
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroup -Location $primaryLocation | Out-Null
    Write-Host "✓ Resource group created" -ForegroundColor Green
} else {
    Write-Host "✓ Resource group already exists" -ForegroundColor Yellow
}
Write-Host "Creating App Service Plans..." -ForegroundColor Cyan
New-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $appServicePlan1Name -Location $primaryLocation -Tier "Free" | Out-Null
Write-Host "✓ App Service Plan created in $primaryLocation" -ForegroundColor Green
New-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $appServicePlan2Name -Location $secondaryLocation -Tier "Free" | Out-Null
Write-Host "✓ App Service Plan created in $secondaryLocation" -ForegroundColor Green
Write-Host "Creating App Services..." -ForegroundColor Cyan
New-AzWebApp -ResourceGroupName $resourceGroup -Name $appService1Name -Location $primaryLocation -AppServicePlan $appServicePlan1Name | Out-Null
Write-Host "✓ App Service created in $primaryLocation" -ForegroundColor Green
New-AzWebApp -ResourceGroupName $resourceGroup -Name $appService2Name -Location $secondaryLocation -AppServicePlan $appServicePlan2Name | Out-Null
Write-Host "✓ App Service created in $secondaryLocation" -ForegroundColor Green
Write-Host "Creating vulnerable web application content..." -ForegroundColor Cyan
$vulnerableHtml = @"
<!DOCTYPE html>
<html>
<head>
    <title>XSS Vulnerable Web App -
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background:
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color:
        .form-group { margin: 20px 0; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
        button { background:
        button:hover { opacity: 0.8; }
        .result { margin-top: 20px; padding: 15px; background:
        .warning { background:
    </style>
</head>
<body>
    <div class="container">
        <h1>🌍 WAF Demo App -
        <div class="warning">
            <strong>⚠️ Warning:</strong> This is a deliberately vulnerable application for WAF testing. 
            It contains XSS vulnerabilities that should be blocked by WAF when properly configured.
        </div>
        <h2>Test XSS Vulnerability</h2>
        <form method="get">
            <div class="form-group">
                <label for="name">Enter your name (vulnerable to XSS):</label>
                <input type="text" id="name" name="name" placeholder="Try: <script>alert('XSS Attack!')</script>">
            </div>
            <div class="form-group">
                <label for="comment">Leave a comment (vulnerable to XSS):</label>
                <textarea id="comment" name="comment" rows="4" placeholder="Try: <img src=x onerror=alert('XSS!')>"></textarea>
            </div>
            <button type="submit">Submit (This will execute XSS!)</button>
        </form>
        <script>
            // Get URL parameters
            const urlParams = new URLSearchParams(window.location.search);
            const name = urlParams.get('name');
            const comment = urlParams.get('comment');
            if (name || comment) {
                document.write('<div class="result">');
                if (name) {
                    document.write('<h3>Hello: ' + name + '</h3>');
                }
                if (comment) {
                    document.write('<h3>Your comment: ' + comment + '</h3>');
                }
                document.write('</div>');
            }
        </script>
        <h2>Common XSS Test Payloads</h2>
        <p>Try these in the form above:</p>
        <ul>
            <li><code>&lt;script&gt;alert('XSS')&lt;/script&gt;</code></li>
            <li><code>&lt;img src=x onerror=alert('XSS')&gt;</code></li>
            <li><code>&lt;svg onload=alert('XSS')&gt;</code></li>
            <li><code>&lt;iframe src=javascript:alert('XSS')&gt;</code></li>
            <li><code>javascript:alert('XSS')</code></li>
        </ul>
        <h2>Expected Behavior</h2>
        <p><strong>Without WAF:</strong> XSS scripts will execute and show alert boxes</p>
        <p><strong>With WAF:</strong> Requests will be blocked with HTTP 403 Forbidden</p>
        <p><strong>Region:</strong>
        <p><strong>App Service:</strong>
    </div>
</body>
</html>
"@
$primaryHtml = $vulnerableHtml -replace "##REGION##", "East US (Primary)" -replace "##COLOR##", "#0078d4" -replace "##BGCOLOR##", "#e6f3ff" -replace "##APPNAME##", $appService1Name
$secondaryHtml = $vulnerableHtml -replace "##REGION##", "West Europe (Secondary)" -replace "##COLOR##", "#107c10" -replace "##BGCOLOR##", "#e6ffe6" -replace "##APPNAME##", $appService2Name
$tempDir = [System.IO.Path]::GetTempPath()
$primaryHtmlFile = Join-Path $tempDir "primary-app.html"
$secondaryHtmlFile = Join-Path $tempDir "secondary-app.html"
$primaryHtml | Out-File -FilePath $primaryHtmlFile -Encoding UTF8
$secondaryHtml | Out-File -FilePath $secondaryHtmlFile -Encoding UTF8
$primaryZipFile = Join-Path $tempDir "primary-app.zip"
$secondaryZipFile = Join-Path $tempDir "secondary-app.zip"
if (Test-Path $primaryZipFile) { Remove-Item $primaryZipFile }
if (Test-Path $secondaryZipFile) { Remove-Item $secondaryZipFile }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$primaryZip = [System.IO.Compression.ZipFile]::Open($primaryZipFile, [System.IO.Compression.ZipArchiveMode]::Create)
$primaryEntry = $primaryZip.CreateEntry("index.html")
$primaryStream = $primaryEntry.Open()
$primaryBytes = [System.Text.Encoding]::UTF8.GetBytes($primaryHtml)
$primaryStream.Write($primaryBytes, 0, $primaryBytes.Length)
$primaryStream.Close()
$primaryZip.Dispose()
$secondaryZip = [System.IO.Compression.ZipFile]::Open($secondaryZipFile, [System.IO.Compression.ZipArchiveMode]::Create)
$secondaryEntry = $secondaryZip.CreateEntry("index.html")
$secondaryStream = $secondaryEntry.Open()
$secondaryBytes = [System.Text.Encoding]::UTF8.GetBytes($secondaryHtml)
$secondaryStream.Write($secondaryBytes, 0, $secondaryBytes.Length)
$secondaryStream.Close()
$secondaryZip.Dispose()
Write-Host "✓ Vulnerable web application content created" -ForegroundColor Green
Write-Host "Deploying vulnerable application to App Services..." -ForegroundColor Cyan
Write-Host "  Deploying to primary region ($primaryLocation)..." -ForegroundColor Gray
Publish-AzWebApp -ResourceGroupName $resourceGroup -Name $appService1Name -ArchivePath $primaryZipFile -Force | Out-Null
Write-Host "✓ Deployed to $appService1Name" -ForegroundColor Green
Write-Host "  Deploying to secondary region ($secondaryLocation)..." -ForegroundColor Gray
Publish-AzWebApp -ResourceGroupName $resourceGroup -Name $appService2Name -ArchivePath $secondaryZipFile -Force | Out-Null
Write-Host "✓ Deployed to $appService2Name" -ForegroundColor Green
Remove-Item $primaryHtmlFile, $secondaryHtmlFile, $primaryZipFile, $secondaryZipFile -Force
$appService1Url = "https://$appService1Name.azurewebsites.net"
$appService2Url = "https://$appService2Name.azurewebsites.net"
Write-Host "Deployment completed." -ForegroundColor Green
