

# ------------------------ Variables ------------------------
$resourceGroup    = "rg-az700-p2s"
$locationHub      = "eastus"
$locationSpoke    = "eastus"   # Keep same region for simplicity

# Hub VNet
$hubVnetName      = "vnet-az700-p2s-hub"
$hubAddressSpace  = "10.90.0.0/24"  # Single /24 as requested (no subnets yet)

# Spoke VNet
$spokeVnetName    = "vnet-az700-p2s-spoke"
$spokeAddressSpace= "10.91.0.0/16"
$spokeSubnetName  = "snet-az700-p2s-spoke-app"
$spokeSubnetPrefix= "10.91.1.0/24"

# VM in Spoke (private only)
$vmName           = "vm-az700-p2s-spoke-app-01"
$nicName          = "nic-az700-p2s-spoke-app-01"
$nsgName          = "nsg-az700-p2s-spoke-app"

$username         = "kodekloud"
$passwordPlain    = "@dminP@55w0rd"
$securePassword   = ConvertTo-SecureString $passwordPlain -AsPlainText -Force
$credential       = New-Object System.Management.Automation.PSCredential($username,$securePassword)

# Ubuntu 22.04 image
$imagePublisher   = "Canonical"
$imageOffer       = "0001-com-ubuntu-server-jammy"
$imageSku         = "22_04-lts-gen2"
$imageVersion     = "latest"

# Cloud-init to install Apache and set page
$cloudInit = @" 
#cloud-config
packages:
  - apache2
runcmd:
  - echo '<h1>Internal Site</h1>' > /var/www/html/index.html
  - systemctl enable apache2
  - systemctl restart apache2
"@
$cloudInitBytes = [System.Text.Encoding]::UTF8.GetBytes($cloudInit)
$cloudInitEncoded = [Convert]::ToBase64String($cloudInitBytes)

Write-Host "Starting P2S / Gateway Transit base lab (no gateway yet)" -ForegroundColor Cyan

# ------------------------ Resource Group ------------------------
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroup -Location $locationHub | Out-Null
}

# ------------------------ Create Hub VNet (no subnets yet) ------------------------
Write-Host "Creating hub VNet (no subnets)" -ForegroundColor Cyan
$hubVnet = New-AzVirtualNetwork -Name $hubVnetName -ResourceGroupName $resourceGroup -Location $locationHub -AddressPrefix $hubAddressSpace

# ------------------------ Create Spoke VNet & Subnet ------------------------
Write-Host "Creating spoke VNet + subnet" -ForegroundColor Cyan
$spokeSubnetCfg = New-AzVirtualNetworkSubnetConfig -Name $spokeSubnetName -AddressPrefix $spokeSubnetPrefix
$spokeVnet = New-AzVirtualNetwork -Name $spokeVnetName -ResourceGroupName $resourceGroup -Location $locationSpoke -AddressPrefix $spokeAddressSpace -Subnet $spokeSubnetCfg
$spokeSubnet = Get-AzVirtualNetworkSubnetConfig -Name $spokeSubnetName -VirtualNetwork $spokeVnet

# ------------------------ NSG + Rules (HTTP + SSH) ------------------------
Write-Host "Creating NSG for spoke VM" -ForegroundColor Cyan
$nsg = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroup -Location $locationSpoke
$nsg | Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH" -Description "SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 | Set-AzNetworkSecurityGroup | Out-Null
$nsg | Add-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1010 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 | Set-AzNetworkSecurityGroup | Out-Null

# ------------------------ NIC (Private only, no Public IP) ------------------------
Write-Host "Creating NIC (no public IP)" -ForegroundColor Cyan
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup -Location $locationSpoke -Subnet $spokeSubnet -NetworkSecurityGroup $nsg

# ------------------------ VM Config ------------------------
Write-Host "Creating VM config" -ForegroundColor Cyan
$vmCfg = New-AzVMConfig -VMName $vmName -VMSize "Standard_B1s" |
    Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential $credential |
    Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion |
    Add-AzVMNetworkInterface -Id $nic.Id
$vmCfg.OSProfile.CustomData = $cloudInitEncoded

# ------------------------ Create VM ------------------------
Write-Host "Deploying VM" -ForegroundColor Cyan
New-AzVM -ResourceGroupName $resourceGroup -Location $locationSpoke -VM $vmCfg | Out-Null

# ------------------------ VNet Peering (no gateway transit) ------------------------
Write-Host "Creating hub <-> spoke peering (no gateway transit)" -ForegroundColor Cyan
Add-AzVirtualNetworkPeering -Name "peer-hub-to-spoke"   -VirtualNetwork $hubVnet  -RemoteVirtualNetworkId $spokeVnet.Id -AllowForwardedTraffic | Out-Null
Add-AzVirtualNetworkPeering -Name "peer-spoke-to-hub"   -VirtualNetwork $spokeVnet -RemoteVirtualNetworkId $hubVnet.Id   -AllowForwardedTraffic | Out-Null

# ------------------------ Output ------------------------
$privateIp = (Get-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup).IpConfigurations[0].PrivateIpAddress
Write-Host "Deployment complete." -ForegroundColor Green
Write-Host "Spoke VM Private IP: $privateIp" -ForegroundColor Yellow

Write-Host "Next steps: Add GatewaySubnet to hub, deploy VPN gateway, enable gateway transit (hub side) then establish P2S to reach the internal site." -ForegroundColor Cyan
