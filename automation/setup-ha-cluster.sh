#!/bin/bash

# =============================================================================
# MicroK8s Cluster Management Setup Script
# Erstellt von: Sebastian Meyer
# Zweck: Setup aller HA-Optimierungen und Pod-Scheduling Tools
# =============================================================================

# Farben für bessere Lesbarkeit
GREEN='\033[0;32m' 
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 MicroK8s HA Cluster Setup${NC}"
echo -e "${BLUE}=============================${NC}"
echo

# 1. Failure Domain Configuration
echo -e "${GREEN}📍 Step 1: Configure Failure Domains${NC}"
if [ -f "./automation/configure-failure-domain.sh" ]; then
    chmod +x ./automation/configure-failure-domain.sh
    ./automation/configure-failure-domain.sh
    echo -e "${GREEN}✅ Failure domain configured for this node${NC}"
else
    echo -e "${YELLOW}⚠️  configure-failure-domain.sh not found${NC}"
fi
echo

# 2. Deploy Descheduler
echo -e "${GREEN}🔄 Step 2: Deploy Pod Descheduler${NC}"
if [ -f "./cluster-management/descheduler.yaml" ]; then
    microk8s kubectl apply -f cluster-management/descheduler.yaml
    echo -e "${GREEN}✅ Descheduler deployed (runs every 10 minutes)${NC}"
else
    echo -e "${YELLOW}⚠️  descheduler.yaml not found${NC}"
fi
echo

# 3. Upgrade Helm deployment with Anti-Affinity
echo -e "${GREEN}🎯 Step 3: Update Deployment with Pod Anti-Affinity${NC}"
if [ -d "./helm-charts/nginx-website" ]; then
    microk8s helm3 upgrade nginx-website helm-charts/nginx-website/
    echo -e "${GREEN}✅ Nginx deployment updated with anti-affinity rules${NC}"
else
    echo -e "${YELLOW}⚠️  nginx-website chart not found${NC}"
fi
echo

# 4. Trigger initial rebalancing
echo -e "${GREEN}⚖️  Step 4: Trigger Initial Pod Rebalancing${NC}"
microk8s kubectl create job --from=cronjob/descheduler-cronjob -n kube-system descheduler-initial 2>/dev/null || echo "Descheduler job already exists or failed"
echo -e "${GREEN}✅ Initial pod rebalancing triggered${NC}"
echo

# 5. Show results
echo -e "${BLUE}📊 Current Pod Distribution:${NC}"
microk8s kubectl get pods -o wide -l "app.kubernetes.io/instance=nginx-website" | grep -v dev
echo

echo -e "${GREEN}🎉 HA Cluster Setup Complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "  • Run this script on all other nodes for failure domains"
echo -e "  • Check pod distribution: kubectl get pods -o wide"
echo -e "  • Monitor with: ./monitoring/cluster-overview.sh"
echo