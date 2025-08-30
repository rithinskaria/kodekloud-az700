# Azure Firewall Lab

## Overview
Network and application-level firewall protection

## Architecture
Private VM and jumpbox VM in separate subnets

## What Gets Deployed
This lab creates the infrastructure needed to demonstrate azure firewall functionality. The actual azure firewall service configuration is done manually through the Azure Portal.

## Key Features
- Network rules
- Application rules
- DNAT rules
- Threat intelligence

## Deployment
```powershell
.\deploy.ps1
```

## Manual Configuration Steps
After running the deployment script:

1. **Navigate to Azure Portal**
2. **Create Azure Firewall resource**
3. **Configure according to lab requirements**
4. **Test functionality**
5. **Observe behavior and results**

## Testing
Follow the specific testing procedures outlined in the deployment script output for hands-on experience with azure firewall.

## Cleanup
Delete the resource group when done:
```powershell
Remove-AzResourceGroup -Name "rg-az700-*" -Force
```

## Learning Objectives
- Understand azure firewall concepts and use cases
- Practice Azure networking configuration
- Learn about integration with other Azure services
- Gain hands-on experience with real-world scenarios

## Notes
- All scripts use cost-effective VM sizes and service tiers
- Authentication uses consistent credentials across labs
- Infrastructure is designed for learning and demonstration purposes
