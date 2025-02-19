# 🚀 Terraform Kubernetes Infrastructure

## 📂 Project Structure
This Terraform project is designed to deploy and manage a Kubernetes cluster with essential services such as MetalLB, Cert-Manager, Ingress-Nginx, and Grafana. The structure follows best practices for modularity and maintainability.

### **Main Files**
- `main.tf` - Defines the core Terraform modules and their dependencies.
- `versions.tf` - Specifies required Terraform and provider versions.
- `providers.tf` - Configures Kubernetes, Helm, and Kubectl providers.
- `variables.tf` - Defines global variables used across modules.

### **Modules**
Each service is managed as a separate module for better reusability and organization.

#### **📁 modules/metallb**
- Deploys **MetalLB** via Helm.
- Configures **IP address pools** dynamically using `kubectl_manifest`.

#### **📁 modules/cert-manager**
- Installs **Cert-Manager** using Helm.
- Creates a **ClusterIssuer** and a self-signed CA certificate.

#### **📁 modules/ingress-nginx**
- Deploys **Ingress-Nginx** as a controller for managing ingress traffic.

#### **📁 modules/grafana**
- Deploys **Grafana** using Kubernetes manifests.
- Configures an **Ingress resource** with TLS issued by Cert-Manager.

## 🛠️ Setup and Deployment
1. **Initialize Terraform:**
   ```sh
   terraform init
   ```

2. **Plan the deployment:**
   ```sh
   terraform plan
   ```

3. **Apply the changes:**
   ```sh
   terraform apply -auto-approve
   ```

4. **Verify resources in Kubernetes:**
   ```sh
   kubectl get pods -A
   kubectl get svc -A
   kubectl get ingress -A
   ```

## 🔧 Configuration
### **Customizing Variables**
You can override default variables by creating a `terraform.tfvars` file or passing them via CLI:
```hcl
kube_config_path = "~/.kube/config"
kube_context = "docker-desktop"
metallb_ip_range = ["127.0.0.1-127.0.0.1", "192.168.1.100-192.168.1.200"]
grafana_namespace = "monitoring"
```

### **Destroying the Infrastructure**
To remove all deployed resources:
```sh
terraform destroy -auto-approve
```

## 📌 Key Features
✅ Modular architecture with separate Terraform modules.  
✅ Uses Helm for package management.  
✅ Configures self-signed certificates with Cert-Manager.  
✅ Supports MetalLB for LoadBalancer services in local Kubernetes environments.  
✅ Ingress-Nginx handles application routing.  
✅ Secure and automated TLS handling via ClusterIssuer.  

---
📢 **Contributions & Issues**
If you encounter any issues or have suggestions for improvements, feel free to contribute or raise an issue! 🚀

