
# ------------------------ Variables ------------------------
$resourceGroup      = "rg-az700-nat"
$location           = "eastus"
$vnetName           = "vnet-az700-nat"
$mgmtSubnetName     = "snet-az700-nat-mgmt"
$appSubnetName      = "snet-az700-nat-app"
$mgmtSubnetPrefix   = "10.80.1.0/24"
$appSubnetPrefix    = "10.80.2.0/24"
$vnetAddressSpace   = "10.80.0.0/16"

$mgmtVmName         = "vm-az700-nat-mgmt-01"
$appVmName          = "vm-az700-nat-app-01"
$mgmtNicName        = "nic-az700-nat-mgmt-01"
$appNicName         = "nic-az700-nat-app-01"
$mgmtPipName        = "pip-az700-nat-mgmt-01"
$mgmtNsgName        = "nsg-az700-nat-mgmt"
$appNsgName         = "nsg-az700-nat-app"

$username           = "kodekloud"
$passwordPlain      = "@dminP@55w0rd"   # Lab only – NOT for production
$securePassword     = ConvertTo-SecureString $passwordPlain -AsPlainText -Force
$credential         = New-Object System.Management.Automation.PSCredential($username,$securePassword)

# Image (Ubuntu 22.04 LTS)
$imagePublisher     = "Canonical"
$imageOffer         = "0001-com-ubuntu-server-jammy"
$imageSku           = "22_04-lts-gen2"
$imageVersion       = "latest"

Write-Host "Starting NAT Gateway lab base deployment..." -ForegroundColor Cyan

# ------------------------ Resource Group ------------------------
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroup -Location $location | Out-Null
}

# ------------------------ VNet & Subnets ------------------------
Write-Host "Creating VNet and subnets" -ForegroundColor Cyan
$mgmtSubnetCfg = New-AzVirtualNetworkSubnetConfig -Name $mgmtSubnetName -AddressPrefix $mgmtSubnetPrefix
$appSubnetCfg  = New-AzVirtualNetworkSubnetConfig -Name $appSubnetName  -AddressPrefix $appSubnetPrefix
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup -Location $location -AddressPrefix $vnetAddressSpace -Subnet $mgmtSubnetCfg,$appSubnetCfg

# Retrieve subnets (objects) after creation
$mgmtSubnet = Get-AzVirtualNetworkSubnetConfig -Name $mgmtSubnetName -VirtualNetwork $vnet
$appSubnet  = Get-AzVirtualNetworkSubnetConfig -Name $appSubnetName  -VirtualNetwork $vnet

# ------------------------ Public IP (Mgmt VM only) ------------------------
Write-Host "Creating Public IP for management VM" -ForegroundColor Cyan
$mgmtPip = New-AzPublicIpAddress -Name $mgmtPipName -ResourceGroupName $resourceGroup -Location $location -Sku Basic -AllocationMethod Static -IpAddressVersion IPv4

# ------------------------ NSGs ------------------------
Write-Host "Creating NSGs" -ForegroundColor Cyan
$mgmtNsg = New-AzNetworkSecurityGroup -Name $mgmtNsgName -ResourceGroupName $resourceGroup -Location $location
$appNsg  = New-AzNetworkSecurityGroup -Name $appNsgName  -ResourceGroupName $resourceGroup -Location $location

# Add rules
# Mgmt: Allow SSH inbound from anywhere (lab simplicity)
$mgmtNsg | Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH" -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 | Set-AzNetworkSecurityGroup | Out-Null
# App: Allow SSH only from management subnet
$appNsg  | Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH-From-Mgmt" -Description "Allow SSH from mgmt subnet" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix $mgmtSubnetPrefix -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 | Set-AzNetworkSecurityGroup | Out-Null

# Associate NSGs to subnets (so that private VM is protected regardless of NIC config)
Write-Host "Associating NSGs to subnets" -ForegroundColor Cyan
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup
$idxMgmt = ($vnet.Subnets | ForEach-Object IndexOf { $_.Name -eq $mgmtSubnetName })
$idxApp  = ($vnet.Subnets | ForEach-Object IndexOf { $_.Name -eq $appSubnetName })
# Simpler: fetch each subnet and set NSG
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $mgmtSubnetName -AddressPrefix $mgmtSubnetPrefix -NetworkSecurityGroup $mgmtNsg | Out-Null
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $appSubnetName  -AddressPrefix $appSubnetPrefix  -NetworkSecurityGroup $appNsg  | Out-Null
$vnet | Set-AzVirtualNetwork | Out-Null

# ------------------------ NICs ------------------------
Write-Host "Creating NICs" -ForegroundColor Cyan
$mgmtNic = New-AzNetworkInterface -Name $mgmtNicName -ResourceGroupName $resourceGroup -Location $location -Subnet $mgmtSubnet -PublicIpAddress $mgmtPip -NetworkSecurityGroup $mgmtNsg
$appNic  = New-AzNetworkInterface -Name $appNicName  -ResourceGroupName $resourceGroup -Location $location -Subnet $appSubnet  -NetworkSecurityGroup $appNsg

# ------------------------ VM Configs ------------------------
Write-Host "Building VM configurations" -ForegroundColor Cyan
$mgmtVmCfg = New-AzVMConfig -VMName $mgmtVmName -VMSize "Standard_B1s" |
    Set-AzVMOperatingSystem -Linux -ComputerName $mgmtVmName -Credential $credential |
    Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion |
    Add-AzVMNetworkInterface -Id $mgmtNic.Id

$appVmCfg = New-AzVMConfig -VMName $appVmName -VMSize "Standard_B1s" |
    Set-AzVMOperatingSystem -Linux -ComputerName $appVmName -Credential $credential |
    Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion |
    Add-AzVMNetworkInterface -Id $appNic.Id

# ------------------------ Create VMs ------------------------
Write-Host "Creating VMs (few minutes)" -ForegroundColor Cyan
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $mgmtVmCfg | Out-Null
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $appVmCfg | Out-Null

# ------------------------ Output ------------------------
$mgmtPublicIp = (Get-AzPublicIpAddress -Name $mgmtPipName -ResourceGroupName $resourceGroup).IpAddress
$mgmtPrivateIp = (Get-AzNetworkInterface -Name $mgmtNicName -ResourceGroupName $resourceGroup).IpConfigurations[0].PrivateIpAddress
$appPrivateIp  = (Get-AzNetworkInterface -Name $appNicName  -ResourceGroupName $resourceGroup).IpConfigurations[0].PrivateIpAddress

Write-Host "Deployment complete." -ForegroundColor Green
Write-Host "Management VM Public IP: $mgmtPublicIp" -ForegroundColor Yellow
Write-Host "Management VM Private IP: $mgmtPrivateIp"
Write-Host "App VM Private IP:        $appPrivateIp"

