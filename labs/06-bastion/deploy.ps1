$resourceGroup = "rg-az700-bastion-lab"
$location = "eastus2"
$vnetName = "vnet-az700-bastion"
$subnetName = "subnet-bastion-lab"
$windowsVmName = "vm-win-bastion"
$linuxVmName = "vm-linux-bastion"
$windowsVmSize = "Standard_D2s_v3"  # 2 vCPUs, 8GB RAM - good performance for Windows
$linuxVmSize = "Standard_B1s"       # Cost-effective for Linux
$adminUsername = "kodekloud"
$adminPassword = "@dminP@55w0rd"
Write-Host "Starting Azure Bastion lab infrastructure deployment..." -ForegroundColor Cyan
Write-Host "Creating resource group: $resourceGroup" -ForegroundColor Cyan
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroup -Location $location | Out-Null
    Write-Host "✓ Resource group created" -ForegroundColor Green
} else {
    Write-Host "✓ Resource group already exists" -ForegroundColor Yellow
}
Write-Host "Creating virtual network and subnet" -ForegroundColor Cyan
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.1.0/24"
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location -Name $vnetName -AddressPrefix "10.0.0.0/16" -Subnet $subnetConfig
Write-Host "✓ Virtual network created: $vnetName" -ForegroundColor Green
Write-Host "✓ Subnet created: $subnetName (10.0.1.0/24)" -ForegroundColor Green
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName
Write-Host "Creating Windows Server 2022 VM..." -ForegroundColor Cyan
$securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($adminUsername, $securePassword)
$windowsNicName = "$windowsVmName-nic"
Write-Host "  Creating network interface: $windowsNicName" -ForegroundColor Gray
$windowsNic = New-AzNetworkInterface -ResourceGroupName $resourceGroup -Location $location -Name $windowsNicName -SubnetId $subnet.Id
Write-Host "  Configuring Windows Server 2022 VM ($windowsVmSize)..." -ForegroundColor Gray
$windowsVmConfig = New-AzVMConfig -VMName $windowsVmName -VMSize $windowsVmSize
$windowsVmConfig = Set-AzVMOperatingSystem -VM $windowsVmConfig -Windows -ComputerName $windowsVmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$windowsVmConfig = Set-AzVMSourceImage -VM $windowsVmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter-g2" -Version "latest"
$windowsVmConfig = Add-AzVMNetworkInterface -VM $windowsVmConfig -Id $windowsNic.Id
$windowsVmConfig = Set-AzVMBootDiagnostic -VM $windowsVmConfig -Disable
Write-Host "  Creating Windows Server 2022 virtual machine..." -ForegroundColor Gray
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $windowsVmConfig | Out-Null
Write-Host "✓ Windows Server 2022 VM created: $windowsVmName" -ForegroundColor Green
Write-Host "Creating Ubuntu 22.04 VM..." -ForegroundColor Cyan
$linuxNicName = "$linuxVmName-nic"
Write-Host "  Creating network interface: $linuxNicName" -ForegroundColor Gray
$linuxNic = New-AzNetworkInterface -ResourceGroupName $resourceGroup -Location $location -Name $linuxNicName -SubnetId $subnet.Id
Write-Host "  Configuring Ubuntu 22.04 VM ($linuxVmSize)..." -ForegroundColor Gray
$linuxVmConfig = New-AzVMConfig -VMName $linuxVmName -VMSize $linuxVmSize
$linuxVmConfig = Set-AzVMOperatingSystem -VM $linuxVmConfig -Linux -ComputerName $linuxVmName -Credential $cred
$linuxVmConfig = Set-AzVMSourceImage -VM $linuxVmConfig -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts-gen2" -Version "latest"
$linuxVmConfig = Add-AzVMNetworkInterface -VM $linuxVmConfig -Id $linuxNic.Id
$linuxVmConfig = Set-AzVMBootDiagnostic -VM $linuxVmConfig -Disable
Write-Host "  Creating Ubuntu 22.04 virtual machine..." -ForegroundColor Gray
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $linuxVmConfig | Out-Null
Write-Host "✓ Ubuntu 22.04 VM created: $linuxVmName" -ForegroundColor Green
Write-Host "`nBastion lab infrastructure deployment complete! 🏰" -ForegroundColor Green
Write-Host "`nCreated Resources:" -ForegroundColor Yellow
Write-Host "Resource Group: $resourceGroup" -ForegroundColor White
Write-Host "Virtual Network: $vnetName (10.0.0.0/16)" -ForegroundColor White
Write-Host "Subnet: $subnetName (10.0.1.0/24)" -ForegroundColor White
Write-Host "`nVirtual Machines:" -ForegroundColor Yellow
Write-Host "  Windows Server 2022:" -ForegroundColor Cyan
Write-Host "    Name: $windowsVmName" -ForegroundColor White
Write-Host "    Size: $windowsVmSize (2 vCPUs, 8GB RAM)" -ForegroundColor White
Write-Host "    Public IP: None (Bastion required for access)" -ForegroundColor White
Write-Host "    OS: Windows Server 2022 Datacenter" -ForegroundColor White
Write-Host "  Ubuntu Linux:" -ForegroundColor Cyan
Write-Host "    Name: $linuxVmName" -ForegroundColor White
Write-Host "    Size: $linuxVmSize (1 vCPU, 1GB RAM)" -ForegroundColor White
Write-Host "    Public IP: None (Bastion required for access)" -ForegroundColor White
Write-Host "    OS: Ubuntu 22.04 LTS" -ForegroundColor White
Write-Host "`nLogin Credentials:" -ForegroundColor Yellow
Write-Host "Username: $adminUsername" -ForegroundColor White
Write-Host "Password: $adminPassword" -ForegroundColor White
Write-Host "`nNext Steps for Azure Bastion:" -ForegroundColor Yellow
Write-Host "1. Create Azure Bastion subnet (AzureBastionSubnet):" -ForegroundColor White
Write-Host "   - Subnet name must be exactly: AzureBastionSubnet" -ForegroundColor Gray
Write-Host "   - Minimum size: /26 (e.g., 10.0.2.0/26)" -ForegroundColor Gray
Write-Host "2. Deploy Azure Bastion resource:" -ForegroundColor White
Write-Host "   - Choose Basic or Standard SKU" -ForegroundColor Gray
Write-Host "   - Associate with AzureBastionSubnet" -ForegroundColor Gray
Write-Host "3. Configure Bastion settings:" -ForegroundColor White
Write-Host "   - Public IP for Bastion service" -ForegroundColor Gray
Write-Host "   - Network Security Group rules" -ForegroundColor Gray
Write-Host "4. Test connectivity:" -ForegroundColor White
Write-Host "   - RDP to Windows VM via Bastion" -ForegroundColor Gray
Write-Host "   - SSH to Linux VM via Bastion" -ForegroundColor Gray
Write-Host "`nBastion Connection Testing:" -ForegroundColor Yellow
Write-Host "Windows VM (RDP):" -ForegroundColor White
Write-Host "  • Use Azure Portal → Connect → Bastion" -ForegroundColor Gray
Write-Host "  • Username: $adminUsername" -ForegroundColor Gray
Write-Host "  • Password: $adminPassword" -ForegroundColor Gray
Write-Host "Linux VM (SSH):" -ForegroundColor White
Write-Host "  • Use Azure Portal → Connect → Bastion" -ForegroundColor Gray
Write-Host "  • Username: $adminUsername" -ForegroundColor Gray
Write-Host "  • Authentication: Password" -ForegroundColor Gray
Write-Host "  • Password: $adminPassword" -ForegroundColor Gray
Write-Host "`nBastion Benefits to Demonstrate:" -ForegroundColor Yellow
Write-Host "• Secure RDP/SSH without public IPs" -ForegroundColor White
Write-Host "• No need for VPN or ExpressRoute" -ForegroundColor White
Write-Host "• Browser-based connectivity" -ForegroundColor White
Write-Host "• Network security without NSG rules" -ForegroundColor White
Write-Host "• Centralized access management" -ForegroundColor White
Write-Host "`nNote: VMs have NO public IPs - Azure Bastion is required for access. This demonstrates secure connectivity." -ForegroundColor Gray
