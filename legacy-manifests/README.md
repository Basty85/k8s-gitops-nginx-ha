# Legacy Kubernetes Manifests

⚠️ **DEPRECATED - Use Helm Chart Instead**

Diese Dateien sind die ursprünglichen Kubernetes YAML-Manifeste, die jetzt durch das Helm Chart ersetzt wurden.

## Status: Archiviert ✅

- **nginx-deployment.yaml** → Jetzt: `helm-charts/nginx-website/templates/deployment.yaml`
- **nginx-service.yaml** → Jetzt: `helm-charts/nginx-website/templates/service.yaml`  
- **website-configmap.yaml** → Jetzt: `helm-charts/nginx-website/templates/configmap.yaml`
- **nginx-ingress-tls.yaml** → Jetzt: `helm-charts/nginx-website/templates/ingress.yaml`

## Verwendung:
```bash
# Alt (nicht mehr verwenden):
kubectl apply -f legacy-manifests/

# Neu (verwenden):
helm upgrade nginx-website helm-charts/nginx-website/
```

Diese Dateien werden nur noch als Referenz aufbewahrt.