$resourceGroup = "rg-az700-frontdoor"
$randomSuffix = -join ((97..122) | Get-Random -Count 6 | % {[char]$_})
$appNamePrefix = "app-az700-fd-$randomSuffix"
$commonPaths = @("/api/users", "/api/orders", "/images/gallery", "/images/uploads", "/videos/stream", "/videos/live", "/docs/help", "/docs/faq")
$regions = @(
    @{ 
        name = "eastus"
        display = "East US"
        location = "eastus"
        continent = "North America"
        flag = "🇺🇸"
        color = "#4285f4"
        specialty = "API Services"
        description = "High-performance API endpoints optimized for North American users"
    },
    @{ 
        name = "westeurope"
        display = "West Europe"
        location = "westeurope"
        continent = "Europe"
        flag = "🇪🇺"
        color = "#34a853"
        specialty = "Media & Images"
        description = "Optimized media delivery and image processing for European users"
    },
    @{ 
        name = "southeastasia"
        display = "Southeast Asia"
        location = "southeastasia"
        continent = "Asia"
        flag = "🌏"
        color = "#fbbc04"
        specialty = "Video Content"
        description = "Video streaming and content delivery optimized for Asian markets"
    },
    @{ 
        name = "australiaeast"
        display = "Australia East"
        location = "australiaeast"
        continent = "Oceania"
        flag = "🇦🇺"
        color = "#ea4335"
        specialty = "Documentation"
        description = "Knowledge base and documentation services for Oceania region"
    }
)
Write-Host "Starting Azure Front Door global demo deployment..." -ForegroundColor Cyan
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    Write-Host "Creating resource group in East US" -ForegroundColor Cyan
    New-AzResourceGroup -Name $resourceGroup -Location $regions[0].location | Out-Null
}
$appUrls = @()
foreach ($region in $regions) {
    $planName = "plan-az700-fd-$($region.name)"
    $appName = "$appNamePrefix-$($region.name)"
    Write-Host "Creating App Service Plan in $($region.display)" -ForegroundColor Cyan
    $plan = New-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $planName -Location $region.location -Tier Free -WorkerSize Small
    Write-Host "Creating App Service: $appName" -ForegroundColor Cyan
    $app = New-AzWebApp -ResourceGroupName $resourceGroup -Name $appName -Location $region.location -AppServicePlan $planName
    $pathsContent = ""
    foreach ($path in $commonPaths) {
        $pathName = $path.Split('/')[-1]
        $pathCategory = $path.Split('/')[1]
        $pathsContent += @"
        <div class="path-demo">
            <h3>$path</h3>
            <p><strong>Regional Specialty:</strong> $($region.specialty)</p>
            <p>This $pathCategory endpoint is served from $($region.display) with optimized content for $($region.continent) users.</p>
            <div class="path-badge">$($region.flag) $pathName</div>
        </div>
"@
    }
    $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure Front Door Demo - $($region.display)</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, $($region.color)22 0%, $($region.color)44 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(255,255,255,0.95);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 40px;
            padding-bottom: 30px;
            border-bottom: 3px solid $($region.color);
        }
        .flag { font-size: 4em; margin-bottom: 20px; }
        .title { 
            font-size: 2.5em; 
            color: $($region.color); 
            margin-bottom: 10px;
            font-weight: bold;
        }
        .subtitle { 
            font-size: 1.3em; 
            color:
            margin-bottom: 20px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }
        .info-card {
            background: linear-gradient(135deg, $($region.color)11 0%, $($region.color)22 100%);
            padding: 25px;
            border-radius: 15px;
            border-left: 5px solid $($region.color);
        }
        .info-card h3 {
            color: $($region.color);
            margin-bottom: 15px;
            font-size: 1.4em;
        }
        .paths-section {
            background: linear-gradient(135deg,
            padding: 30px;
            border-radius: 15px;
            margin-top: 30px;
        }
        .paths-title {
            text-align: center;
            color: $($region.color);
            font-size: 1.8em;
            margin-bottom: 25px;
        }
        .path-demo {
            background: white;
            margin: 15px 0;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid $($region.color);
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .path-demo h3 {
            color: $($region.color);
            font-family: 'Courier New', monospace;
            margin-bottom: 10px;
        }
        .path-badge {
            background: $($region.color);
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            display: inline-block;
            font-size: 0.9em;
            margin-top: 10px;
        }
        .server-info {
            text-align: center;
            margin-top: 30px;
            padding: 20px;
            background: linear-gradient(135deg, $($region.color)11 0%, $($region.color)22 100%);
            border-radius: 10px;
        }
        .latency-demo {
            background:
            border: 1px solid
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: center;
        }
        .routing-info {
            background:
            border: 1px solid
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .routing-info h4 {
            color:
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="flag">$($region.flag)</div>
            <h1 class="title">Azure Front Door Demo</h1>
            <p class="subtitle">Serving from $($region.display), $($region.continent)</p>
            <p><strong>Happy Learning from $($region.display)!</strong></p>
        </div>
        <div class="info-grid">
            <div class="info-card">
                <h3>🌍 Geographic Info</h3>
                <p><strong>Region:</strong> $($region.display)</p>
                <p><strong>Location:</strong> $($region.location)</p>
                <p><strong>Continent:</strong> $($region.continent)</p>
                <p><strong>App Service:</strong> $appName</p>
                <p><strong>Specialty:</strong> $($region.specialty)</p>
            </div>
            <div class="info-card">
                <h3>🚀 Front Door Benefits</h3>
                <p>• Global load balancing</p>
                <p>• Geographic routing</p>
                <p>• SSL termination</p>
                <p>• WAF protection</p>
                <p>• Caching & compression</p>
                <p>• Health monitoring</p>
            </div>
        </div>
        <div class="latency-demo">
            <h4>🌐 Geographic Routing Demo</h4>
            <p>Azure Front Door routes users to the nearest healthy backend based on geographic location for optimal performance!</p>
            <p><strong>This region specializes in:</strong> $($region.specialty)</p>
        </div>
        <div class="routing-info">
            <h4>🎯 Front Door Configuration</h4>
            <p><strong>Backend Pool:</strong> $($region.display) Backend</p>
            <p><strong>Priority:</strong> Geographic proximity</p>
            <p><strong>Health Probe:</strong> /health (monitor endpoint availability)</p>
            <p><strong>Description:</strong> $($region.description)</p>
        </div>
        <div class="paths-section">
            <h2 class="paths-title">Available Endpoints</h2>
            <p style="text-align: center; margin-bottom: 25px; color: #666;">
                All endpoints are available on every region with localized content
            </p>
            $pathsContent
        </div>
        <div class="server-info">
            <h3>Server Information</h3>
            <p><strong>Hostname:</strong> $appName</p>
            <p><strong>Response Time:</strong> <span id="responseTime">Loading...</span></p>
            <p><strong>Request ID:</strong> <span id="requestId">$((New-Guid).ToString().Substring(0,8))</span></p>
        </div>
    </div>
    <script>
        // Simulate response time measurement
        const startTime = performance.now();
        window.addEventListener('load', function() {
            const loadTime = Math.round(performance.now() - startTime);
            document.getElementById('responseTime').textContent = loadTime + 'ms';
        });
        // Add some interactivity
        document.querySelectorAll('.path-demo').forEach(function(element) {
            element.addEventListener('click', function() {
                this.style.transform = this.style.transform === 'scale(1.02)' ? 'scale(1)' : 'scale(1.02)';
                this.style.transition = 'transform 0.2s ease';
            });
        });
    </script>
</body>
</html>
"@
    $pathFiles = @()
    foreach ($path in $commonPaths) {
        $pathSegments = $path.Split('/')
        $pathDir = $pathSegments[1]
        $pathFile = $pathSegments[2]
        $pathPageContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>$path - $($region.display)</title>
    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, $($region.color) 0%, $($region.color)88 100%); 
            color: white; 
            text-align: center; 
            padding: 50px; 
            min-height: 100vh;
            margin: 0;
        }
        .container { 
            max-width: 900px; 
            margin: 0 auto; 
            background: rgba(255,255,255,0.1); 
            padding: 40px; 
            border-radius: 20px; 
            backdrop-filter: blur(10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
        }
        h1 { 
            font-size: 3em; 
            margin-bottom: 20px; 
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3); 
        }
        .flag { 
            font-size: 5em; 
            margin: 20px 0; 
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .endpoint-info { 
            background: rgba(255,255,255,0.2); 
            padding: 25px; 
            border-radius: 15px; 
            margin: 25px 0; 
            border: 1px solid rgba(255,255,255,0.3);
        }
        .demo-content { 
            font-size: 1.2em; 
            line-height: 1.6; 
            margin: 20px 0;
        }
        .specialty-badge {
            background: rgba(255,255,255,0.3);
            padding: 10px 20px;
            border-radius: 25px;
            display: inline-block;
            margin: 10px;
            font-weight: bold;
        }
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 25px 0;
        }
        .feature {
            background: rgba(255,255,255,0.15);
            padding: 15px;
            border-radius: 10px;
            border-left: 4px solid rgba(255,255,255,0.5);
        }
        .stats {
            background: rgba(255,255,255,0.1);
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="flag">$($region.flag)</div>
        <h1>$path</h1>
        <div class="specialty-badge">$($region.specialty)</div>
        <div class="endpoint-info">
            <h2>Regional Content Delivery</h2>
            <p><strong>Served From:</strong> $($region.display) ($($region.continent))</p>
            <p><strong>Backend:</strong> $appName</p>
            <p><strong>Optimized For:</strong> $($region.specialty)</p>
        </div>
        <div class="demo-content">
            <h3>Happy Learning from $($region.display)!</h3>
            <p>$($region.description)</p>
            <p>This <strong>$path</strong> endpoint demonstrates how the same service can provide regionally optimized content.</p>
        </div>
        <div class="features">
            <div class="feature">
                <h4>🚀 Performance</h4>
                <p>Optimized for $($region.continent) users</p>
            </div>
            <div class="feature">
                <h4>🌍 Geographic</h4>
                <p>Served from $($region.display)</p>
            </div>
            <div class="feature">
                <h4>⚡ Speed</h4>
                <p>Low latency delivery</p>
            </div>
            <div class="feature">
                <h4>🛡️ Reliable</h4>
                <p>High availability</p>
            </div>
        </div>
        <div class="stats">
            <h3>Endpoint Statistics</h3>
            <p><strong>Response Time:</strong> <span id="responseTime">Loading...</span></p>
            <p><strong>Request ID:</strong> <span id="requestId">$((New-Guid).ToString().Substring(0,8))</span></p>
            <p><strong>Server Region:</strong> $($region.display)</p>
            <p><strong>Content Type:</strong> Regional $($pathSegments[1])</p>
        </div>
    </div>
    <script>
        // Simulate response time measurement
        const startTime = performance.now();
        window.addEventListener('load', function() {
            const loadTime = Math.round(performance.now() - startTime);
            document.getElementById('responseTime').textContent = loadTime + 'ms';
        });
        // Add some regional flavor animations
        setInterval(function() {
            document.querySelector('.flag').style.transform = 
                document.querySelector('.flag').style.transform === 'scale(1.1)' ? 'scale(1)' : 'scale(1.1)';
        }, 3000);
    </script>
</body>
</html>
"@
        $pathFiles += @{
            dir = $pathDir
            file = $pathFile
            content = $pathPageContent
        }
    }
    $tempDir = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    $htmlContent | Out-File -FilePath "$tempDir/index.html" -Encoding UTF8
    foreach ($pathFile in $pathFiles) {
        $pathDirPath = "$tempDir/$($pathFile.dir)"
        New-Item -ItemType Directory -Path $pathDirPath -Force | Out-Null
        $pathFile.content | Out-File -FilePath "$pathDirPath/$($pathFile.file).html" -Encoding UTF8
    }
    $healthContent = @"
<!DOCTYPE html>
<html>
<head><title>Health Check</title></head>
<body style="background: green; color: white; text-align: center; padding: 50px;">
<h1>✅ HEALTHY</h1>
<p>Backend: $appName</p>
<p>Region: $($region.display)</p>
<p>Status: Online</p>
</body>
</html>
"@
    $healthContent | Out-File -FilePath "$tempDir/health.html" -Encoding UTF8
    Write-Host "Deploying content to $appName" -ForegroundColor Cyan
    $zipFile = [System.IO.Path]::GetTempFileName() + ".zip"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipFile)
    Publish-AzWebApp -ResourceGroupName $resourceGroup -Name $appName -ArchivePath $zipFile -Force | Out-Null
    Remove-Item $tempDir -Recurse -Force
    Remove-Item $zipFile -Force
    $appUrls += "https://$appName.azurewebsites.net"
    Write-Host "✓ Deployed: $appName in $($region.display)" -ForegroundColor Green
}
Write-Host "`nDeployment complete! 🌍" -ForegroundColor Green
Write-Host "`nApp Service URLs for Front Door:" -ForegroundColor Yellow
for ($i = 0; $i -lt $regions.Count; $i++) {
    $region = $regions[$i]
    $url = $appUrls[$i]
    Write-Host ("  $($region.flag) $($region.display): $url") -ForegroundColor Cyan
    Write-Host ("    Specialty: $($region.specialty)") -ForegroundColor Gray
    Write-Host ("    All paths available with regional content") -ForegroundColor Gray
}
Write-Host "`nNext Steps for Azure Front Door:" -ForegroundColor Yellow
Write-Host "1. Create Azure Front Door profile" -ForegroundColor White
Write-Host "2. Add these App Services as backend pools:" -ForegroundColor White
Write-Host "   - East US backend (North America traffic)" -ForegroundColor White
Write-Host "   - West Europe backend (Europe traffic)" -ForegroundColor White  
Write-Host "   - Southeast Asia backend (Asia traffic)" -ForegroundColor White
Write-Host "   - Australia East backend (Oceania traffic)" -ForegroundColor White
Write-Host "3. Configure geographic routing (not path-based):" -ForegroundColor White
Write-Host "   - Route users to nearest healthy backend" -ForegroundColor White
Write-Host "   - All backends serve identical paths with regional content" -ForegroundColor White
Write-Host "4. Set up health probes pointing to /health.html" -ForegroundColor White
Write-Host "5. Configure failover between regions" -ForegroundColor White
Write-Host "6. Test from different global locations" -ForegroundColor White
Write-Host "`nTesting URLs (same paths, different regional content):" -ForegroundColor Yellow
Write-Host "- http://<frontdoor-url>/ (routed to nearest region)" -ForegroundColor White
Write-Host "- http://<frontdoor-url>/api/users (regional API content)" -ForegroundColor White
Write-Host "- http://<frontdoor-url>/api/orders (regional API content)" -ForegroundColor White
Write-Host "- http://<frontdoor-url>/images/gallery (regional image content)" -ForegroundColor White
Write-Host "- http://<frontdoor-url>/images/uploads (regional image content)" -ForegroundColor White
Write-Host "- http://<frontdoor-url>/videos/stream (regional video content)" -ForegroundColor White
Write-Host "- http://<frontdoor-url>/videos/live (regional video content)" -ForegroundColor White
Write-Host "- http://<frontdoor-url>/docs/help (regional documentation)" -ForegroundColor White
Write-Host "- http://<frontdoor-url>/docs/faq (regional documentation)" -ForegroundColor White
Write-Host "`nNote: All regions serve all paths with localized content and regional specialization." -ForegroundColor Gray
