# Quick Start Guide - .NET 8 on Azure Kubernetes

## 🎯 Overview
This guide helps you deploy a .NET 8 Weather API to Azure Kubernetes Service (AKS) using Azure DevOps CI/CD in under 30 minutes.

## ⚡ Fast Track Deployment

### Option 1: Automated Setup (Recommended)

```bash
# 1. Run the provisioning script
cd scripts
./provision-azure.sh

# 2. Push code to Azure DevOps
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-azure-devops-repo-url>
git push -u origin main

# 3. Create pipeline in Azure DevOps UI
# Follow steps in README.md Section 5.5
```

### Option 2: Manual Azure Setup

```bash
# Set your variables
RESOURCE_GROUP="rg-weatherapi-prod"
LOCATION="eastus"
ACR_NAME="acrweatherapi$(date +%s)"
AKS_NAME="aks-weatherapi-cluster"

# Create resources
az group create --name $RESOURCE_GROUP --location $LOCATION
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic
az aks create --resource-group $RESOURCE_GROUP --name $AKS_NAME \
  --node-count 2 --node-vm-size Standard_D2s_v3 --attach-acr $ACR_NAME --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
```

## 📋 Prerequisites Checklist

- [ ] Azure Subscription active
- [ ] Azure CLI installed: `az --version`
- [ ] kubectl installed: `kubectl version --client`
- [ ] Docker installed: `docker --version`
- [ ] .NET 8 SDK installed: `dotnet --version`
- [ ] Git installed: `git --version`
- [ ] Azure DevOps account created

## 🔑 Key Configuration Points

### Azure DevOps Service Connections
1. **ACR Connection**: Name it `ACR-ServiceConnection`
2. **AKS Connection**: Name it `AKS-ServiceConnection`

### Pipeline Variables
Create variable group: `AKS-Deploy-Variables`
- `ACR_NAME`: Your ACR name
- `AKS_RESOURCE_GROUP`: Resource group name
- `AKS_CLUSTER_NAME`: AKS cluster name

## 🧪 Testing the Deployment

```bash
# Get external IP
kubectl get service weatherapi-service

# Test endpoints (replace <EXTERNAL-IP>)
curl http://<EXTERNAL-IP>/WeatherForecast
curl http://<EXTERNAL-IP>/health
curl http://<EXTERNAL-IP>/WeatherForecast/version
curl http://<EXTERNAL-IP>/swagger
```

## 🐛 Quick Troubleshooting

### Pipeline Fails
```bash
# Check service connections are authorized
# Verify variable group is linked
# Check ACR name is correct (lowercase, no special chars)
```

### Pods Not Starting
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### No External IP
```bash
# Wait 2-3 minutes for Azure to assign IP
kubectl get service weatherapi-service -w
```

### Image Pull Errors
```bash
# Verify ACR is attached to AKS
az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME \
  --query addonProfiles.acrProfile
```

## 📊 Common Commands

```bash
# View all resources
kubectl get all

# Scale application
kubectl scale deployment weatherapi --replicas=3

# View logs
kubectl logs -l app=weatherapi --tail=100 -f

# Restart deployment
kubectl rollout restart deployment weatherapi

# Check pod details
kubectl describe pod <pod-name>
```

## 🔄 Making Changes

1. Update code locally
2. Commit and push to main branch
3. Pipeline automatically triggers
4. Monitor in Azure DevOps → Pipelines
5. Verify deployment: `kubectl get pods`

## 💡 Pro Tips

1. **Cost Optimization**: Use `Standard_D2s_v3` nodes (or smaller if available in your region)
2. **Monitoring**: Enable Azure Monitor for containers
3. **Security**: Use Azure Key Vault for secrets
4. **Scaling**: Configure HPA (Horizontal Pod Autoscaler)
5. **Networking**: Add Ingress Controller for production

## 🎓 Learning Path

1. ✅ Deploy basic application (you are here)
2. Add Azure Application Insights
3. Implement Azure Key Vault integration
4. Set up Ingress with SSL/TLS
5. Add database (Azure SQL/Cosmos DB)
6. Implement authentication
7. Add automated tests to pipeline

## 📞 Support Resources

- **Azure CLI Docs**: https://docs.microsoft.com/cli/azure
- **AKS Docs**: https://docs.microsoft.com/azure/aks
- **Azure DevOps**: https://docs.microsoft.com/azure/devops
- **kubectl Cheat Sheet**: https://kubernetes.io/docs/reference/kubectl/cheatsheet

## 🧹 Cleanup

```bash
# Delete everything
cd scripts
./cleanup-azure.sh

# Or manually
az group delete --name $RESOURCE_GROUP --yes
```

## ⏱️ Estimated Costs

**Development Setup:**
- AKS (2x Standard_D2s_v3 nodes): ~$140/month
- ACR Basic: ~$5/month
- Load Balancer: ~$20/month
- **Total**: ~$165/month

**Tip**: Delete resources when not in use to save costs!

---

**Next**: See README.md for detailed explanations of each step
