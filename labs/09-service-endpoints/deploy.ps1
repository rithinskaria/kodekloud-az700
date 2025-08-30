$resourceGroup = "rg-az700-service-endpoints"
$location = "eastus"
$randomSuffix = -join ((1..6) | ForEach-Object { [char](97 + (Get-Random -Maximum 26)) })
$vnetName = "vnet-service-endpoints"
$subnetName = "subnet-vm"
$vnetAddressPrefix = "10.0.0.0/16"
$subnetAddressPrefix = "10.0.1.0/24"
$vmName = "vm-service-endpoints"
$vmSize = "Standard_B1s"
$adminUsername = "kodekloud"
$adminPassword = "@dminP@55w0rd"
$publicIpName = "pip-vm-service-endpoints"
$nsgName = "nsg-vm-service-endpoints"
$nicName = "nic-vm-service-endpoints"
$storageAccountName = "sa$randomSuffix"
Write-Host "Starting Service Endpoints demo lab deployment..." -ForegroundColor Cyan
Write-Host "Using suffix: $randomSuffix" -ForegroundColor Yellow
Write-Host "This creates infrastructure to demonstrate Azure Service Endpoints" -ForegroundColor Gray
Write-Host "Creating resource group: $resourceGroup" -ForegroundColor Cyan
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroup -Location $location | Out-Null
    Write-Host "✓ Resource group created" -ForegroundColor Green
} else {
    Write-Host "✓ Resource group already exists" -ForegroundColor Yellow
}
Write-Host "Creating virtual network and subnet..." -ForegroundColor Cyan
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location -Name $vnetName -AddressPrefix $vnetAddressPrefix -Subnet $subnetConfig
Write-Host "✓ Virtual network created: $vnetName" -ForegroundColor Green
Write-Host "✓ Subnet created: $subnetName" -ForegroundColor Green
Write-Host "Creating Network Security Group..." -ForegroundColor Cyan
$sshRule = New-AzNetworkSecurityRuleConfig -Name "SSH" -Protocol Tcp -Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -Access Allow
$httpRule = New-AzNetworkSecurityRuleConfig -Name "HTTP" -Protocol Tcp -Direction Inbound -Priority 1002 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 -Access Allow
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location -Name $nsgName -SecurityRules $sshRule,$httpRule
Write-Host "✓ Network Security Group created: $nsgName" -ForegroundColor Green
Write-Host "Creating public IP address..." -ForegroundColor Cyan
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroup -Location $location -Name $publicIpName -AllocationMethod Static -Sku Standard
Write-Host "✓ Public IP created: $publicIpName" -ForegroundColor Green
Write-Host "Creating network interface..." -ForegroundColor Cyan
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroup -Location $location -Name $nicName -SubnetId $subnet.Id -PublicIpAddressId $publicIp.Id -NetworkSecurityGroupId $nsg.Id
Write-Host "✓ Network interface created: $nicName" -ForegroundColor Green
Write-Host "Creating virtual machine..." -ForegroundColor Cyan
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($adminUsername, $securePassword)
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -Credential $cred -DisablePasswordAuthentication:$false
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts-gen2" -Version "latest"
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
Write-Host "  Deploying virtual machine (this may take a few minutes)..." -ForegroundColor Gray
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig | Out-Null
Write-Host "✓ Virtual machine created: $vmName" -ForegroundColor Green
Write-Host "Creating storage account..." -ForegroundColor Cyan
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName -Location $location -SkuName "Standard_LRS" -Kind "StorageV2"
Write-Host "✓ Storage account created: $storageAccountName" -ForegroundColor Green
$publicIpAddress = Get-AzPublicIpAddress -ResourceGroupName $resourceGroup -Name $publicIpName
Write-Host "Deployment completed." -ForegroundColor Green
