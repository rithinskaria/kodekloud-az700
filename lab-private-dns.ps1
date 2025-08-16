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
az group create --name $resourceGroup --location $locationEUS

# Create VNETs and Subnets
az network vnet create --resource-group $resourceGroup --name $vnetName1 --address-prefix $addressPrefix1 --location $locationEUS --subnet-name $subnetName1 --subnet-prefix $subnetPrefix1
az network vnet create --resource-group $resourceGroup --name $vnetName2 --address-prefix $addressPrefix2 --location $locationWUS --subnet-name $subnetName2 --subnet-prefix $subnetPrefix2

# Create Public IPs
az network public-ip create --resource-group $resourceGroup --name $ipName1 --location $locationEUS
az network public-ip create --resource-group $resourceGroup --name $ipName2 --location $locationWUS

# Create NICs
az network nic create --resource-group $resourceGroup --name $nicName1 --vnet-name $vnetName1 --subnet $subnetName1 --public-ip-address $ipName1 --location $locationEUS
az network nic create --resource-group $resourceGroup --name $nicName2 --vnet-name $vnetName2 --subnet $subnetName2 --public-ip-address $ipName2 --location $locationWUS


# Create NSGs
$nsgEUS = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $locationEUS -Name "nsg-az700-eus"
$nsgWUS = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $locationWUS -Name "nsg-az700-wus"

# Allow SSH on both NSGs
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig -Name "Allow-SSH" -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22
$nsgEUS | Add-AzNetworkSecurityRuleConfig -NetworkSecurityRule $nsgRuleSSH | Set-AzNetworkSecurityGroup
$nsgWUS | Add-AzNetworkSecurityRuleConfig -NetworkSecurityRule $nsgRuleSSH | Set-AzNetworkSecurityGroup

# Attach NSGs to NICs
Set-AzNetworkInterface -Name $nicName1 -ResourceGroupName $resourceGroup -NetworkSecurityGroup $nsgEUS
Set-AzNetworkInterface -Name $nicName2 -ResourceGroupName $resourceGroup -NetworkSecurityGroup $nsgWUS

# VM config for EUS
$vmConfig1 = New-AzVMConfig -VMName $vmName1 -VMSize "Standard_B1s" | `
	Set-AzVMOperatingSystem -Linux -ComputerName $vmName1 -Credential (New-Object System.Management.Automation.PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))) | `
	Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "22_04-lts-gen2" -Version "latest" | `
	Add-AzVMNetworkInterface -Id (Get-AzNetworkInterface -Name $nicName1 -ResourceGroupName $resourceGroup).Id

# VM config for WUS
$vmConfig2 = New-AzVMConfig -VMName $vmName2 -VMSize "Standard_B1s" | `
	Set-AzVMOperatingSystem -Linux -ComputerName $vmName2 -Credential (New-Object System.Management.Automation.PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))) | `
	Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "22_04-lts-gen2" -Version "latest" | `
	Add-AzVMNetworkInterface -Id (Get-AzNetworkInterface -Name $nicName2 -ResourceGroupName $resourceGroup).Id

# Create VMs
New-AzVM -ResourceGroupName $resourceGroup -Location $locationEUS -VM $vmConfig1
New-AzVM -ResourceGroupName $resourceGroup -Location $locationWUS -VM $vmConfig2
