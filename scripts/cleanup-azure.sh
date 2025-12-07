#!/bin/bash

# Azure Resource Cleanup Script
# WARNING: This will delete all resources created for the WeatherAPI project

set -e

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}================================${NC}"
echo -e "${RED}Azure Resource Cleanup Script${NC}"
echo -e "${RED}================================${NC}"
echo ""
echo -e "${RED}WARNING: This will DELETE all resources!${NC}"
echo ""

# Try to load configuration
if [ -f "azure-config.txt" ]; then
    source azure-config.txt
    echo -e "${YELLOW}Loaded configuration from azure-config.txt${NC}"
else
    # Default values if config file doesn't exist
    RESOURCE_GROUP="rg-weatherapi-prod"
    echo -e "${YELLOW}Using default resource group: $RESOURCE_GROUP${NC}"
fi

echo ""
echo -e "${YELLOW}Resources to be deleted:${NC}"
echo "Resource Group: $RESOURCE_GROUP"
echo ""
echo -e "${RED}This action cannot be undone!${NC}"
echo ""

read -p "Are you sure you want to delete all resources? Type 'DELETE' to confirm: " CONFIRM

if [ "$CONFIRM" != "DELETE" ]; then
    echo -e "${YELLOW}Aborted by user${NC}"
    exit 1
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null
then
    echo -e "${RED}Azure CLI is not installed.${NC}"
    exit 1
fi

# Login check
echo -e "${YELLOW}Checking Azure login status...${NC}"
az account show &> /dev/null || az login

# Delete Resource Group (this deletes everything in it)
echo -e "${YELLOW}Deleting Resource Group (this may take several minutes)...${NC}"
az group delete \
  --name $RESOURCE_GROUP \
  --yes \
  --no-wait

echo ""
echo -e "${YELLOW}Deletion initiated. Resources are being deleted in the background.${NC}"
echo -e "${YELLOW}Check status with: az group show --name $RESOURCE_GROUP${NC}"
echo ""
echo "To monitor deletion progress:"
echo "az group wait --name $RESOURCE_GROUP --deleted"
