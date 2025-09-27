# Legacy Kubernetes Manifests

⚠️ **DEPRECATED - Use Helm Chart Instead**

These files are the original Kubernetes YAML manifests that have now been replaced by the Helm Chart.

## Status: Archived ✅

- **nginx-deployment.yaml** → Now: `helm-charts/nginx-website/templates/deployment.yaml`
- **nginx-service.yaml** → Now: `helm-charts/nginx-website/templates/service.yaml`  
- **website-configmap.yaml** → Now: `helm-charts/nginx-website/templates/configmap.yaml`
- **nginx-ingress-tls.yaml** → Now: `helm-charts/nginx-website/templates/ingress.yaml`

## Legacy Deployment Commands (Conventional YAML):

### Prerequisites:
```bash
# Ensure you have a valid TLS secret first:
microk8s kubectl create secret tls nginx-tls \
  --cert=path/to/certificate.crt \
  --key=path/to/private.key

# Check if secret exists:
microk8s kubectl get secret nginx-tls
```

### Deploy all legacy manifests:
```bash
# Deploy everything at once:
microk8s kubectl apply -f legacy-manifests/

# Or deploy individually in order:
microk8s kubectl apply -f legacy-manifests/website-configmap.yaml
microk8s kubectl apply -f legacy-manifests/nginx-deployment.yaml
microk8s kubectl apply -f legacy-manifests/nginx-service.yaml
microk8s kubectl apply -f legacy-manifests/nginx-ingress-tls.yaml
microk8s kubectl apply -f legacy-manifests/ingress-lb.yaml
```

### Check deployment status:
```bash
# Check all resources:
microk8s kubectl get all -l app=nginx

# Check pods:
microk8s kubectl get pods -l app=nginx -o wide

# Check service:
microk8s kubectl get svc nginx-lb

# Check ingress:
microk8s kubectl get ingress nginx-ingress-tls
```

### Update/Modify legacy deployment:
```bash
# Update specific manifest:
microk8s kubectl apply -f legacy-manifests/nginx-deployment.yaml

# Restart deployment:
microk8s kubectl rollout restart deployment nginx

# Check rollout status:
microk8s kubectl rollout status deployment nginx
```

### Remove legacy deployment:
```bash
# Remove all resources:
microk8s kubectl delete -f legacy-manifests/

# Or remove individually:
microk8s kubectl delete deployment nginx
microk8s kubectl delete service nginx-lb
microk8s kubectl delete ingress nginx-ingress-tls
microk8s kubectl delete configmap nginx-website
```

## Migration Path:

### From Legacy to Helm:
```bash
# 1. Remove old deployment:
microk8s kubectl delete -f legacy-manifests/

# 2. Deploy with Helm:
microk8s helm3 upgrade --install nginx-website \
  helm-charts/nginx-website/ \
  -f environments/production/values.yaml
```

## Why Helm is Better:

- ✅ **Templating**: Reusable configurations for multiple environments
- ✅ **Versioning**: Easy rollbacks and release management  
- ✅ **Values**: Environment-specific configurations
- ✅ **Lifecycle**: Install, upgrade, rollback operations
- ✅ **GitOps**: Better integration with CI/CD pipelines

## Current Usage:
```bash
# ❌ Old (don't use):
kubectl apply -f legacy-manifests/

# ✅ New (use this):
microk8s helm3 upgrade --install nginx-website \
  helm-charts/nginx-website/ \
  -f environments/production/values.yaml
```

These files are kept for reference only.