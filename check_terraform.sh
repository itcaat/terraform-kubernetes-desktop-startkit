#!/bin/bash

echo "🔍 Checking Terraform structure and Kubernetes cluster..."

# 1. Check if Terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "❌ Terraform is not installed. Please install it and try again."
    exit 1
fi
echo "✅ Terraform is installed: $(terraform version | head -n 1)"

# 2. Check if kubectl is installed
if ! command -v kubectl &> /dev/null
then
    echo "❌ Kubectl is not installed. Please install it and try again."
    exit 1
fi

# 3. Check the current Kubernetes context
CURRENT_CONTEXT=$(kubectl config current-context)
if [ -z "$CURRENT_CONTEXT" ]; then
    echo "❌ No active Kubernetes context! Check your kubeconfig settings."
    exit 1
fi
echo "✅ Current Kubernetes context: $CURRENT_CONTEXT"

# 4. Verify if the Kubernetes cluster is accessible
if ! kubectl get nodes &> /dev/null; then
    echo "❌ Cannot connect to the Kubernetes cluster! Make sure it is running."
    exit 1
fi
echo "✅ Kubernetes cluster is accessible!"

# 5. Check if essential Terraform files exist
TF_FILES=("providers.tf" "versions.tf")
for file in "${TF_FILES[@]}"
do
    if [ ! -f "$file" ]; then
        echo "❌ Missing Terraform file: $file"
        exit 1
    fi
done
echo "✅ Required Terraform files found!"

# 6. Check if the modules folder exists
if [ ! -d "modules" ]; then
    echo "❌ The 'modules' folder is missing! Check your project structure."
    exit 1
fi
echo "✅ Modules folder is present."

# 7. Verify Terraform modules are initialized
terraform init -backend=false &> /dev/null
if [ $? -ne 0 ]; then
    echo "❌ Terraform modules are not initialized! Run 'terraform init'."
    exit 1
fi
echo "✅ Terraform modules are initialized."

# 8. Check if Terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo "⚠️  terraform.tfstate file is missing. The infrastructure might not be deployed."
else
    echo "✅ Terraform state file found."
fi

# 9. Check if Terraform state contains resources
TF_STATE=$(terraform state list 2>/dev/null)
if [ -z "$TF_STATE" ]; then
    echo "⚠️  Terraform state is empty. The infrastructure might not be deployed."
else
    echo "✅ Terraform state contains resources:"
    echo "$TF_STATE"
fi

# 10. Check if Kubernetes has deployed resources
K8S_RESOURCES=$(kubectl get all -A --no-headers 2>/dev/null | wc -l)
if [ "$K8S_RESOURCES" -eq 0 ]; then
    echo "⚠️  No resources found in Kubernetes."
else
    echo "✅ Kubernetes contains $K8S_RESOURCES resources."
fi

echo "🎉 Check complete!"
exit 0
