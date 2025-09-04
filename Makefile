.PHONY: help tf-init tf-fmt tf-validate tf-plan tf-apply ansible-lint k8s-validate clean

# Default environment
ENV ?= dev

# Colors for output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m # No Color

help: ## Show this help message
	@echo "Atlas Micro IaC - Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

tf-init: ## Initialize Terraform
	@echo "$(GREEN)Initializing Terraform...$(NC)"
	cd terraform && terraform init

tf-fmt: ## Format Terraform files
	@echo "$(GREEN)Formatting Terraform files...$(NC)"
	cd terraform && terraform fmt -recursive

tf-validate: ## Validate Terraform configuration
	@echo "$(GREEN)Validating Terraform configuration...$(NC)"
	cd terraform && terraform validate

tf-plan: ## Plan Terraform changes (ENV=dev|stage|prod)
	@echo "$(YELLOW)⚠️  WARNING: This is a demo project. No real AWS resources will be created.$(NC)"
	@echo "$(GREEN)Planning Terraform changes for $(ENV) environment...$(NC)"
	cd terraform && terraform plan -var-file=../envs/$(ENV).tfvars

tf-apply: ## Apply Terraform changes (DISABLED - Demo only)
	@echo "$(RED)❌ terraform apply is disabled in this demo project$(NC)"
	@echo "$(YELLOW)This command is provided for reference only.$(NC)"
	@echo "$(YELLOW)In a real environment, you would run:$(NC)"
	@echo "cd terraform && terraform apply -var-file=../envs/$(ENV).tfvars"

tf-destroy: ## Destroy Terraform resources (DISABLED - Demo only)
	@echo "$(RED)❌ terraform destroy is disabled in this demo project$(NC)"
	@echo "$(YELLOW)This command is provided for reference only.$(NC)"
	@echo "$(YELLOW)In a real environment, you would run:$(NC)"
	@echo "cd terraform && terraform destroy -var-file=../envs/$(ENV).tfvars"

ansible-lint: ## Run Ansible lint checks
	@echo "$(GREEN)Running Ansible lint...$(NC)"
	cd ansible && ansible-lint playbooks/ || true

ansible-check: ## Run Ansible playbooks in check mode
	@echo "$(YELLOW)⚠️  Running Ansible in check mode (no changes applied)$(NC)"
	cd ansible && ansible-playbook -i inventory/hosts.yml playbooks/site.yml --check || true

k8s-validate: ## Validate Kubernetes manifests
	@echo "$(GREEN)Validating Kubernetes manifests...$(NC)"
	# Note: Requires kubectl and cluster access
	# kubectl apply -f k8s/ --dry-run=client --validate=true
	@echo "$(YELLOW)k8s validation requires active cluster connection$(NC)"
	@echo "$(YELLOW)Run: kubectl apply -f k8s/ --dry-run=client --validate=true$(NC)"

helm-lint: ## Lint Helm charts
	@echo "$(GREEN)Linting Helm charts...$(NC)"
	helm lint helm/api-generic-chart/
	helm lint helm/monitoring/ || true

security-scan: ## Run security scans (placeholder)
	@echo "$(GREEN)Running security scans...$(NC)"
	@echo "$(YELLOW)Security scan commands (placeholder):$(NC)"
	@echo "  - tfsec terraform/"
	@echo "  - checkov -d terraform/"
	@echo "  - kube-score score k8s/**/*.yaml"

docs-serve: ## Serve documentation locally
	@echo "$(GREEN)Documentation is available in docs/ directory$(NC)"
	@echo "$(YELLOW)Consider using mkdocs or similar for documentation serving$(NC)"

clean: ## Clean temporary files
	@echo "$(GREEN)Cleaning temporary files...$(NC)"
	find . -name "*.tfstate*" -type f -delete || true
	find . -name ".terraform.lock.hcl" -type f -delete || true
	find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup completed$(NC)"

install-deps: ## Install required dependencies (placeholder)
	@echo "$(GREEN)Required dependencies:$(NC)"
	@echo "  - terraform >= 1.6"
	@echo "  - ansible >= 2.12"
	@echo "  - kubectl"
	@echo "  - helm >= 3.8"
	@echo "  - aws-cli"
	@echo ""
	@echo "$(YELLOW)Install commands vary by OS. See README.md for details.$(NC)"

pre-commit: tf-fmt tf-validate ansible-lint ## Run pre-commit checks
	@echo "$(GREEN)✓ All pre-commit checks completed$(NC)"

ci: pre-commit ## Run CI pipeline locally
	@echo "$(GREEN)Running CI pipeline locally...$(NC)"
	@echo "$(GREEN)✓ CI pipeline completed$(NC)"
