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
Write-Host "Deployment completed." -ForegroundColor Green
