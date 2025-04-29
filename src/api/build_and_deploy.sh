#!/bin/bash

# Script to build and deploy a Docker image to Azure Container App

set -e  # Exit immediately if a command exits with a non-zero status

# Default values
DEFAULT_IMAGE_NAME="pwc-hve-api"
DEFAULT_IMAGE_TAG="latest"
DEFAULT_RESOURCE_GROUP="pwc-hve-rg"
DEFAULT_LOCATION="eastus"
DEFAULT_ENVIRONMENT="pwc-hve-env"
DEFAULT_CONTAINER_APP_NAME="pwc-hve-api"
DEFAULT_CPU="0.5"
DEFAULT_MEMORY="1Gi"
DEFAULT_MIN_REPLICAS="1"
DEFAULT_MAX_REPLICAS="3"
DEFAULT_PORT="8000"

# Display help message
function show_help {
    echo "Usage: $0 [options]"
    echo ""
    echo "Build and deploy a Docker image to Azure Container App"
    echo ""
    echo "Options:"
    echo "  -i, --image-name NAME         Docker image name (default: $DEFAULT_IMAGE_NAME)"
    echo "  -t, --image-tag TAG           Docker image tag (default: $DEFAULT_IMAGE_TAG)"
    echo "  -s, --subscription-id ID      Azure subscription ID (required)"
    echo "  -r, --resource-group NAME     Azure resource group name (default: $DEFAULT_RESOURCE_GROUP)"
    echo "  -l, --location LOCATION       Azure location (default: $DEFAULT_LOCATION)"
    echo "  -e, --environment NAME        Azure Container App environment name (default: $DEFAULT_ENVIRONMENT)"
    echo "  -n, --name NAME               Azure Container App name (default: $DEFAULT_CONTAINER_APP_NAME)"
    echo "  -c, --cpu CPU                 CPU allocation (default: $DEFAULT_CPU)"
    echo "  -m, --memory MEMORY           Memory allocation (default: $DEFAULT_MEMORY)"
    echo "  --min-replicas COUNT          Minimum replicas (default: $DEFAULT_MIN_REPLICAS)"
    echo "  --max-replicas COUNT          Maximum replicas (default: $DEFAULT_MAX_REPLICAS)"
    echo "  -p, --port PORT               Container port (default: $DEFAULT_PORT)"
    echo "  -h, --help                    Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -i myapi -t v1 -s 00000000-0000-0000-0000-000000000000 -r myresourcegroup"
    exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -i|--image-name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -t|--image-tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        -s|--subscription-id)
            SUBSCRIPTION_ID="$2"
            shift 2
            ;;
        -r|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -n|--name)
            CONTAINER_APP_NAME="$2"
            shift 2
            ;;
        -c|--cpu)
            CPU="$2"
            shift 2
            ;;
        -m|--memory)
            MEMORY="$2"
            shift 2
            ;;
        --min-replicas)
            MIN_REPLICAS="$2"
            shift 2
            ;;
        --max-replicas)
            MAX_REPLICAS="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Set default values if not provided
IMAGE_NAME=${IMAGE_NAME:-$DEFAULT_IMAGE_NAME}
IMAGE_TAG=${IMAGE_TAG:-$DEFAULT_IMAGE_TAG}
RESOURCE_GROUP=${RESOURCE_GROUP:-$DEFAULT_RESOURCE_GROUP}
LOCATION=${LOCATION:-$DEFAULT_LOCATION}
ENVIRONMENT=${ENVIRONMENT:-$DEFAULT_ENVIRONMENT}
CONTAINER_APP_NAME=${CONTAINER_APP_NAME:-$DEFAULT_CONTAINER_APP_NAME}
CPU=${CPU:-$DEFAULT_CPU}
MEMORY=${MEMORY:-$DEFAULT_MEMORY}
MIN_REPLICAS=${MIN_REPLICAS:-$DEFAULT_MIN_REPLICAS}
MAX_REPLICAS=${MAX_REPLICAS:-$DEFAULT_MAX_REPLICAS}
PORT=${PORT:-$DEFAULT_PORT}

# Check if subscription ID is provided
if [[ -z "$SUBSCRIPTION_ID" ]]; then
    echo "Error: Azure subscription ID is required."
    show_help
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if required tools are installed
if ! command_exists "docker"; then
    echo "Error: docker is not installed. Please install docker first."
    exit 1
fi

if ! command_exists "az"; then
    echo "Error: Azure CLI is not installed. Please install it first."
    exit 1
fi

# Login to Azure if not already logged in
echo "Checking Azure login status..."
az account show > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Not logged in to Azure. Please login."
    az login
fi

# Set the subscription
echo "Setting Azure subscription to $SUBSCRIPTION_ID..."
az account set --subscription "$SUBSCRIPTION_ID"

# Check if resource group exists, create if it doesn't
echo "Checking if resource group $RESOURCE_GROUP exists..."
if ! az group show --name "$RESOURCE_GROUP" > /dev/null 2>&1; then
    echo "Resource group $RESOURCE_GROUP does not exist, creating..."
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
else
    echo "Resource group $RESOURCE_GROUP exists."
fi

# Build the Docker image
echo "Building Docker image $IMAGE_NAME:$IMAGE_TAG..."
docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

# Ensure Azure Container Registry extension is installed
echo "Ensuring Azure Container Apps extension is installed..."
az extension add --name containerapp --upgrade

# Check if Container App environment exists
echo "Checking if Container App environment $ENVIRONMENT exists..."
if ! az containerapp env show --name "$ENVIRONMENT" --resource-group "$RESOURCE_GROUP" > /dev/null 2>&1; then
    echo "Container App environment $ENVIRONMENT does not exist, creating..."
    az containerapp env create \
        --name "$ENVIRONMENT" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION"
else
    echo "Container App environment $ENVIRONMENT exists."
fi

# Check if the Container App exists
echo "Checking if Container App $CONTAINER_APP_NAME exists..."
if ! az containerapp show --name "$CONTAINER_APP_NAME" --resource-group "$RESOURCE_GROUP" > /dev/null 2>&1; then
    echo "Container App $CONTAINER_APP_NAME does not exist, creating..."
        
    # Create the Container App
    az containerapp create \
        --name "$CONTAINER_APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --environment "$ENVIRONMENT" \
        --image "$IMAGE_NAME:$IMAGE_TAG" \
        --target-port "$PORT" \
        --ingress "external" \
        --min-replicas "$MIN_REPLICAS" \
        --max-replicas "$MAX_REPLICAS" \
        --cpu "$CPU" \
        --memory "$MEMORY"
    
    echo "Container App $CONTAINER_APP_NAME created."
else
    echo "Container App $CONTAINER_APP_NAME exists, updating..."
    
    # Update the Container App with the new image
    az containerapp update \
        --name "$CONTAINER_APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --image "$IMAGE_NAME:$IMAGE_TAG" \
        --cpu "$CPU" \
        --memory "$MEMORY" \
        --min-replicas "$MIN_REPLICAS" \
        --max-replicas "$MAX_REPLICAS"
    
    echo "Container App $CONTAINER_APP_NAME updated."
fi

echo ""
echo "Deployment completed successfully!"
echo "Access your Container App at: $(az containerapp show --name "$CONTAINER_APP_NAME" --resource-group "$RESOURCE_GROUP" --query properties.configuration.ingress.fqdn -o tsv)"
