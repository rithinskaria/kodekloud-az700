$resourceGroup        = "rg-az700-vwan"
$locationVnet1        = "eastus"
$locationVnet2        = "westus"
$vnet1Name            = "vnet-az700-vwan-eus"
$vnet1AddressSpace    = "10.120.0.0/16"
$vnet1SubnetName      = "snet-az700-vwan-eus-web"
$vnet1SubnetPrefix    = "10.120.1.0/24"
$vm1Name              = "vm-az700-vwan-eus-web-01"
$nic1Name             = "nic-az700-vwan-eus-web-01"
$nsg1Name             = "nsg-az700-vwan-eus-web"
$vnet2Name            = "vnet-az700-vwan-wus"
$vnet2AddressSpace    = "10.130.0.0/16"
$vnet2SubnetName      = "snet-az700-vwan-wus-web"
$vnet2SubnetPrefix    = "10.130.1.0/24"
$vm2Name              = "vm-az700-vwan-wus-web-01"
$nic2Name             = "nic-az700-vwan-wus-web-01"
$nsg2Name             = "nsg-az700-vwan-wus-web"
$username             = "kodekloud"
$passwordPlain        = "@dminP@55w0rd"
$securePassword       = ConvertTo-SecureString $passwordPlain -AsPlainText -Force
$credential           = New-Object System.Management.Automation.PSCredential($username,$securePassword)
$imagePublisher       = "Canonical"
$imageOffer           = "0001-com-ubuntu-server-jammy"
$imageSku             = "22_04-lts-gen2"
$imageVersion         = "latest"
$cloudInit1 = @" 
packages:
  - apache2
runcmd:
  - echo '<h1>Internal Site 1</h1>' > /var/www/html/index.html
  - systemctl enable apache2
  - systemctl restart apache2
"@
$cloudInit2 = @" 
packages:
  - apache2
runcmd:
  - echo '<h1>Internal Site 2</h1>' > /var/www/html/index.html
  - systemctl enable apache2
  - systemctl restart apache2
"@
$cloudInit1Encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($cloudInit1))
$cloudInit2Encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($cloudInit2))
Write-Host "Starting Virtual WAN spokes deployment (no hub yet)" -ForegroundColor Cyan
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroup -Location $locationVnet1 | Out-Null
}
Write-Host "Creating VNet1 & subnet" -ForegroundColor Cyan
$subnetCfg1 = New-AzVirtualNetworkSubnetConfig -Name $vnet1SubnetName -AddressPrefix $vnet1SubnetPrefix
$vnet1 = New-AzVirtualNetwork -Name $vnet1Name -ResourceGroupName $resourceGroup -Location $locationVnet1 -AddressPrefix $vnet1AddressSpace -Subnet $subnetCfg1
$subnet1 = Get-AzVirtualNetworkSubnetConfig -Name $vnet1SubnetName -VirtualNetwork $vnet1
Write-Host "Creating NSG1" -ForegroundColor Cyan
$nsg1 = New-AzNetworkSecurityGroup -Name $nsg1Name -ResourceGroupName $resourceGroup -Location $locationVnet1
$nsg1 | Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH"  -Description "SSH"  -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 | Set-AzNetworkSecurityGroup | Out-Null
$nsg1 | Add-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1010 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 | Set-AzNetworkSecurityGroup | Out-Null
Write-Host "NIC1 (no public IP)" -ForegroundColor Cyan
$nic1 = New-AzNetworkInterface -Name $nic1Name -ResourceGroupName $resourceGroup -Location $locationVnet1 -Subnet $subnet1 -NetworkSecurityGroup $nsg1
Write-Host "VM1 config" -ForegroundColor Cyan
$vm1Cfg = New-AzVMConfig -VMName $vm1Name -VMSize "Standard_B1s" |
  Set-AzVMOperatingSystem -Linux -ComputerName $vm1Name -Credential $credential |
  Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion |
  Add-AzVMNetworkInterface -Id $nic1.Id
$vm1Cfg.OSProfile.CustomData = $cloudInit1Encoded
Write-Host "Creating VNet2 & subnet" -ForegroundColor Cyan
$subnetCfg2 = New-AzVirtualNetworkSubnetConfig -Name $vnet2SubnetName -AddressPrefix $vnet2SubnetPrefix
$vnet2 = New-AzVirtualNetwork -Name $vnet2Name -ResourceGroupName $resourceGroup -Location $locationVnet2 -AddressPrefix $vnet2AddressSpace -Subnet $subnetCfg2
$subnet2 = Get-AzVirtualNetworkSubnetConfig -Name $vnet2SubnetName -VirtualNetwork $vnet2
Write-Host "Creating NSG2" -ForegroundColor Cyan
$nsg2 = New-AzNetworkSecurityGroup -Name $nsg2Name -ResourceGroupName $resourceGroup -Location $locationVnet2
$nsg2 | Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH"  -Description "SSH"  -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 | Set-AzNetworkSecurityGroup | Out-Null
$nsg2 | Add-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1010 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 | Set-AzNetworkSecurityGroup | Out-Null
Write-Host "NIC2 (no public IP)" -ForegroundColor Cyan
$nic2 = New-AzNetworkInterface -Name $nic2Name -ResourceGroupName $resourceGroup -Location $locationVnet2 -Subnet $subnet2 -NetworkSecurityGroup $nsg2
Write-Host "VM2 config" -ForegroundColor Cyan
$vm2Cfg = New-AzVMConfig -VMName $vm2Name -VMSize "Standard_B1s" |
  Set-AzVMOperatingSystem -Linux -ComputerName $vm2Name -Credential $credential |
  Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion |
  Add-AzVMNetworkInterface -Id $nic2.Id
$vm2Cfg.OSProfile.CustomData = $cloudInit2Encoded
Write-Host "Creating VMs" -ForegroundColor Cyan
New-AzVM -ResourceGroupName $resourceGroup -Location $locationVnet1 -VM $vm1Cfg | Out-Null
New-AzVM -ResourceGroupName $resourceGroup -Location $locationVnet2 -VM $vm2Cfg | Out-Null
$priv1 = (Get-AzNetworkInterface -Name $nic1Name -ResourceGroupName $resourceGroup).IpConfigurations[0].PrivateIpAddress
$priv2 = (Get-AzNetworkInterface -Name $nic2Name -ResourceGroupName $resourceGroup).IpConfigurations[0].PrivateIpAddress
Write-Host "Deployment completed." -ForegroundColor Green
