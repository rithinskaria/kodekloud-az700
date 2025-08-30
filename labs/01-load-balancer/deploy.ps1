$resourceGroup    = "rg-az700-lb"
$location         = "eastus2"
$vnetName         = "vnet-az700-lb"
$subnetName       = "snet-az700-lb-web"
$vnetAddressSpace = "10.200.0.0/16"
$subnetPrefix     = "10.200.1.0/24"

$vmNames = @(
  @{ name = "vm-az700-lb-web-az1"; zone = "1"; nic = "nic-az700-lb-web-az1"; nsg = "nsg-az700-lb-web" },
  @{ name = "vm-az700-lb-web-az2"; zone = "2"; nic = "nic-az700-lb-web-az2"; nsg = "nsg-az700-lb-web" },
  @{ name = "vm-az700-lb-web-az3"; zone = "3"; nic = "nic-az700-lb-web-az3"; nsg = "nsg-az700-lb-web" }
)

$username         = "kodekloud"
$passwordPlain    = "@dminP@55w0rd"
$securePassword   = ConvertTo-SecureString $passwordPlain -AsPlainText -Force
$credential       = New-Object System.Management.Automation.PSCredential($username,$securePassword)

$imagePublisher   = "Canonical"
$imageOffer       = "0001-com-ubuntu-server-jammy"
$imageSku         = "22_04-lts-gen2"
$imageVersion     = "latest"

$bgColors = @("#e3f2fd", "#e8f5e9", "#fce4ec")

$cloudTemplate = @'
#cloud-config
packages:
  - apache2
write_files:
  - path: /var/www/html/index.html
    content: |
      <html><body style="background-color: BG; font-family: Arial; text-align:center; padding-top:20vh;"><h1>happy learning from HOSTNAME</h1></body></html>
   
runcmd:
  - sed -i "s/HOSTNAME/$(hostname)/" /var/www/html/index.html
  - systemctl enable apache2
  - systemctl restart apache2
'@

Write-Host "Starting Azure LB demo prep deployment..." -ForegroundColor Cyan

Write-Host "Creating resource group: $resourceGroup" -ForegroundColor Cyan
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroup -Location $location | Out-Null
    Write-Host "✓ Resource group created" -ForegroundColor Green
} else {
    Write-Host "✓ Resource group already exists" -ForegroundColor Yellow
}

Write-Host "Creating virtual network..." -ForegroundColor Cyan
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetPrefix
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location -Name $vnetName -AddressPrefix $vnetAddressSpace -Subnet $subnetConfig
Write-Host "✓ VNet created: $vnetName" -ForegroundColor Green

Write-Host "Creating Network Security Group..." -ForegroundColor Cyan
$httpRule = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 -Access Allow
$sshRule = New-AzNetworkSecurityRuleConfig -Name "Allow-SSH" -Protocol Tcp -Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -Access Allow
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location -Name "nsg-az700-lb-web" -SecurityRules $httpRule,$sshRule
Write-Host "✓ NSG created" -ForegroundColor Green

$subnetRef = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName

foreach ($vm in $vmNames) {
    Write-Host "Creating VM: $($vm.name) in Zone $($vm.zone)..." -ForegroundColor Yellow
    
    $nic = New-AzNetworkInterface -ResourceGroupName $resourceGroup -Location $location -Name $vm.nic -SubnetId $subnetRef.Id -NetworkSecurityGroupId $nsg.Id
    
    $zoneIndex = [int]$vm.zone - 1
    $customCloudInit = $cloudTemplate -replace "BG", $bgColors[$zoneIndex]
    $cloudInitBytes = [System.Text.Encoding]::UTF8.GetBytes($customCloudInit)
    $cloudInitB64 = [Convert]::ToBase64String($cloudInitBytes)
    
    $vmConfig = New-AzVMConfig -VMName $vm.name -VMSize "Standard_B1ms" -Zone $vm.zone
    $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vm.name -Credential $credential -CustomData $cloudInitB64
    $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion
    $vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
    $vmConfig = Set-AzVMBootDiagnostic -VM $vmConfig -Disable
    
    New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig | Out-Null
    Write-Host "✓ VM created: $($vm.name)" -ForegroundColor Green
}

Write-Host "Deployment completed." -ForegroundColor Green
