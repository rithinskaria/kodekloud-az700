

# ------------------------ Variables ------------------------
$resourceGroup      = "rg-az700-udr-nva"
$locationEUS        = "eastus"
$locationWUS        = "westus"
$locationCentral    = "centralus"
$username           = "kodekloud"
$passwordPlain      = "@dminP@55w0rd"   # Lab only
$securePassword     = (ConvertTo-SecureString $passwordPlain -AsPlainText -Force)
$credential         = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# Image (Ubuntu 22.04 LTS)
$imagePublisher     = "Canonical"
$imageOffer         = "0001-com-ubuntu-server-jammy"
$imageSku           = "22_04-lts-gen2"
$imageVersion       = "latest"

# VNet / VM naming (hub & spokes) - hub hosts the NVA in centralus
$vnet1Name          = "vnet-az700-udr-spoke-eus"
$vnet2Name          = "vnet-az700-udr-spoke-wus"
$vnet3Name          = "vnet-az700-udr-hub"   # centralus hub
$subnet1Name        = "subnet-az700-udr-spoke-eus"
$subnet2Name        = "subnet-az700-udr-spoke-wus"
$subnet3Name        = "subnet-az700-udr-hub"
$vm1Name            = "vm-az700-udr-spoke-eus-01"
$vm2Name            = "vm-az700-udr-spoke-wus-01"
$vm3Name            = "vm-az700-udr-hub-01"  # NVA
$nic1Name           = "nic-az700-udr-spoke-eus-01"
$nic2Name           = "nic-az700-udr-spoke-wus-01"
$nic3Name           = "nic-az700-udr-hub-01" # NVA NIC
$ip1Name            = "pip-az700-udr-spoke-eus-01"
$ip2Name            = "pip-az700-udr-spoke-wus-01"
$ip3Name            = "pip-az700-udr-hub-01"
$nsg1Name           = "nsg-az700-udr-spoke-eus"
$nsg2Name           = "nsg-az700-udr-spoke-wus"
$nsg3Name           = "nsg-az700-udr-hub"

# Address spaces (non-overlapping)
$vnet1Prefix        = "10.50.0.0/16"
$vnet2Prefix        = "10.60.0.0/16"
$vnet3Prefix        = "10.70.0.0/16"
$subnet1Prefix      = "10.50.1.0/24"
$subnet2Prefix      = "10.60.1.0/24"
$subnet3Prefix      = "10.70.1.0/24"

Write-Host "Starting AZ-700 UDR/NVA lab deployment..." -ForegroundColor Cyan

# ------------------------ Resource Group ------------------------
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroup -Location $locationEUS | Out-Null
}

# ------------------------ VNets ------------------------
Write-Host "Creating VNets & Subnets" -ForegroundColor Cyan
$subnetCfg1 = New-AzVirtualNetworkSubnetConfig -Name $subnet1Name -AddressPrefix $subnet1Prefix
$vnet1 = New-AzVirtualNetwork -Name $vnet1Name -ResourceGroupName $resourceGroup -Location $locationEUS -AddressPrefix $vnet1Prefix -Subnet $subnetCfg1

$subnetCfg2 = New-AzVirtualNetworkSubnetConfig -Name $subnet2Name -AddressPrefix $subnet2Prefix
$vnet2 = New-AzVirtualNetwork -Name $vnet2Name -ResourceGroupName $resourceGroup -Location $locationWUS -AddressPrefix $vnet2Prefix -Subnet $subnetCfg2

$subnetCfg3 = New-AzVirtualNetworkSubnetConfig -Name $subnet3Name -AddressPrefix $subnet3Prefix
$vnet3 = New-AzVirtualNetwork -Name $vnet3Name -ResourceGroupName $resourceGroup -Location $locationCentral -AddressPrefix $vnet3Prefix -Subnet $subnetCfg3

# ------------------------ Public IPs ------------------------
Write-Host "Creating Public IPs" -ForegroundColor Cyan
$pip1 = New-AzPublicIpAddress -Name $ip1Name -ResourceGroupName $resourceGroup -Location $locationEUS -Sku Basic -AllocationMethod Static -IpAddressVersion IPv4
$pip2 = New-AzPublicIpAddress -Name $ip2Name -ResourceGroupName $resourceGroup -Location $locationWUS -Sku Basic -AllocationMethod Static -IpAddressVersion IPv4
$pip3 = New-AzPublicIpAddress -Name $ip3Name -ResourceGroupName $resourceGroup -Location $locationCentral -Sku Basic -AllocationMethod Static -IpAddressVersion IPv4

# ------------------------ NSGs ------------------------
Write-Host "Creating NSGs and SSH rules" -ForegroundColor Cyan
$nsg1 = New-AzNetworkSecurityGroup -Name $nsg1Name -ResourceGroupName $resourceGroup -Location $locationEUS
$nsg2 = New-AzNetworkSecurityGroup -Name $nsg2Name -ResourceGroupName $resourceGroup -Location $locationWUS
$nsg3 = New-AzNetworkSecurityGroup -Name $nsg3Name -ResourceGroupName $resourceGroup -Location $locationCentral

foreach ($nsg in @($nsg1,$nsg2,$nsg3)) {
    $nsg | Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH" -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 | Set-AzNetworkSecurityGroup | Out-Null
}

# ------------------------ NICs ------------------------
Write-Host "Creating NICs" -ForegroundColor Cyan
$subnet1 = Get-AzVirtualNetworkSubnetConfig -Name $subnet1Name -VirtualNetwork $vnet1
$subnet2 = Get-AzVirtualNetworkSubnetConfig -Name $subnet2Name -VirtualNetwork $vnet2
$subnet3 = Get-AzVirtualNetworkSubnetConfig -Name $subnet3Name -VirtualNetwork $vnet3

$nic1 = New-AzNetworkInterface -Name $nic1Name -ResourceGroupName $resourceGroup -Location $locationEUS -Subnet $subnet1 -PublicIpAddress $pip1 -NetworkSecurityGroup $nsg1
$nic2 = New-AzNetworkInterface -Name $nic2Name -ResourceGroupName $resourceGroup -Location $locationWUS -Subnet $subnet2 -PublicIpAddress $pip2 -NetworkSecurityGroup $nsg2
$nic3 = New-AzNetworkInterface -Name $nic3Name -ResourceGroupName $resourceGroup -Location $locationCentral -Subnet $subnet3 -PublicIpAddress $pip3 -NetworkSecurityGroup $nsg3 -EnableIPForwarding

# ------------------------ VM Configs ------------------------
Write-Host "Building VM configurations" -ForegroundColor Cyan
$vmCfg1 = New-AzVMConfig -VMName $vm1Name -VMSize "Standard_B1s" |
    Set-AzVMOperatingSystem -Linux -ComputerName $vm1Name -Credential $credential |
    Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion |
    Add-AzVMNetworkInterface -Id $nic1.Id

$vmCfg2 = New-AzVMConfig -VMName $vm2Name -VMSize "Standard_B1s" |
    Set-AzVMOperatingSystem -Linux -ComputerName $vm2Name -Credential $credential |
    Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion |
    Add-AzVMNetworkInterface -Id $nic2.Id

# NVA VM config (enable IP forwarding in guest via cloud-init)
$cloudInit = @" 
#cloud-config
runcmd:
  - sysctl -w net.ipv4.ip_forward=1
  - sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
  - sysctl -p
"@
$cloudInitBytes = [System.Text.Encoding]::UTF8.GetBytes($cloudInit)
$cloudInitEncoded = [Convert]::ToBase64String($cloudInitBytes)

$vmCfg3 = New-AzVMConfig -VMName $vm3Name -VMSize "Standard_B1s" |
    Set-AzVMOperatingSystem -Linux -ComputerName $vm3Name -Credential $credential |
    Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion |
    Add-AzVMNetworkInterface -Id $nic3.Id
# Inject cloud-init custom data (base64 encoded)
$vmCfg3.OSProfile.CustomData = $cloudInitEncoded

# ------------------------ Create VMs ------------------------
Write-Host "Creating VMs (this will take several minutes)" -ForegroundColor Cyan
New-AzVM -ResourceGroupName $resourceGroup -Location $locationEUS -VM $vmCfg1 | Out-Null
New-AzVM -ResourceGroupName $resourceGroup -Location $locationWUS -VM $vmCfg2 | Out-Null
New-AzVM -ResourceGroupName $resourceGroup -Location $locationCentral -VM $vmCfg3 | Out-Null

# ------------------------ Peering (Full Mesh) ------------------------
Write-Host "Creating VNet peerings with forwarded traffic allowed" -ForegroundColor Cyan
# Helper function
function New-FullPeering($fromVnet,$toVnet){
    # AllowVirtualNetworkAccess is enabled by default; only specify forwarded traffic.
    Add-AzVirtualNetworkPeering -Name ("peer-"+$fromVnet.Name+"-to-"+$toVnet.Name) -VirtualNetwork $fromVnet -RemoteVirtualNetworkId $toVnet.Id -AllowForwardedTraffic | Out-Null
}

New-FullPeering -fromVnet $vnet1 -toVnet $vnet2
New-FullPeering -fromVnet $vnet2 -toVnet $vnet1
New-FullPeering -fromVnet $vnet1 -toVnet $vnet3
New-FullPeering -fromVnet $vnet3 -toVnet $vnet1
New-FullPeering -fromVnet $vnet2 -toVnet $vnet3
New-FullPeering -fromVnet $vnet3 -toVnet $vnet2

# ------------------------ Output ------------------------
Write-Host "Deployment complete." -ForegroundColor Green
Write-Host "NVA Public IP:" ((Get-AzPublicIpAddress -Name $ip3Name -ResourceGroupName $resourceGroup).IpAddress)


