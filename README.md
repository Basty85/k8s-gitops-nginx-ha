# Learning Project Kubernetes HA Infrastructure

🚀 **High-Availability Kubernetes Cluster Infrastructure**

## Repository Structure

```
k8s-deployment/
├── .gitignore                        # Git ignore patterns
├── README.md                         # This documentation
├── helm-charts/                      # Helm Charts (Source of Truth)
│   └── nginx-website/                # Main application chart
├── environments/                     # Environment-specific configurations  
│   └── production/                   # Production values
├── argocd/                           # GitOps configurations
│   ├── applications.yaml             # ArgoCD Applications
│   └── project.yaml                  # ArgoCD Project
├── automation/                       # Automation scripts
│   ├── setup-ha-cluster.sh           # Complete HA setup
│   └── configure-failure-domain.sh   # HA failure domain setup
├── cluster-management/               # Cluster optimization tools
│   ├── descheduler.yaml              # Pod rebalancing configuration
│   └── argocd-ingress.yaml           # ArgoCD external access
├── legacy-manifests/                 # Deprecated YAML files (reference only)
└── monitoring/                       # Cluster monitoring tools
    └── cluster-overview.sh           # Cluster health check script
```

## Deployment Commands

### Production Deployment (Recommended):
```bash
# Deploy with production values
microk8s helm3 upgrade --install nginx-website \
  helm-charts/nginx-website/ \
  -f environments/production/values.yaml

# Check status
./monitoring/cluster-overview.sh
```

### Development/Testing:
```bash
# Deploy with default values
microk8s helm3 upgrade --install nginx-website-dev \
  helm-charts/nginx-website/

# Upgrade existing deployment after changes
microk8s helm3 upgrade nginx-website-dev \
  helm-charts/nginx-website/
```

## GitOps Workflow

**🔄 ArgoCD automatically manages deployments from this Git repository**

### ArgoCD Access:
- **UI**: http://192.168.1.72 or https://argocd.sebastianmeyer.org
- **Username**: `admin`
- **Password**: Retrieved with: `microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

### GitOps Process:
1. **Make changes** in `helm-charts/nginx-website/`
2. **Update environment values** in `environments/production/values.yaml`
3. **Test locally**: `microk8s helm3 template nginx-website helm-charts/nginx-website/ -f environments/production/values.yaml`
4. **Commit & Push** to trigger GitOps pipeline
5. **ArgoCD automatically syncs** changes within 3 minutes

### Manual Sync (if needed):
```bash
# Trigger immediate sync
microk8s kubectl patch application nginx-website-production -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"now"}}}'
```

## Architecture

- **3-Node HA Cluster**: ubuntu-ha-cluster-1/2/3
- **GitOps**: ArgoCD (192.168.1.72)
- **Load Balancer**: MetalLB (192.168.1.70)
- **Ingress**: NGINX Ingress Controller
- **TLS**: Sectigo SSL Certificate
- **Monitoring**: Custom cluster-overview script

## Quick Start

```bash
# Clone repository
git clone https://github.com/Basty85/k8s-gitops-nginx-ha.git
cd k8s-gitops-nginx-ha

# Deploy application
microk8s helm3 upgrade --install nginx-website \
  helm-charts/nginx-website/ \
  -f environments/production/values.yaml

# Monitor cluster
./monitoring/cluster-overview.sh
```

## Links

- **Website**: https://sebastianmeyer.org
- **Load Balancer**: http://192.168.1.70 (local only)
- **Monitoring**: ./monitoring/cluster-overview.sh

## Prerequisites

- MicroK8s v1.32+ with enabled addons:
  - `microk8s enable dns ingress metallb cert-manager helm3`
- Valid SSL certificate configured as Kubernetes secret:
  ```bash
  kubectl create secret tls nginx-tls \
    --cert=path/to/certificate.crt \
    --key=path/to/private.key
  ```
- LoadBalancer IP range configured in MetalLB

## High Availability & Pod Scheduling

### Failure Domains Configuration
Configure failure domains for optimal HA resilience:

```bash
# Run on each VM to set individual failure domains
./automation/configure-failure-domain.sh
```

This automatically detects the node and sets appropriate failure domains:
- VM1 (192.168.1.54): failure-domain=1
- VM2 (192.168.1.55): failure-domain=2  
- VM3 (192.168.1.56): failure-domain=3

### Pod Rebalancing & Anti-Affinity

The deployment includes **Pod Anti-Affinity** rules to distribute pods evenly across nodes.

Deploy the **Descheduler** for automatic pod rebalancing:
```bash
# Deploy descheduler (runs every 10 minutes)
microk8s kubectl apply -f cluster-management/descheduler.yaml

# Manual rebalancing trigger
microk8s kubectl create job --from=cronjob/descheduler-cronjob -n kube-system descheduler-now
```

**Benefits:**
- ✅ **Even Distribution**: Pods spread across all available nodes
- ✅ **Auto-Recovery**: When nodes return, pods rebalance automatically  
- ✅ **Fault Tolerance**: No single node has all replicas

### Pod Distribution Check
```bash
# Check current pod distribution
microk8s kubectl get pods -o wide -l "app.kubernetes.io/instance=nginx-website"

# Expected result: ~2 pods per node in 3-node cluster
```

## Troubleshooting

### Common Issues:
```bash
# Check Helm releases
microk8s helm3 list

# Validate chart before deployment
microk8s helm3 lint helm-charts/nginx-website/

# Debug template rendering
microk8s helm3 template nginx-website helm-charts/nginx-website/ -f environments/production/values.yaml

# Check cluster health
./monitoring/cluster-overview.sh
```

### Rollback if needed:
```bash
microk8s helm3 history nginx-website
microk8s helm3 rollback nginx-website 1
```