# Azure Front Door Lab

## Overview
Global content delivery and load balancing across continents

## Architecture
4 App Services across 4 continents with regional content

## What Gets Deployed
This lab creates the infrastructure needed to demonstrate azure front door functionality. The actual azure front door service configuration is done manually through the Azure Portal.

## Key Features
- Global load balancing
- CDN capabilities
- Edge locations
- Health monitoring

## Deployment
```powershell
.\deploy.ps1
```

## Manual Configuration Steps
After running the deployment script:

1. **Navigate to Azure Portal**
2. **Create Azure Front Door resource**
3. **Configure according to lab requirements**
4. **Test functionality**
5. **Observe behavior and results**

## Testing
Follow the specific testing procedures outlined in the deployment script output for hands-on experience with azure front door.

## Cleanup
Delete the resource group when done:
```powershell
Remove-AzResourceGroup -Name "rg-az700-*" -Force
```

## Learning Objectives
- Understand azure front door concepts and use cases
- Practice Azure networking configuration
- Learn about integration with other Azure services
- Gain hands-on experience with real-world scenarios

## Notes
- All scripts use cost-effective VM sizes and service tiers
- Authentication uses consistent credentials across labs
- Infrastructure is designed for learning and demonstration purposes
