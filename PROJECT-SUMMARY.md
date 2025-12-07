# Project Summary: .NET 8 Weather API on Azure Kubernetes

## 📦 What's Included

This complete solution includes everything you need to deploy a .NET 8 application to Azure Kubernetes Service (AKS) with CI/CD:

### Application Files
```
src/WeatherApi/
├── Controllers/
│   └── WeatherForecastController.cs  ← API endpoints
├── Program.cs                         ← Application entry point
├── WeatherForecast.cs                 ← Data model
├── WeatherApi.csproj                  ← Project configuration
└── appsettings.json                   ← App settings
```

### Containerization
```
Dockerfile                             ← Multi-stage Docker build
.dockerignore                          ← Docker ignore rules
```

### Kubernetes Configuration
```
k8s/
├── deployment.yaml                    ← K8s deployment manifest
└── service.yaml                       ← K8s service (LoadBalancer)
```

### CI/CD Pipeline
```
azure-pipelines.yml                    ← Complete Azure DevOps pipeline
```

### Helper Scripts
```
scripts/
├── provision-azure.sh                 ← Automated Azure setup
└── cleanup-azure.sh                   ← Resource cleanup
```

### Documentation
```
README.md                              ← Comprehensive guide
QUICKSTART.md                          ← Fast-track deployment
.gitignore                             ← Git ignore rules
```

## 🎯 Key Features

### Application
- ✅ .NET 8 Web API
- ✅ Swagger/OpenAPI documentation
- ✅ Health check endpoint
- ✅ Structured logging
- ✅ Version endpoint

### Infrastructure
- ✅ Docker containerization
- ✅ Kubernetes deployment with 2 replicas
- ✅ LoadBalancer service for external access
- ✅ Resource limits and requests
- ✅ Liveness and readiness probes

### CI/CD
- ✅ Automated build on code push
- ✅ Docker image build and push to ACR
- ✅ Automated deployment to AKS
- ✅ Token replacement for environment-specific values
- ✅ Pipeline artifacts management

## 🚀 Deployment Steps

### 1. Azure Resources (5-10 minutes)
```bash
cd scripts
./provision-azure.sh
```
This creates:
- Resource Group
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS) with 2 nodes

### 2. Azure DevOps Setup (5 minutes)
1. Create project in Azure DevOps
2. Import/push code to Azure Repos
3. Create service connections:
   - Docker Registry → ACR
   - Kubernetes → AKS
4. Create variable group with ACR/AKS details
5. Create pipeline from `azure-pipelines.yml`

### 3. Deploy & Test (Automatic)
- Pipeline runs automatically on code push
- Build → Push to ACR → Deploy to AKS
- Get external IP: `kubectl get service weatherapi-service`
- Test: `curl http://<EXTERNAL-IP>/WeatherForecast`

## 📊 Architecture

```
Developer
    ↓ (git push)
Azure DevOps Pipeline
    ↓ (build)
Docker Image
    ↓ (push)
Azure Container Registry
    ↓ (pull)
Azure Kubernetes Service
    ├── Pod 1 (weatherapi)
    └── Pod 2 (weatherapi)
    ↓ (expose)
LoadBalancer Service
    ↓ (external access)
End Users
```

## 🔧 Configuration Points

### Azure Pipeline Variables
```yaml
ACR_NAME: your-acr-name
AKS_RESOURCE_GROUP: rg-weatherapi-prod
AKS_CLUSTER_NAME: aks-weatherapi-cluster
```

### Service Connections
1. **ACR-ServiceConnection**: Docker registry access
2. **AKS-ServiceConnection**: Kubernetes cluster access

### Kubernetes Resources
- **Deployment**: 2 replicas, resource limits, health probes
- **Service**: LoadBalancer type for external access

## 🧪 Testing Endpoints

Once deployed, test these endpoints:

```bash
# Get external IP
EXTERNAL_IP=$(kubectl get service weatherapi-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Weather forecast
curl http://$EXTERNAL_IP/WeatherForecast

# Health check
curl http://$EXTERNAL_IP/health

# Version info
curl http://$EXTERNAL_IP/WeatherForecast/version

# Swagger UI (browser)
http://$EXTERNAL_IP/swagger
```

## 📈 Monitoring & Management

```bash
# View pods
kubectl get pods

# View logs
kubectl logs -l app=weatherapi --tail=50 -f

# Scale up
kubectl scale deployment weatherapi --replicas=5

# Restart deployment
kubectl rollout restart deployment weatherapi

# Check deployment status
kubectl rollout status deployment weatherapi
```

## 💰 Cost Estimate

**Monthly costs (Development):**
- AKS: 2x Standard_D2s_v3 nodes = ~$140
- ACR Basic = ~$5
- Load Balancer = ~$20
- **Total: ~$165/month**

**Tip**: Stop/delete resources when not in use!

## 🎓 Learning Outcomes

After completing this project, you'll understand:
1. ✅ .NET containerization with Docker
2. ✅ Kubernetes deployment patterns
3. ✅ Azure Container Registry integration
4. ✅ Azure Kubernetes Service management
5. ✅ Azure DevOps CI/CD pipelines
6. ✅ Infrastructure as Code principles
7. ✅ Container orchestration basics

## 🔄 Next Steps

Enhance this solution with:
1. **Monitoring**: Azure Application Insights
2. **Secrets**: Azure Key Vault integration
3. **Ingress**: NGINX Ingress Controller with SSL/TLS
4. **Database**: Azure SQL or Cosmos DB
5. **Auth**: Azure AD authentication
6. **Testing**: Unit/integration tests in pipeline
7. **Scaling**: Horizontal Pod Autoscaler (HPA)

## 📚 Additional Resources

- [Full README.md](README.md) - Complete documentation
- [QUICKSTART.md](QUICKSTART.md) - Fast-track guide
- [Azure AKS Docs](https://docs.microsoft.com/azure/aks)
- [Azure DevOps Docs](https://docs.microsoft.com/azure/devops)

## 🤝 Support

For issues or questions:
1. Check the troubleshooting section in README.md
2. Review Azure DevOps pipeline logs
3. Check Kubernetes pod logs: `kubectl logs <pod-name>`
4. Verify service connections in Azure DevOps

## 🧹 Cleanup

When finished:
```bash
cd scripts
./cleanup-azure.sh
```

Or manually:
```bash
az group delete --name rg-weatherapi-prod --yes
```

---

**Project Status**: ✅ Ready to Deploy
**Estimated Setup Time**: 20-30 minutes
**Skill Level**: Intermediate
**Prerequisites**: Azure subscription, Azure DevOps account

**Created for**: Microsoft Azure & Kubernetes Training
**Version**: 1.0.0
**Last Updated**: December 2025
