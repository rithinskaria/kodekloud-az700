# AZ-700 Azure Networking Labs

This repository contains hands-on lab exercises for Azure networking concepts covered in the AZ-700 certification exam.

## Lab Structure
Each lab is organized in its own folder with:
- **deploy.ps1**: Clean PowerShell script for infrastructure deployment
- **README.md**: Detailed lab instructions and learning objectives

## Available Labs

### Load Balancing & Traffic Management
- **01-load-balancer**: Azure Load Balancer with availability zones
- **02-traffic-manager**: Geographic traffic routing across continents
- **03-application-gateway**: Path-based routing and SSL termination
- **04-front-door**: Global content delivery and load balancing

### Network Security
- **05-nsg**: Network Security Groups and traffic filtering
- **06-bastion**: Secure remote access without public IPs
- **07-azure-firewall**: Network and application-level protection
- **08-waf**: Web Application Firewall with attack protection

### Connectivity & Routing
- **09-service-endpoints**: Secure Azure service access from VNets
- **10-nat-gateway**: Outbound internet connectivity for private resources
- **11-peering**: Virtual network peering across regions
- **12-private-dns**: Private DNS zones for internal name resolution
- **13-udr-nva**: Custom routing with network virtual appliances
- **14-vpn-p2s**: Point-to-site VPN for remote access
- **15-vwan**: Virtual WAN for global network architecture

## Prerequisites
- Azure subscription with sufficient quotas
- Azure PowerShell module installed
- Appropriate permissions to create resources

## Common Credentials
All labs use consistent authentication:
- **Username**: kodekloud
- **Password**: @dminP@55w0rd

## Cost Optimization
- All VMs use cost-effective B-series sizes
- App Services use Free or Basic tiers where possible
- Resources are designed for learning, not production

## Usage Pattern
1. Navigate to desired lab folder
2. Read the README.md for context
3. Run .\deploy.ps1 to create infrastructure
4. Follow manual configuration steps
5. Test and observe functionality
6. Clean up resources when done

## Learning Path
Recommended order for comprehensive understanding:
1. Start with basic concepts (NSG, Load Balancer)
2. Progress to advanced routing (Application Gateway, Front Door)
3. Explore security features (Bastion, Firewall, WAF)
4. Learn connectivity patterns (Peering, VPN, Virtual WAN)

Happy learning! 🎓
