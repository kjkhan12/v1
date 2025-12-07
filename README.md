# .NET 8 Weather API - Azure Kubernetes Deployment

A simple .NET 8 Web API application demonstrating CI/CD deployment to Azure Kubernetes Service (AKS) using Azure DevOps.

## 📋 Prerequisites

- Azure Subscription
- Azure DevOps Organization
- Azure CLI installed
- kubectl installed
- Docker Desktop (for local testing)
- .NET 8 SDK
- Git

## 🏗️ Project Structure

```
dotnet-aks-demo/
├── src/
│   └── WeatherApi/
│       ├── Controllers/
│       │   └── WeatherForecastController.cs
│       ├── WeatherForecast.cs
│       ├── Program.cs
│       ├── WeatherApi.csproj
│       └── appsettings.json
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── Dockerfile
├── .dockerignore
├── .gitignore
└── azure-pipelines.yml
```

## 🚀 Step-by-Step Deployment Guide

### Step 1: Clone and Test Locally

```bash
# Clone the repository
git clone <your-repo-url>
cd dotnet-aks-demo

# Restore and run locally
cd src/WeatherApi
dotnet restore
dotnet run

# Test the API
curl http://localhost:5000/WeatherForecast
curl http://localhost:5000/WeatherForecast/version
```

### Step 2: Create Azure Resources

```bash
# Login to Azure
az login

# Set variables
RESOURCE_GROUP="rg-weatherapi-prod"
LOCATION="eastus"
ACR_NAME="acrweatherapi"  # Must be globally unique, lowercase
AKS_NAME="aks-weatherapi-cluster"
AKS_NODE_COUNT=2

# Create Resource Group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create Azure Container Registry
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --location $LOCATION

# Create AKS Cluster
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --node-count $AKS_NODE_COUNT \
  --node-vm-size Standard_D2s_v3 \
  --generate-ssh-keys \
  --attach-acr $ACR_NAME \
  --enable-managed-identity \
  --location $LOCATION

# Get AKS credentials
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME

# Verify connection
kubectl get nodes
```

### Step 3: Test Docker Build Locally

```bash
# Build the Docker image
docker build -t weatherapi:local -f Dockerfile .

# Run the container locally
docker run -d -p 8080:8080 --name weatherapi-test weatherapi:local

# Test the containerized API
curl http://localhost:8080/WeatherForecast
curl http://localhost:8080/health

# Stop and remove
docker stop weatherapi-test
docker rm weatherapi-test
```

### Step 4: Push to Azure Container Registry (Manual Test)

```bash
# Login to ACR
az acr login --name $ACR_NAME

# Tag and push image
docker tag weatherapi:local $ACR_NAME.azurecr.io/weatherapi:v1
docker push $ACR_NAME.azurecr.io/weatherapi:v1

# Verify image in ACR
az acr repository list --name $ACR_NAME --output table
az acr repository show-tags --name $ACR_NAME --repository weatherapi --output table
```

### Step 5: Set Up Azure DevOps

#### 5.1 Create Azure DevOps Project

1. Go to https://dev.azure.com
2. Create a new organization (if needed)
3. Create a new project: "WeatherAPI-AKS"

#### 5.2 Import Repository

1. In your Azure DevOps project, go to **Repos**
2. Import your Git repository or push code:

```bash
# Initialize git (if not already done)
git init
git add .
git commit -m "Initial commit"

# Add Azure DevOps remote
git remote add origin https://dev.azure.com/<org>/<project>/_git/weatherapi
git push -u origin main
```

#### 5.3 Create Service Connections

##### Azure Container Registry Service Connection:
1. Go to **Project Settings** → **Service connections**
2. Click **New service connection** → **Docker Registry**
3. Select **Azure Container Registry**
4. Choose your subscription and ACR
5. Name it: `ACR-ServiceConnection`
6. Save

##### AKS Service Connection:
1. Click **New service connection** → **Kubernetes**
2. Select **Azure Subscription**
3. Choose your subscription, resource group, and AKS cluster
4. Name it: `AKS-ServiceConnection`
5. Save

#### 5.4 Create Pipeline Variables

1. Go to **Pipelines** → **Library**
2. Create a Variable Group: `AKS-Deploy-Variables`
3. Add these variables:
   - `ACR_NAME`: Your ACR name (e.g., acrweatherapi)
   - `AKS_RESOURCE_GROUP`: Your resource group name
   - `AKS_CLUSTER_NAME`: Your AKS cluster name

#### 5.5 Create Pipeline

1. Go to **Pipelines** → **Create Pipeline**
2. Select **Azure Repos Git**
3. Select your repository
4. Choose **Existing Azure Pipelines YAML file**
5. Select `/azure-pipelines.yml`
6. Click **Run**

### Step 6: Configure Pipeline Variables in YAML

Update the pipeline to use the variable group:

```yaml
variables:
- group: AKS-Deploy-Variables
```

### Step 7: Monitor Deployment

```bash
# Watch pods starting up
kubectl get pods -w

# Check deployment status
kubectl get deployments

# Check service
kubectl get services

# Get external IP (wait until EXTERNAL-IP is assigned)
kubectl get service weatherapi-service -w

# Once IP is assigned, test the API
EXTERNAL_IP=$(kubectl get service weatherapi-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$EXTERNAL_IP/WeatherForecast
curl http://$EXTERNAL_IP/health
curl http://$EXTERNAL_IP/WeatherForecast/version
```

### Step 8: Access Swagger UI

Once deployed, access Swagger at:
```
http://<EXTERNAL-IP>/swagger
```

## 📊 Verify the Deployment

```bash
# Check all resources
kubectl get all

# View logs
kubectl logs -l app=weatherapi --tail=50

# Describe pod for details
kubectl describe pod <pod-name>

# Execute commands in pod
kubectl exec -it <pod-name> -- /bin/bash
```

## 🔄 CI/CD Pipeline Flow

1. **Trigger**: Code push to `main` or `develop` branch
2. **Build Stage**:
   - Build Docker image
   - Push to Azure Container Registry
   - Publish Kubernetes manifests as artifacts
3. **Deploy Stage**:
   - Download manifests
   - Replace tokens (image tag, ACR name)
   - Deploy to AKS cluster
   - Display service details

## 🛠️ Manual Kubernetes Deployment (Alternative)

If you want to deploy manually without CI/CD:

```bash
# Update deployment.yaml with your ACR and image tag
# Replace __ACR_NAME__ with your ACR name
# Replace __BUILD_ID__ with a version tag

# Apply manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Monitor rollout
kubectl rollout status deployment/weatherapi
```

## 📈 Scaling the Application

```bash
# Scale replicas
kubectl scale deployment weatherapi --replicas=5

# Enable autoscaling
kubectl autoscale deployment weatherapi --min=2 --max=10 --cpu-percent=80

# Check HPA status
kubectl get hpa
```

## 🔍 Troubleshooting

### Check Pod Status
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check Service
```bash
kubectl get svc weatherapi-service
kubectl describe svc weatherapi-service
```

### Check Events
```bash
kubectl get events --sort-by='.lastTimestamp'
```

### Access Pod Shell
```bash
kubectl exec -it <pod-name> -- /bin/bash
```

### Check ACR Images
```bash
az acr repository show-tags --name $ACR_NAME --repository weatherapi
```

## 🔐 Security Best Practices

1. **Use Azure Key Vault** for secrets
2. **Enable RBAC** on AKS
3. **Use managed identities** instead of service principals
4. **Implement network policies**
5. **Enable Azure Policy** for AKS
6. **Use private ACR endpoints**

## 🧹 Cleanup

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/

# Delete AKS cluster
az aks delete --resource-group $RESOURCE_GROUP --name $AKS_NAME --yes --no-wait

# Delete ACR
az acr delete --resource-group $RESOURCE_GROUP --name $ACR_NAME --yes

# Delete Resource Group (deletes everything)
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## 📚 API Endpoints

- `GET /WeatherForecast` - Get weather forecast
- `GET /WeatherForecast/version` - Get application version
- `GET /health` - Health check endpoint
- `GET /swagger` - Swagger UI (development)

## 🎯 Next Steps

1. Add Azure Application Insights for monitoring
2. Implement Azure Key Vault for secrets
3. Set up Ingress Controller with SSL/TLS
4. Add database connectivity (Azure SQL/Cosmos DB)
5. Implement authentication (Azure AD)
6. Add automated testing in pipeline
7. Implement blue-green or canary deployments

## 📖 Additional Resources

- [.NET Documentation](https://docs.microsoft.com/dotnet)
- [Azure Kubernetes Service](https://docs.microsoft.com/azure/aks)
- [Azure DevOps](https://docs.microsoft.com/azure/devops)
- [Docker Documentation](https://docs.docker.com)
- [Kubernetes Documentation](https://kubernetes.io/docs)

## 💡 Tips

- Monitor costs using Azure Cost Management (Standard_D2s_v3: ~$70/node/month)
- Use Azure DevOps Pipeline approvals for production
- Implement proper tagging strategy for resources
- Use Azure Monitor for observability
- Regular security scanning of container images

---

**Author**: Created for Azure Kubernetes and DevOps Training
**Version**: 1.0.0
**Last Updated**: December 2025
