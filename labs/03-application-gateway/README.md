# Application Gateway Lab

## Overview
Path-based routing demonstration with multiple backend pools

## Architecture
4 VMs in 2 subnets for API and Images backends

## What Gets Deployed
This lab creates the infrastructure needed to demonstrate application gateway functionality. The actual application gateway service configuration is done manually through the Azure Portal.

## Key Features
- Path-based routing
- Backend pools
- Health probes
- Load balancing rules

## Deployment
```powershell
.\deploy.ps1
```

## Manual Configuration Steps
After running the deployment script:

1. **Navigate to Azure Portal**
2. **Create Application Gateway resource**
3. **Configure according to lab requirements**
4. **Test functionality**
5. **Observe behavior and results**

## Testing
Follow the specific testing procedures outlined in the deployment script output for hands-on experience with application gateway.

## Cleanup
Delete the resource group when done:
```powershell
Remove-AzResourceGroup -Name "rg-az700-*" -Force
```

## Learning Objectives
- Understand application gateway concepts and use cases
- Practice Azure networking configuration
- Learn about integration with other Azure services
- Gain hands-on experience with real-world scenarios

## Notes
- All scripts use cost-effective VM sizes and service tiers
- Authentication uses consistent credentials across labs
- Infrastructure is designed for learning and demonstration purposes
