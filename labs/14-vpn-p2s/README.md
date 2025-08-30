# Point-to-Site VPN Lab

## Overview
Secure remote access to Azure virtual networks

## Architecture
VPN Gateway with certificate-based authentication

## What Gets Deployed
This lab creates the infrastructure needed to demonstrate point-to-site vpn functionality. The actual point-to-site vpn service configuration is done manually through the Azure Portal.

## Key Features
- Remote access
- Certificate auth
- VPN client
- Secure tunneling

## Deployment
```powershell
.\deploy.ps1
```

## Manual Configuration Steps
After running the deployment script:

1. **Navigate to Azure Portal**
2. **Create Point-to-Site VPN resource**
3. **Configure according to lab requirements**
4. **Test functionality**
5. **Observe behavior and results**

## Testing
Follow the specific testing procedures outlined in the deployment script output for hands-on experience with point-to-site vpn.

## Cleanup
Delete the resource group when done:
```powershell
Remove-AzResourceGroup -Name "rg-az700-*" -Force
```

## Learning Objectives
- Understand point-to-site vpn concepts and use cases
- Practice Azure networking configuration
- Learn about integration with other Azure services
- Gain hands-on experience with real-world scenarios

## Notes
- All scripts use cost-effective VM sizes and service tiers
- Authentication uses consistent credentials across labs
- Infrastructure is designed for learning and demonstration purposes
