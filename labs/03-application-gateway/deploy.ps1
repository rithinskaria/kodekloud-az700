$resourceGroup    = "rg-az700-appgw"
$location         = "eastus2"
$vnetName         = "vnet-az700-appgw"
$vnetAddressSpace = "10.201.0.0/16"
$apiSubnetName    = "snet-api-backend"
$apiSubnetPrefix  = "10.201.1.0/24"
$imgSubnetName    = "snet-images-backend"
$imgSubnetPrefix  = "10.201.2.0/24"
$vmGroups = @(
  @{
    groupName = "API Backend"
    path = "/api"
    subnet = $apiSubnetName
    vms = @(
      @{ name = "vm-appgw-api-01"; nic = "nic-appgw-api-01" },
      @{ name = "vm-appgw-api-02"; nic = "nic-appgw-api-02" }
    )
  },
  @{
    groupName = "Images Backend"
    path = "/images"
    subnet = $imgSubnetName
    vms = @(
      @{ name = "vm-appgw-img-01"; nic = "nic-appgw-img-01" },
      @{ name = "vm-appgw-img-02"; nic = "nic-appgw-img-02" }
    )
  }
)
$username         = "kodekloud"
$passwordPlain    = "@dminP@55w0rd"   # Lab only
$securePassword   = ConvertTo-SecureString $passwordPlain -AsPlainText -Force
$credential       = New-Object System.Management.Automation.PSCredential($username,$securePassword)
$imagePublisher   = "Canonical"
$imageOffer       = "0001-com-ubuntu-server-jammy"
$imageSku         = "22_04-lts-gen2"
$imageVersion     = "latest"
$apiCloudInit = @'
packages:
  - apache2
write_files:
  - path: /var/www/html/index.html
    content: |
      <!DOCTYPE html>
      <html>
      <head>
          <title>API Backend - Application Gateway Demo</title>
          <style>
              body { font-family: 'Segoe UI', Arial; margin: 0; background: linear-gradient(135deg,
              .container { max-width: 1200px; margin: 0 auto; padding: 40px 20px; text-align: center; }
              h1 { font-size: 3em; margin-bottom: 20px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
              .badge { background: rgba(255,255,255,0.2); padding: 10px 30px; border-radius: 25px; display: inline-block; margin: 20px; }
              .api-card { background: rgba(255,255,255,0.1); padding: 30px; border-radius: 15px; margin: 20px 0; backdrop-filter: blur(10px); }
              .endpoint { background:
              .status { color:
          </style>
      </head>
      <body>
          <div class="container">
              <h1>🚀 API Backend Server</h1>
              <div class="badge">Server: HOSTNAME</div>
              <div class="badge">Path: /api/*</div>
              <div class="api-card">
                  <h2>API Status: <span class="status">✅ ONLINE</span></h2>
                  <p>This backend handles all API requests routed by Application Gateway</p>
                  <div class="endpoint">GET /api/users → User management endpoints</div>
                  <div class="endpoint">POST /api/data → Data processing endpoints</div>
                  <div class="endpoint">GET /api/status → Health check endpoint</div>
                  <p><strong>Happy Learning from HOSTNAME!</strong></p>
                  <p>Path-based routing demo: API traffic lands here 🎯</p>
              </div>
          </div>
      </body>
      </html>
  - path: /var/www/html/api/index.html
    content: |
      <!DOCTYPE html><html><head><title>API Endpoint</title></head><body style="background:#4CAF50;color:white;text-align:center;padding:50px;font-family:Arial;"><h1>API Endpoint Active</h1><p>Server: HOSTNAME</p><p>This is the /api path on the API backend!</p></body></html>
runcmd:
  - mkdir -p /var/www/html/api
  - sed -i "s/HOSTNAME/$(hostname)/g" /var/www/html/index.html
  - sed -i "s/HOSTNAME/$(hostname)/g" /var/www/html/api/index.html
  - chown -R www-data:www-data /var/www/html
  - chmod -R 755 /var/www/html
  - systemctl enable apache2
  - systemctl restart apache2
'@
$imagesCloudInit = @'
packages:
  - apache2
write_files:
  - path: /var/www/html/index.html
    content: |
      <!DOCTYPE html>
      <html>
      <head>
          <title>Images Backend - Application Gateway Demo</title>
          <style>
              body { font-family: 'Segoe UI', Arial; margin: 0; background: linear-gradient(135deg,
              .container { max-width: 1200px; margin: 0 auto; padding: 40px 20px; text-align: center; }
              h1 { font-size: 3em; margin-bottom: 20px; text-shadow: 2px 2px 4px rgba(0,0,0,0.1); }
              .badge { background: rgba(255,255,255,0.8); color:
              .images-card { background: rgba(255,255,255,0.9); color:
              .gallery { display: flex; justify-content: center; flex-wrap: wrap; margin: 20px 0; }
              .image-placeholder { width: 120px; height: 120px; background: linear-gradient(45deg,
              .status { color:
          </style>
      </head>
      <body>
          <div class="container">
              <h1>🖼️ Images Backend Server</h1>
              <div class="badge">Server: HOSTNAME</div>
              <div class="badge">Path: /images/*</div>
              <div class="images-card">
                  <h2>Gallery Status: <span class="status">✅ ONLINE</span></h2>
                  <p>This backend serves all image content routed by Application Gateway</p>
                  <div class="gallery">
                      <div class="image-placeholder">🏞️</div>
                      <div class="image-placeholder">🌅</div>
                      <div class="image-placeholder">🎨</div>
                      <div class="image-placeholder">📸</div>
                  </div>
                  <p><strong>Happy Learning from HOSTNAME!</strong></p>
                  <p>Path-based routing demo: Images traffic lands here 🎯</p>
              </div>
          </div>
      </body>
      </html>
  - path: /var/www/html/images/index.html
    content: |
      <!DOCTYPE html><html><head><title>Images Gallery</title></head><body style="background:#ff6b6b;color:white;text-align:center;padding:50px;font-family:Arial;"><h1>Images Gallery</h1><p>Server: HOSTNAME</p><p>This is the /images path on the Images backend!</p><div style="font-size:4em;">🖼️📸🎨🌅</div></body></html>
runcmd:
  - mkdir -p /var/www/html/images
  - sed -i "s/HOSTNAME/$(hostname)/g" /var/www/html/index.html
  - sed -i "s/HOSTNAME/$(hostname)/g" /var/www/html/images/index.html
  - chown -R www-data:www-data /var/www/html
  - chmod -R 755 /var/www/html
  - systemctl enable apache2
  - systemctl restart apache2
'@
Write-Host "Starting Azure Application Gateway Path-Based Routing demo deployment..." -ForegroundColor Cyan
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
  New-AzResourceGroup -Name $resourceGroup -Location $location | Out-Null
}
Write-Host "Creating VNet with two subnets for backend pools" -ForegroundColor Cyan
$apiSubnetCfg = New-AzVirtualNetworkSubnetConfig -Name $apiSubnetName -AddressPrefix $apiSubnetPrefix
$imgSubnetCfg = New-AzVirtualNetworkSubnetConfig -Name $imgSubnetName -AddressPrefix $imgSubnetPrefix
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup -Location $location -AddressPrefix $vnetAddressSpace -Subnet $apiSubnetCfg, $imgSubnetCfg
$apiSubnet = Get-AzVirtualNetworkSubnetConfig -Name $apiSubnetName -VirtualNetwork $vnet
$imgSubnet = Get-AzVirtualNetworkSubnetConfig -Name $imgSubnetName -VirtualNetwork $vnet
Write-Host "Creating NSG" -ForegroundColor Cyan
$nsgName = "nsg-az700-appgw-web"
$nsg = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroup -Location $location
$nsg | Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH"  -Description "SSH"  -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 | Set-AzNetworkSecurityGroup | Out-Null
$nsg | Add-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1010 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 | Set-AzNetworkSecurityGroup | Out-Null
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $apiSubnetName -AddressPrefix $apiSubnetPrefix -NetworkSecurityGroup $nsg | Out-Null
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $imgSubnetName -AddressPrefix $imgSubnetPrefix -NetworkSecurityGroup $nsg | Out-Null
$vnet | Set-AzVirtualNetwork | Out-Null
$allVmDetails = @()
foreach ($group in $vmGroups) {
    Write-Host ("Creating VMs for " + $group.groupName + " (" + $group.path + ")") -ForegroundColor Yellow
    $subnet = if ($group.subnet -eq $apiSubnetName) { $apiSubnet } else { $imgSubnet }
    $cloudTemplate = if ($group.path -eq "/api") { $apiCloudInit } else { $imagesCloudInit }
    foreach ($vm in $group.vms) {
        $cloudEncoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($cloudTemplate))
        Write-Host ("  Creating NIC for " + $vm.name) -ForegroundColor Cyan
        $nic = New-AzNetworkInterface -Name $vm.nic -ResourceGroupName $resourceGroup -Location $location -Subnet $subnet -NetworkSecurityGroup $nsg
        Write-Host ("  Building VM config for " + $vm.name) -ForegroundColor Cyan
        $vmCfg = New-AzVMConfig -VMName $vm.name -VMSize "Standard_B1s" |
            Set-AzVMOperatingSystem -Linux -ComputerName $vm.name -Credential $credential |
            Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion |
            Add-AzVMNetworkInterface -Id $nic.Id
        $vmCfg.OSProfile.CustomData = $cloudEncoded
        New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmCfg | Out-Null
        $privateIp = (Get-AzNetworkInterface -Name $vm.nic -ResourceGroupName $resourceGroup).IpConfigurations[0].PrivateIpAddress
        $allVmDetails += @{
            name = $vm.name
            ip = $privateIp
            group = $group.groupName
            path = $group.path
            subnet = $group.subnet
        }
        Write-Host ("  ✓ Created " + $vm.name + " (" + $privateIp + ")") -ForegroundColor Green
    }
}
Write-Host "Deployment completed." -ForegroundColor Green
