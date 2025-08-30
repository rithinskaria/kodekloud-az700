$resourceGroup = "rg-az700-nsg"
$location = "eastus"
$vnetName = "vnet-az700-nsg"
$subnetName = "subnet-nsg-lab"
$vmNamePrefix = "vm-nsg-lab"
$vmSize = "Standard_B1s"  # Smallest and most cost-effective VM size
$adminUsername = "kodekloud"
$adminPassword = "@dminP@55w0rd"
Write-Host "Starting NSG Lab infrastructure deployment..." -ForegroundColor Cyan
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
Write-Host "Creating 3 Linux VMs with public IPs..." -ForegroundColor Cyan
$securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($adminUsername, $securePassword)
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName
for ($i = 1; $i -le 3; $i++) {
    $vmName = "$vmNamePrefix-$i"
    $publicIpName = "$vmName-pip"
    $nicName = "$vmName-nic"
    Write-Host "Creating VM $i of 3: $vmName" -ForegroundColor Cyan
    Write-Host "  Creating public IP: $publicIpName" -ForegroundColor Gray
    $publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroup -Location $location -Name $publicIpName -AllocationMethod Static -Sku Standard
    Write-Host "  Creating network interface: $nicName" -ForegroundColor Gray
    $nic = New-AzNetworkInterface -ResourceGroupName $resourceGroup -Location $location -Name $nicName -SubnetId $subnet.Id -PublicIpAddressId $publicIp.Id
    $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize
    $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -Credential $cred
    $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts-gen2" -Version "latest"
    $vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
    $vmConfig = Set-AzVMBootDiagnostic -VM $vmConfig -Disable
    Write-Host "  Creating virtual machine..." -ForegroundColor Gray
    New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig | Out-Null
    Write-Host "✓ VM created: $vmName (Public IP: $($publicIp.IpAddress))" -ForegroundColor Green
}
Write-Host "Deployment completed." -ForegroundColor Green
