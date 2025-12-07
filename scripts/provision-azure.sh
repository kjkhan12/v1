#!/bin/bash

# Azure AKS Provisioning Script for WeatherAPI
# This script creates all necessary Azure resources for the application

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Azure AKS Provisioning Script${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Variables - Customize these
RESOURCE_GROUP="rg-weatherapi-prod"
LOCATION="eastus"
ACR_NAME="acrweatherapi$(date +%s)"  # Append timestamp for uniqueness
AKS_NAME="aks-weatherapi-cluster"
AKS_NODE_COUNT=2
AKS_NODE_SIZE="Standard_D2s_v3"

echo -e "${YELLOW}Configuration:${NC}"
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "ACR Name: $ACR_NAME"
echo "AKS Name: $AKS_NAME"
echo "Node Count: $AKS_NODE_COUNT"
echo "Node Size: $AKS_NODE_SIZE"
echo ""

read -p "Continue with these settings? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${RED}Aborted by user${NC}"
    exit 1
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null
then
    echo -e "${RED}Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Login check
echo -e "${YELLOW}Checking Azure login status...${NC}"
az account show &> /dev/null || az login

# Create Resource Group
echo -e "${YELLOW}Creating Resource Group...${NC}"
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --output table

# Create Azure Container Registry
echo -e "${YELLOW}Creating Azure Container Registry...${NC}"
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --location $LOCATION \
  --output table

# Enable admin account (for development - not recommended for production)
echo -e "${YELLOW}Configuring ACR...${NC}"
az acr update --name $ACR_NAME --admin-enabled true

# Create AKS Cluster
echo -e "${YELLOW}Creating AKS Cluster (this may take 5-10 minutes)...${NC}"
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --node-count $AKS_NODE_COUNT \
  --node-vm-size $AKS_NODE_SIZE \
  --generate-ssh-keys \
  --attach-acr $ACR_NAME \
  --enable-managed-identity \
  --location $LOCATION \
  --network-plugin azure \
  --output table

# Get AKS credentials
echo -e "${YELLOW}Getting AKS credentials...${NC}"
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --overwrite-existing

# Verify connection
echo -e "${YELLOW}Verifying Kubernetes connection...${NC}"
kubectl get nodes

# Get ACR login server
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Provisioning Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}Resource Details:${NC}"
echo "Resource Group: $RESOURCE_GROUP"
echo "ACR Name: $ACR_NAME"
echo "ACR Login Server: $ACR_LOGIN_SERVER"
echo "AKS Cluster: $AKS_NAME"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Update your Azure DevOps pipeline variables:"
echo "   - ACR_NAME: $ACR_NAME"
echo "   - AKS_RESOURCE_GROUP: $RESOURCE_GROUP"
echo "   - AKS_CLUSTER_NAME: $AKS_NAME"
echo ""
echo "2. Create service connections in Azure DevOps:"
echo "   - Docker Registry connection to: $ACR_LOGIN_SERVER"
echo "   - Kubernetes connection to: $AKS_NAME"
echo ""
echo "3. Test ACR login:"
echo "   az acr login --name $ACR_NAME"
echo ""
echo "4. Build and push test image:"
echo "   docker build -t $ACR_LOGIN_SERVER/weatherapi:v1 ."
echo "   docker push $ACR_LOGIN_SERVER/weatherapi:v1"
echo ""
echo -e "${GREEN}Setup script completed successfully!${NC}"

# Save configuration to file
cat > azure-config.txt <<EOF
RESOURCE_GROUP=$RESOURCE_GROUP
LOCATION=$LOCATION
ACR_NAME=$ACR_NAME
ACR_LOGIN_SERVER=$ACR_LOGIN_SERVER
AKS_NAME=$AKS_NAME
AKS_NODE_COUNT=$AKS_NODE_COUNT
EOF

echo -e "${YELLOW}Configuration saved to: azure-config.txt${NC}"
