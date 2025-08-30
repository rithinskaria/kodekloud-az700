# User-Defined Routes & NVA Lab

## Overview
Custom routing and network virtual appliances

## Architecture
Custom route tables and network virtual appliance for traffic control

## What Gets Deployed
This lab creates the infrastructure needed to demonstrate user-defined routes & nva functionality. The actual user-defined routes & nva service configuration is done manually through the Azure Portal.

## Key Features
- Custom routes
- Route tables
- Network appliances
- Traffic steering

## Deployment
```powershell
.\deploy.ps1
```

## Manual Configuration Steps
After running the deployment script:

1. **Navigate to Azure Portal**
2. **Create User-Defined Routes & NVA resource**
3. **Configure according to lab requirements**
4. **Test functionality**
5. **Observe behavior and results**

## Testing
Follow the specific testing procedures outlined in the deployment script output for hands-on experience with user-defined routes & nva.

## Cleanup
Delete the resource group when done:
```powershell
Remove-AzResourceGroup -Name "rg-az700-*" -Force
```

## Learning Objectives
- Understand user-defined routes & nva concepts and use cases
- Practice Azure networking configuration
- Learn about integration with other Azure services
- Gain hands-on experience with real-world scenarios

## Notes
- All scripts use cost-effective VM sizes and service tiers
- Authentication uses consistent credentials across labs
- Infrastructure is designed for learning and demonstration purposes
