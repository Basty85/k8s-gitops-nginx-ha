# Sebastian Meyer's Kubernetes Infrastructure

🚀 **High-Availability Kubernetes Cluster Infrastructure**

## Repository Structure

```
k8s-deployment/
├── .gitignore                # Git ignore patterns
├── README.md                 # This documentation
├── helm-charts/              # Helm Charts (Source of Truth)
│   └── nginx-website/        # Main application chart
├── environments/             # Environment-specific configurations  
│   └── production/           # Production values
├── legacy-manifests/         # Deprecated YAML files (reference only)
└── monitoring/               # Cluster monitoring tools
    └── cluster-overview.sh   # Cluster health check script
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
```

## GitOps Workflow

1. **Make changes** in `helm-charts/nginx-website/`
2. **Update environment values** in `environments/production/values.yaml`
3. **Test locally**: `microk8s helm3 template` or `microk8s helm3 --dry-run`
4. **Commit & Push** to trigger GitOps pipeline
5. **ArgoCD/Flux** automatically syncs changes

## Architecture

- **3-Node HA Cluster**: ubuntu-ha-cluster-1/2/3
- **Load Balancer**: MetalLB (192.168.1.70)
- **Ingress**: NGINX Ingress Controller
- **TLS**: Sectigo SSL Certificate
- **Monitoring**: Custom cluster-overview script

## Quick Start

```bash
# Clone repository
git clone <repo-url>
cd k8s-deployment

# Deploy application
microk8s helm3 upgrade --install nginx-website \
  helm-charts/nginx-website/ \
  -f environments/production/values.yaml

# Monitor cluster
./monitoring/cluster-overview.sh
```

## Links

- **Website**: https://sebastianmeyer.org
- **Load Balancer**: http://192.168.1.70
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