# Azure Traffic Manager Lab

## Overview
This lab demonstrates Azure Traffic Manager routing traffic to App Services across multiple geographic regions based on user location.

## Architecture
- **Resource Group**: rg-az700-tm
- **Regions**: East US, West Europe, Southeast Asia
- **App Services**: 3 identical web applications across continents
- **Traffic Manager**: Geographic routing (to be created manually)

## What Gets Deployed
1. Resource group in East US
2. App Service Plans in all 3 regions (Free Tier F1)
3. App Services with custom landing pages
4. Regional content showing origin location

## Regional Configuration
- **East US**: Serves North American traffic
- **West Europe**: Serves European traffic  
- **Southeast Asia**: Serves Asian traffic

## App Service Details
- **Tier**: Free (F1)
- **Content**: Custom HTML pages with regional identification
- **Unique Names**: Random suffix for global uniqueness
- **Regional Branding**: Each app shows its origin region

## Deployment
```powershell
.\deploy.ps1
```

## Manual Configuration Steps
After running the script, create Traffic Manager manually:

1. **Create Traffic Manager Profile**
   - Go to Azure Portal > Create Resource > Traffic Manager Profile
   - Routing Method: Geographic
   - DNS name: Choose unique name
   - Resource group: rg-az700-tm

2. **Add Endpoints**
   - Add all 3 App Services as endpoints
   - Configure geographic mappings:
     - East US → North America
     - West Europe → Europe
     - Southeast Asia → Asia

3. **Configure Geographic Mappings**
   - Assign continents/countries to each endpoint
   - Set up failover priorities

## Testing Methods
1. **Direct Access**: Visit each App Service URL directly
2. **Traffic Manager**: Access via Traffic Manager FQDN
3. **VPN Testing**: Use VPN to test from different regions
4. **Online Tools**: Use geolocation testing websites
5. **DNS Lookup**: Check DNS resolution from different locations

## Expected Results
- Users from North America → routed to East US
- Users from Europe → routed to West Europe
- Users from Asia → routed to Southeast Asia
- Each page displays the serving region clearly

## Routing Methods Available
- **Geographic**: Route based on user location (used in this lab)
- **Performance**: Route to fastest endpoint
- **Priority**: Failover routing
- **Weighted**: Distribute traffic by percentage
- **Multivalue**: Return multiple healthy endpoints

## Cleanup
Delete the resource group when done:
```powershell
Remove-AzResourceGroup -Name "rg-az700-tm" -Force
```

## Learning Objectives
- Understand Traffic Manager geographic routing
- Learn about global load balancing
- Practice multi-region App Service deployment
- Understand DNS-based traffic management
- Observe geographic traffic distribution
