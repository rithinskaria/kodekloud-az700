# Variables
$resourceGroup = "rg-az700-private-dns"
$locationEUS = "eastus"
$locationWUS = "westus"
$username = "kodekloud"
$password = "@dminP@55w0rd" 

# VM 1 (East US)
$vmName1 = "vm-az700-eus-01"
$vnetName1 = "vnet-az700-eus"
$subnetName1 = "subnet-az700-eus"
$ipName1 = "ip-az700-eus"
$nicName1 = "nic-az700-eus"
$addressPrefix1 = "10.10.0.0/16"
$subnetPrefix1 = "10.10.1.0/24"

# VM 2 (West US)
$vmName2 = "vm-az700-wus-01"
$vnetName2 = "vnet-az700-wus"
$subnetName2 = "subnet-az700-wus"
$ipName2 = "ip-az700-wus"
$nicName2 = "nic-az700-wus"
$addressPrefix2 = "10.20.0.0/16"
$subnetPrefix2 = "10.20.1.0/24"

# Create Resource Group
New-AzResourceGroup -Name $resourceGroup -Location $locationEUS

# Create Subnets
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name $subnetName1 -AddressPrefix $subnetPrefix1
$subnet2 = New-AzVirtualNetworkSubnetConfig -Name $subnetName2 -AddressPrefix $subnetPrefix2

# Create VNETs
New-AzVirtualNetwork -Name $vnetName1 -ResourceGroupName $resourceGroup -Location $locationEUS -AddressPrefix $addressPrefix1 -Subnet $subnet1
New-AzVirtualNetwork -Name $vnetName2 -ResourceGroupName $resourceGroup -Location $locationWUS -AddressPrefix $addressPrefix2 -Subnet $subnet2

# Create Public IPs
New-AzPublicIpAddress -Name $ipName1 -ResourceGroupName $resourceGroup -Location $locationEUS -AllocationMethod Static
New-AzPublicIpAddress -Name $ipName2 -ResourceGroupName $resourceGroup -Location $locationWUS -AllocationMethod Static

# Get VNETs and Public IPs for NIC creation
$vnet1 = Get-AzVirtualNetwork -Name $vnetName1 -ResourceGroupName $resourceGroup
$vnet2 = Get-AzVirtualNetwork -Name $vnetName2 -ResourceGroupName $resourceGroup
$pip1 = Get-AzPublicIpAddress -Name $ipName1 -ResourceGroupName $resourceGroup
$pip2 = Get-AzPublicIpAddress -Name $ipName2 -ResourceGroupName $resourceGroup

# Create NICs
New-AzNetworkInterface -Name $nicName1 -ResourceGroupName $resourceGroup -Location $locationEUS -SubnetId $vnet1.Subnets[0].Id -PublicIpAddressId $pip1.Id
New-AzNetworkInterface -Name $nicName2 -ResourceGroupName $resourceGroup -Location $locationWUS -SubnetId $vnet2.Subnets[0].Id -PublicIpAddressId $pip2.Id


# Create NSGs
$nsgEUS = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $locationEUS -Name "nsg-az700-eus"
$nsgWUS = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $locationWUS -Name "nsg-az700-wus"

# Allow SSH on both NSGs 
$nsgEUS = Get-AzNetworkSecurityGroup -Name "nsg-az700-eus" -ResourceGroupName $resourceGroup
$nsgEUS = Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH" -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -NetworkSecurityGroup $nsgEUS
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsgEUS

$nsgWUS = Get-AzNetworkSecurityGroup -Name "nsg-az700-wus" -ResourceGroupName $resourceGroup
$nsgWUS = Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH" -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -NetworkSecurityGroup $nsgWUS
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsgWUS

# Attach NSGs to NICs
$nic1 = Get-AzNetworkInterface -Name $nicName1 -ResourceGroupName $resourceGroup
$nic2 = Get-AzNetworkInterface -Name $nicName2 -ResourceGroupName $resourceGroup
$nic1.NetworkSecurityGroup = $nsgEUS
$nic2.NetworkSecurityGroup = $nsgWUS
Set-AzNetworkInterface -NetworkInterface $nic1
Set-AzNetworkInterface -NetworkInterface $nic2

# VM config for EUS
$vmConfig1 = New-AzVMConfig -VMName $vmName1 -VMSize "Standard_B1s" | `
    Set-AzVMOperatingSystem -Linux -ComputerName $vmName1 -Credential (New-Object System.Management.Automation.PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))) | `
    Set-AzVMSourceImage -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts-gen2" -Version "latest" | `
    Add-AzVMNetworkInterface -Id (Get-AzNetworkInterface -Name $nicName1 -ResourceGroupName $resourceGroup).Id

# VM config for WUS
$vmConfig2 = New-AzVMConfig -VMName $vmName2 -VMSize "Standard_B1s" | `
    Set-AzVMOperatingSystem -Linux -ComputerName $vmName2 -Credential (New-Object System.Management.Automation.PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))) | `
    Set-AzVMSourceImage -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts-gen2" -Version "latest" | `
    Add-AzVMNetworkInterface -Id (Get-AzNetworkInterface -Name $nicName2 -ResourceGroupName $resourceGroup).Id

# Create VMs
New-AzVM -ResourceGroupName $resourceGroup -Location $locationEUS -VM $vmConfig1
New-AzVM -ResourceGroupName $resourceGroup -Location $locationWUS -VM $vmConfig2
