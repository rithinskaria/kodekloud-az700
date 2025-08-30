# AZ-700 Azure Networking Labs 🌐

[![Azure](https://img.shields.io/badge/Microsoft-Azure-0078d4?style=flat&logo=microsoft-azure)](https://azure.microsoft.com)
[![PowerShell](https://img.shields.io/badge/PowerShell-7.0+-blue?style=flat&logo=powershell)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

A comprehensive collection of hands-on lab exercises for mastering Azure networking concepts, designed specifically for the **AZ-700: Designing and Implementing Microsoft Azure Networking Solutions** certification exam.

## 🎯 Overview

This repository contains **15 structured labs** covering all major Azure networking services and concepts. Each lab includes clean PowerShell deployment scripts and detailed documentation to accelerate your learning journey.

## 📚 Lab Catalog

### 🔄 Load Balancing & Traffic Management
| Lab | Service | Focus Area |
|-----|---------|------------|
| [01](labs/01-load-balancer/) | **Azure Load Balancer** | Availability zones, backend pools |
| [02](labs/02-traffic-manager/) | **Traffic Manager** | Geographic routing, global distribution |
| [03](labs/03-application-gateway/) | **Application Gateway** | Path-based routing, SSL termination |
| [04](labs/04-front-door/) | **Azure Front Door** | Global CDN, edge locations |

### 🔒 Network Security
| Lab | Service | Focus Area |
|-----|---------|------------|
| [05](labs/05-nsg/) | **Network Security Groups** | Traffic filtering, security rules |
| [06](labs/06-bastion/) | **Azure Bastion** | Secure RDP/SSH access |
| [07](labs/07-azure-firewall/) | **Azure Firewall** | Network/application rules |
| [08](labs/08-waf/) | **Web Application Firewall** | OWASP protection, attack prevention |

### 🌐 Connectivity & Routing
| Lab | Service | Focus Area |
|-----|---------|------------|
| [09](labs/09-service-endpoints/) | **Service Endpoints** | Private Azure service access |
| [10](labs/10-nat-gateway/) | **NAT Gateway** | Outbound internet connectivity |
| [11](labs/11-peering/) | **VNet Peering** | Cross-region connectivity |
| [12](labs/12-private-dns/) | **Private DNS** | Internal name resolution |
| [13](labs/13-udr-nva/) | **Custom Routes & NVA** | Traffic steering, appliances |
| [14](labs/14-vpn-p2s/) | **Point-to-Site VPN** | Remote access connectivity |
| [15](labs/15-vwan/) | **Virtual WAN** | Global network architecture |

## 🚀 Quick Start

### Prerequisites
- **Azure Subscription** with sufficient quotas
- **Azure PowerShell** module installed
- **Contributor** permissions on target subscription

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/az-700-labs.git
cd az-700-labs

# Install Azure PowerShell (if needed)
Install-Module -Name Az -AllowClobber -Scope CurrentUser
```

### Usage Pattern
```powershell
# 1. Navigate to desired lab
cd labs/01-load-balancer

# 2. Review the lab guide
Get-Content README.md

# 3. Deploy infrastructure
.\deploy.ps1

# 4. Follow manual configuration steps
# 5. Test and explore functionality
# 6. Clean up resources when done
```

## 💡 Lab Features

- **🧹 Clean Code**: Comment-free scripts focused on execution
- **📖 Rich Documentation**: Comprehensive README for each lab
- **💰 Cost Optimized**: B-series VMs and Free/Basic service tiers
- **🔄 Consistent**: Standardized authentication and naming
- **🎓 Educational**: Real-world scenarios and best practices
- **⚡ Fast Deployment**: Efficient infrastructure provisioning

## 🔐 Authentication

All labs use consistent credentials for simplicity:
- **Username**: kodekloud
- **Password**: @dminP@55w0rd

> ⚠️ **Note**: These are lab credentials only. Use strong, unique passwords in production.

## 📋 Learning Path

### Beginner (Fundamentals)
1. **NSG** → **Load Balancer** → **Service Endpoints**

### Intermediate (Advanced Services)
2. **Application Gateway** → **Bastion** → **Private DNS**

### Advanced (Complex Scenarios)
3. **Front Door** → **Azure Firewall** → **Virtual WAN**

### Expert (Security & Integration)
4. **WAF** → **UDR/NVA** → **VPN** → **Peering**

## 🛠️ Troubleshooting

### Common Issues
- **Quota Limits**: Check regional VM quotas
- **Naming Conflicts**: Scripts use random suffixes
- **Permissions**: Ensure Contributor role assignment
- **Region Availability**: Some services limited by region

### Support Resources
- [Azure Documentation](https://docs.microsoft.com/azure/)
- [AZ-700 Exam Guide](https://docs.microsoft.com/learn/certifications/exams/az-700)
- [Azure PowerShell Reference](https://docs.microsoft.com/powershell/azure/)

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎖️ Certification Journey

These labs are designed to prepare you for the **AZ-700** exam objectives:

- ✅ **Design, implement, and manage hybrid networking** (25–30%)
- ✅ **Design and implement core networking infrastructure** (20–25%)  
- ✅ **Design and implement routing** (25–30%)
- ✅ **Secure and monitor networks** (15–20%)

## ⭐ Acknowledgments

Created for the Azure networking community to accelerate learning and certification success.

---

**Happy Learning!** 🎓 | **Good Luck with AZ-700!** 🍀

---

*If you find these labs helpful, please ⭐ star the repository!*
