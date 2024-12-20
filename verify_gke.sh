#!/bin/bash

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Error handling
set -e
trap 'handle_error $? $LINENO' ERR

handle_error() {
    echo -e "${RED}Error occurred in script at line: ${2}${NC}"
    case $1 in
        1) echo "General error - check permissions" ;;
        6) echo "GKE plugin not found" ;;
        7) echo "Authentication failed" ;;
        8) echo "Network connectivity issue" ;;
        *) echo "Unknown error: $1" ;;
    esac
}

# Function to check and fix GKE plugin
check_gke_plugin() {
    echo -e "\n${YELLOW}Checking GKE plugin...${NC}"
    if command -v gke-gcloud-auth-plugin &> /dev/null; then
        echo -e "${GREEN}✓ GKE plugin found${NC}"
        gke-gcloud-auth-plugin --version
    else
        echo -e "${RED}✗ GKE plugin not found${NC}"
        echo "Attempting to install..."
        gcloud components install gke-gcloud-auth-plugin
    fi
}

# Function to verify authentication
check_auth() {
    echo -e "\n${YELLOW}Verifying authentication...${NC}"
    if gcloud auth list --format="get(account)" | grep -q "@"; then
        echo -e "${GREEN}✓ Authentication active${NC}"
    else
        echo -e "${RED}✗ No active authentication${NC}"
        echo "Running auth login..."
        gcloud auth login
    fi
}

# Main execution
main() {
    echo -e "${YELLOW}=== Starting GKE Environment Verification ===${NC}"
    check_gke_plugin
    check_auth
    echo -e "\n${GREEN}=== Verification Complete ===${NC}"
}

# Run main function
main