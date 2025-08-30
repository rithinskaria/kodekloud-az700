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
Write-Host "`nNSG Lab infrastructure deployment complete! 🛡️" -ForegroundColor Green
Write-Host "`nCreated Resources:" -ForegroundColor Yellow
Write-Host "Resource Group: $resourceGroup" -ForegroundColor White
Write-Host "Virtual Network: $vnetName (10.0.0.0/16)" -ForegroundColor White
Write-Host "Subnet: $subnetName (10.0.1.0/24)" -ForegroundColor White
Write-Host "VMs: 3 x $vmSize Ubuntu 22.04 LTS" -ForegroundColor White
Write-Host "`nVirtual Machines:" -ForegroundColor Yellow
for ($i = 1; $i -le 3; $i++) {
    $vmName = "$vmNamePrefix-$i"
    $publicIpName = "$vmName-pip"
    $publicIp = Get-AzPublicIpAddress -ResourceGroupName $resourceGroup -Name $publicIpName
    Write-Host "  $vmName - Public IP: $($publicIp.IpAddress)" -ForegroundColor Cyan
}
Write-Host "`nLogin Credentials:" -ForegroundColor Yellow
Write-Host "Username: $adminUsername" -ForegroundColor White
Write-Host "Password: $adminPassword" -ForegroundColor White
Write-Host "`nNext Steps for NSG Demonstration:" -ForegroundColor Yellow
Write-Host "1. Test connectivity to VMs (should FAIL - no NSG rules)" -ForegroundColor Red
Write-Host "   ssh $adminUsername@<public-ip>" -ForegroundColor Gray
Write-Host "2. Create Network Security Groups:" -ForegroundColor White
Write-Host "   - Subnet-level NSG" -ForegroundColor Gray
Write-Host "   - NIC-level NSG" -ForegroundColor Gray
Write-Host "3. Configure NSG rules:" -ForegroundColor White
Write-Host "   - Allow SSH (port 22)" -ForegroundColor Gray
Write-Host "   - Allow HTTP (port 80)" -ForegroundColor Gray
Write-Host "   - Deny specific traffic" -ForegroundColor Gray
Write-Host "4. Associate NSGs with subnet/NICs" -ForegroundColor White
Write-Host "5. Test traffic flow and rule precedence" -ForegroundColor White
Write-Host "6. Monitor NSG flow logs" -ForegroundColor White
Write-Host "`nImportant Notes:" -ForegroundColor Red
Write-Host "• NO NSGs are currently assigned" -ForegroundColor White
Write-Host "• All traffic is currently BLOCKED by default Azure rules" -ForegroundColor White
Write-Host "• VMs cannot be accessed until NSG rules are configured" -ForegroundColor White
Write-Host "• Use this setup to demonstrate NSG rule effects" -ForegroundColor White
Write-Host "`nNSG Testing Commands:" -ForegroundColor Yellow
Write-Host "# Test SSH connectivity (should fail initially)" -ForegroundColor Gray
Write-Host "ssh $adminUsername@<vm-public-ip>" -ForegroundColor Gray
Write-Host "`n# Test HTTP connectivity (install web server first)" -ForegroundColor Gray
Write-Host "curl http://<vm-public-ip>" -ForegroundColor Gray
