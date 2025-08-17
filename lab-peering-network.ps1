
# ------------------------ Variables ------------------------
$resourceGroup          = "rg-az700-peering"
$locationEUS            = "eastus"
$locationWUS            = "westus"
$username               = "kodekloud"
$passwordPlain          = "@dminP@55w0rd"   
$securePassword         = (ConvertTo-SecureString $passwordPlain -AsPlainText -Force)
$credential             = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# Naming (eastus)
$vmName1                = "vm-az700-peering-eus-01"
$vnetName1              = "vnet-az700-peering-eus"
$subnetName1            = "subnet-az700-peering-eus"
$ipName1                = "ip-az700-peering-eus"
$nicName1               = "nic-az700-peering-eus"
$nsgName1               = "nsg-az700-peering-eus"

# Naming (westus)
$vmName2                = "vm-az700-peering-wus-01"
$vnetName2              = "vnet-az700-peering-wus"
$subnetName2            = "subnet-az700-peering-wus"
$ipName2                = "ip-az700-peering-wus"
$nicName2               = "nic-az700-peering-wus"
$nsgName2               = "nsg-az700-peering-wus"

# Address spaces
$addressPrefix1         = "10.30.0.0/16"
$subnetPrefix1          = "10.30.1.0/24"
$addressPrefix2         = "10.40.0.0/16"
$subnetPrefix2          = "10.40.1.0/24"

# Private DNS
$privateDnsZoneName     = "az700peering.com"
$linkNameEUS            = "lnk-az700-peering-eus"
$linkNameWUS            = "lnk-az700-peering-wus"

# Image info (Ubuntu 22.04 LTS)
$imagePublisher         = "Canonical"
$imageOffer             = "0001-com-ubuntu-server-jammy"
$imageSku               = "22_04-lts-gen2"
$imageVersion           = "latest"

# ------------------------ Pre-flight ------------------------
Write-Host "Starting AZ-700 Peering lab deployment..." -ForegroundColor Cyan


# ------------------------ Resource Group ------------------------
Write-Host "Creating resource group $resourceGroup" -ForegroundColor Cyan
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroup -Location $locationEUS | Out-Null
}

# ------------------------ Virtual Networks & Subnets ------------------------
Write-Host "Creating VNets & subnets" -ForegroundColor Cyan
$subnetConfig1 = New-AzVirtualNetworkSubnetConfig -Name $subnetName1 -AddressPrefix $subnetPrefix1
$vnet1 = New-AzVirtualNetwork -Name $vnetName1 -ResourceGroupName $resourceGroup -Location $locationEUS -AddressPrefix $addressPrefix1 -Subnet $subnetConfig1

$subnetConfig2 = New-AzVirtualNetworkSubnetConfig -Name $subnetName2 -AddressPrefix $subnetPrefix2
$vnet2 = New-AzVirtualNetwork -Name $vnetName2 -ResourceGroupName $resourceGroup -Location $locationWUS -AddressPrefix $addressPrefix2 -Subnet $subnetConfig2

# ------------------------ Public IPs ------------------------
Write-Host "Creating Public IPs" -ForegroundColor Cyan
$pip1 = New-AzPublicIpAddress -Name $ipName1 -ResourceGroupName $resourceGroup -Location $locationEUS -Sku Basic -AllocationMethod Static -IpAddressVersion IPv4
$pip2 = New-AzPublicIpAddress -Name $ipName2 -ResourceGroupName $resourceGroup -Location $locationWUS -Sku Basic -AllocationMethod Static -IpAddressVersion IPv4

# ------------------------ NSGs & Rules ------------------------
Write-Host "Creating NSGs and SSH rules" -ForegroundColor Cyan
$nsg1 = New-AzNetworkSecurityGroup -Name $nsgName1 -ResourceGroupName $resourceGroup -Location $locationEUS
$nsg2 = New-AzNetworkSecurityGroup -Name $nsgName2 -ResourceGroupName $resourceGroup -Location $locationWUS

$nsg1 | Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH" -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 | Set-AzNetworkSecurityGroup | Out-Null
$nsg2 | Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH" -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 | Set-AzNetworkSecurityGroup | Out-Null

# ------------------------ NICs ------------------------
Write-Host "Creating NICs" -ForegroundColor Cyan
$subnetObj1 = Get-AzVirtualNetworkSubnetConfig -Name $subnetName1 -VirtualNetwork $vnet1
$subnetObj2 = Get-AzVirtualNetworkSubnetConfig -Name $subnetName2 -VirtualNetwork $vnet2
$nic1 = New-AzNetworkInterface -Name $nicName1 -ResourceGroupName $resourceGroup -Location $locationEUS -Subnet $subnetObj1 -PublicIpAddress $pip1 -NetworkSecurityGroup $nsg1
$nic2 = New-AzNetworkInterface -Name $nicName2 -ResourceGroupName $resourceGroup -Location $locationWUS -Subnet $subnetObj2 -PublicIpAddress $pip2 -NetworkSecurityGroup $nsg2

# ------------------------ VM Configs ------------------------
Write-Host "Building VM configurations" -ForegroundColor Cyan
$vmConfig1 = New-AzVMConfig -VMName $vmName1 -VMSize "Standard_B1s" |
    Set-AzVMOperatingSystem -Linux -ComputerName $vmName1 -Credential $credential |
    Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion |
    Add-AzVMNetworkInterface -Id $nic1.Id

$vmConfig2 = New-AzVMConfig -VMName $vmName2 -VMSize "Standard_B1s" |
    Set-AzVMOperatingSystem -Linux -ComputerName $vmName2 -Credential $credential |
    Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion |
    Add-AzVMNetworkInterface -Id $nic2.Id

# ------------------------ Create VMs ------------------------
Write-Host "Creating VMs (this can take several minutes)" -ForegroundColor Cyan
New-AzVM -ResourceGroupName $resourceGroup -Location $locationEUS -VM $vmConfig1 | Out-Null
New-AzVM -ResourceGroupName $resourceGroup -Location $locationWUS -VM $vmConfig2 | Out-Null

# ------------------------ Private DNS Zone ------------------------
Write-Host "Creating Private DNS zone $privateDnsZoneName" -ForegroundColor Cyan
$dnsZone = New-AzPrivateDnsZone -Name $privateDnsZoneName -ResourceGroupName $resourceGroup

Write-Host "Linking VNets to Private DNS zone with auto-registration" -ForegroundColor Cyan
New-AzPrivateDnsVirtualNetworkLink -ZoneName $privateDnsZoneName -ResourceGroupName $resourceGroup -Name $linkNameEUS -VirtualNetworkId $vnet1.Id -EnableRegistration | Out-Null
New-AzPrivateDnsVirtualNetworkLink -ZoneName $privateDnsZoneName -ResourceGroupName $resourceGroup -Name $linkNameWUS -VirtualNetworkId $vnet2.Id -EnableRegistration | Out-Null

# ------------------------ Output ------------------------
Write-Host "Deployment complete." -ForegroundColor Green
Write-Host "VM 1 Public IP:" ((Get-AzPublicIpAddress -Name $ipName1 -ResourceGroupName $resourceGroup).IpAddress)
Write-Host "VM 2 Public IP:" ((Get-AzPublicIpAddress -Name $ipName2 -ResourceGroupName $resourceGroup).IpAddress)

