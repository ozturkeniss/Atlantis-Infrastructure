#!/bin/bash
# Bastion Host Bootstrap Script
# This script configures the bastion host with necessary tools for EKS management

set -e

# Variables from Terraform
CLUSTER_NAME="${cluster_name}"
REGION="${region}"

# Update system
yum update -y

# Install basic tools
yum install -y \
    curl \
    wget \
    unzip \
    git \
    jq \
    vim \
    htop \
    tree

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Configure kubectl for EKS cluster
mkdir -p /home/ec2-user/.kube
chown ec2-user:ec2-user /home/ec2-user/.kube

# Create a script to configure kubectl (to be run by ec2-user)
cat > /home/ec2-user/configure-kubectl.sh << 'EOF'
#!/bin/bash
aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER_NAME}
kubectl get nodes
EOF

chmod +x /home/ec2-user/configure-kubectl.sh
chown ec2-user:ec2-user /home/ec2-user/configure-kubectl.sh

# Add useful aliases to bashrc
cat >> /home/ec2-user/.bashrc << 'EOF'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kds='kubectl describe svc'

# Helm aliases
alias h='helm'
alias hls='helm list'
alias hla='helm list --all-namespaces'

# ArgoCD aliases
alias argocd='argocd'

# AWS aliases
alias awsp='aws sts get-caller-identity'

# Useful functions
function kexec() {
    kubectl exec -it $1 -- /bin/bash
}

function klogs() {
    kubectl logs -f $1
}

EOF

# Create welcome message
cat > /etc/motd << 'EOF'
===============================================
   Atlas Micro Platform - Bastion Host
===============================================

Welcome to the Atlas Micro platform bastion host!

Available tools:
- kubectl (Kubernetes CLI)
- helm (Helm package manager)
- argocd (ArgoCD CLI)
- aws (AWS CLI v2)
- eksctl (EKS CLI)

Getting started:
1. Configure kubectl: ./configure-kubectl.sh
2. View cluster nodes: kubectl get nodes
3. List helm releases: helm list --all-namespaces

Useful aliases are configured in your .bashrc
Type 'alias' to see available shortcuts.

Cluster: ${CLUSTER_NAME}
Region: ${REGION}
===============================================
EOF

# Set up log rotation for user commands
cat > /etc/logrotate.d/user-commands << 'EOF'
/var/log/user-commands.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
EOF

# Create a simple monitoring script
cat > /home/ec2-user/cluster-status.sh << 'EOF'
#!/bin/bash
echo "=== Cluster Status ==="
echo "Nodes:"
kubectl get nodes --no-headers | wc -l
echo ""
echo "Pods by namespace:"
kubectl get pods --all-namespaces --no-headers | awk '{print $1}' | sort | uniq -c
echo ""
echo "Services:"
kubectl get svc --all-namespaces --no-headers | wc -l
EOF

chmod +x /home/ec2-user/cluster-status.sh
chown ec2-user:ec2-user /home/ec2-user/cluster-status.sh

# Enable and start SSM agent (for Session Manager access)
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo "Bastion host configuration completed successfully!"
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
