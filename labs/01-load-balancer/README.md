# Azure Load Balancer Lab

## Overview
This lab demonstrates Azure Load Balancer distributing traffic across virtual machines in multiple availability zones.

## Architecture
- **Resource Group**: rg-az700-lb
- **Virtual Network**: 10.200.0.0/16
- **Subnet**: 10.200.1.0/24
- **Virtual Machines**: 3 Ubuntu VMs across availability zones 1, 2, and 3
- **Load Balancer**: Standard SKU (to be created manually)

## What Gets Deployed
1. Resource group
2. Virtual network with subnet
3. Network Security Group (HTTP and SSH access)
4. 3 Virtual machines with Apache web server
5. Each VM shows a different colored webpage with hostname

## VM Details
- **Size**: Standard_B1ms (cost-effective)
- **OS**: Ubuntu 22.04 LTS
- **Username**: kodekloud
- **Password**: @dminP@55w0rd
- **Web Server**: Apache serving custom colored pages

## Deployment
```powershell
.\deploy.ps1
```

## Manual Configuration Steps
After running the script, create the Load Balancer manually:

1. **Create Load Balancer**
   - Go to Azure Portal > Create Resource > Load Balancer
   - SKU: Standard
   - Type: Public
   - Create new public IP address

2. **Configure Backend Pool**
   - Add all 3 VMs to the backend pool
   - Associate with the subnet

3. **Create Health Probe**
   - Protocol: HTTP
   - Port: 80
   - Path: /
   - Interval: 5 seconds

4. **Create Load Balancing Rule**
   - Frontend IP: Load balancer public IP
   - Frontend Port: 80
   - Backend Port: 80
   - Backend Pool: Your created pool
   - Health Probe: Your created probe

## Testing
1. Access the Load Balancer's public IP address
2. Refresh the page multiple times
3. You should see different colored pages with different hostnames
4. This demonstrates traffic distribution across availability zones

## Expected Results
- Zone 1 VM: Light blue background
- Zone 2 VM: Light green background  
- Zone 3 VM: Light pink background

Each page displays "happy learning from [hostname]" with the respective VM's hostname.

## Cleanup
Delete the resource group when done:
```powershell
Remove-AzResourceGroup -Name "rg-az700-lb" -Force
```

## Learning Objectives
- Understand Azure Load Balancer functionality
- Learn about availability zones
- Practice backend pool configuration
- Understand health probes and load balancing rules
- Observe traffic distribution patterns
