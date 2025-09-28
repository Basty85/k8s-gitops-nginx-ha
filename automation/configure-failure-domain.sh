#!/bin/bash
# Configure failure domain for MicroK8s HA cluster

# Detect current node IP
CURRENT_IP=$(hostname -I | awk '{print $1}')

case $CURRENT_IP in
    "192.168.1.54")
        DOMAIN=1
        NODE="VM1"
        ;;
    "192.168.1.55")
        DOMAIN=2
        NODE="VM2"
        ;;
    "192.168.1.56")
        DOMAIN=3
        NODE="VM3"
        ;;
    *)
        echo "Unknown IP: $CURRENT_IP"
        exit 1
        ;;
esac

echo "Configuring failure domain $DOMAIN for $NODE ($CURRENT_IP)"

# Set failure domain
echo "failure-domain=$DOMAIN" | sudo tee /var/snap/microk8s/current/args/ha-conf

# Restart MicroK8s
echo "Restarting MicroK8s..."
sudo microk8s stop
sudo microk8s start

echo "✅ Failure domain $DOMAIN configured for $NODE"
echo "Verify with: microk8s status"