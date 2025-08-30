# Virtual Network Peering Lab

## Overview
Connecting virtual networks across regions

## Architecture
Multiple VNets in different regions with cross-region connectivity

## What Gets Deployed
This lab creates the infrastructure needed to demonstrate virtual network peering functionality. The actual virtual network peering service configuration is done manually through the Azure Portal.

## Key Features
- Global peering
- Hub-spoke topology
- Transit routing
- Gateway transit

## Deployment
```powershell
.\deploy.ps1
```

## Manual Configuration Steps
After running the deployment script:

1. **Navigate to Azure Portal**
2. **Create Virtual Network Peering resource**
3. **Configure according to lab requirements**
4. **Test functionality**
5. **Observe behavior and results**

## Testing
Follow the specific testing procedures outlined in the deployment script output for hands-on experience with virtual network peering.

## Cleanup
Delete the resource group when done:
```powershell
Remove-AzResourceGroup -Name "rg-az700-*" -Force
```

## Learning Objectives
- Understand virtual network peering concepts and use cases
- Practice Azure networking configuration
- Learn about integration with other Azure services
- Gain hands-on experience with real-world scenarios

## Notes
- All scripts use cost-effective VM sizes and service tiers
- Authentication uses consistent credentials across labs
- Infrastructure is designed for learning and demonstration purposes
