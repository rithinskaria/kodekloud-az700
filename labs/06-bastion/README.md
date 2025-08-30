# Azure Bastion Lab

## Overview
Secure RDP/SSH connectivity without public IPs

## Architecture
Windows and Linux VMs without public IPs, Bastion subnet

## What Gets Deployed
This lab creates the infrastructure needed to demonstrate azure bastion functionality. The actual azure bastion service configuration is done manually through the Azure Portal.

## Key Features
- Secure connectivity
- No public IPs
- Browser-based access
- Bastion host service

## Deployment
```powershell
.\deploy.ps1
```

## Manual Configuration Steps
After running the deployment script:

1. **Navigate to Azure Portal**
2. **Create Azure Bastion resource**
3. **Configure according to lab requirements**
4. **Test functionality**
5. **Observe behavior and results**

## Testing
Follow the specific testing procedures outlined in the deployment script output for hands-on experience with azure bastion.

## Cleanup
Delete the resource group when done:
```powershell
Remove-AzResourceGroup -Name "rg-az700-*" -Force
```

## Learning Objectives
- Understand azure bastion concepts and use cases
- Practice Azure networking configuration
- Learn about integration with other Azure services
- Gain hands-on experience with real-world scenarios

## Notes
- All scripts use cost-effective VM sizes and service tiers
- Authentication uses consistent credentials across labs
- Infrastructure is designed for learning and demonstration purposes
