# GKE Cluster with Istio Gateway

This Terraform configuration deploys a production-ready Google Kubernetes Engine (GKE) cluster with Istio Gateway for service mesh and ingress management.

## 🏗️ Architecture

- **Modular Design**: Clean separation of concerns with reusable Terraform modules
- **Private VPC Network**: Custom VPC with private nodes and Cloud NAT
- **GKE Cluster**: Regional private cluster with high availability
- **CPU Node Pool**: For general workloads and applications
- **Istio Service Mesh**: Advanced traffic management and observability
- **Istio Gateway**: LoadBalancer for external traffic ingress
- **Auto-scaling**: Node pool autoscaling configured
- **Security**: Private nodes, Workload Identity, Shielded Nodes, and Network Policies enabled

## 📦 Project Structure

```
├── main.tf                 # Orchestrates all modules
├── provider.tf             # Provider configuration (Google, Kubernetes, Helm)
├── istio.tf               # Istio Gateway installation
├── variables.tf           # Variable definitions
├── terraform.tfvars       # Your configuration values
├── outputs.tf             # Output values
├── modules/
│   ├── network/           # VPC and subnet configuration
│   ├── gke-cluster/       # GKE cluster setup
│   └── node-pool/         # Node pool management
├── k8s/                   # Kubernetes manifests
│   ├── test-app-deployment.yaml
│   └── test-app-gateway.yaml
└── scripts/               # Automation scripts
    ├── setup.sh
    └── deploy.sh
```

## 📋 Prerequisites

1. **Google Cloud Platform Account**
   - Active GCP project with billing enabled
   
2. **Local Tools**
   ```bash
   # Install gcloud CLI
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   
   # Install Terraform
   brew install terraform  # macOS
   # or download from https://www.terraform.io/downloads
   
   # Install kubectl
   gcloud components install kubectl
   ```

3. **GCP Authentication**
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

4. **Enable Required APIs**
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable container.googleapis.com
   gcloud services enable servicenetworking.googleapis.com
   ```

## 🚀 Quick Start

### Step 1: Configure Variables

```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
vi terraform.tfvars
```

Update `terraform.tfvars` with your project details:
```hcl
project_id   = "your-gcp-project-id"
project_name = "your-project-name"
region       = "us-east4"  # or your preferred region
```

### Step 2: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

This will take 10-15 minutes to complete and will create:
- VPC Network with subnet
- GKE Cluster
- CPU Node Pool
- Istio Base components
- Istio Control Plane (Istiod)
- Istio Gateway with LoadBalancer

### Step 3: Connect to Cluster

```bash
# Get cluster credentials
gcloud container clusters get-credentials <cluster-name> \
  --region <region> \
  --project <project-id>

# Verify connection
kubectl get nodes
kubectl get pods -n istio-system
```

Or use the Makefile:
```bash
make connect
```

### Step 4: Deploy Test Application

```bash
# Deploy test application
kubectl apply -f k8s/test-app-deployment.yaml
kubectl apply -f k8s/test-app-gateway.yaml

# Check deployment
kubectl get pods -n test-app
kubectl get gateway,virtualservice -n test-app
```

Or use the Makefile:
```bash
make deploy-test
```

### Step 5: Test Istio Gateway

```bash
# Get Istio Gateway IP
kubectl get svc istio-gateway -n istio-system

# Test the gateway (replace with your Gateway IP)
curl http://<GATEWAY-IP>/html
curl http://<GATEWAY-IP>/headers
curl http://<GATEWAY-IP>/ip
```

Or use the Makefile:
```bash
make test-gateway
```

## 📊 Istio Gateway Features

- **Traffic Management**: Advanced routing, retries, timeouts, circuit breakers
- **Security**: mTLS, authentication, authorization policies
- **Observability**: Metrics, logs, distributed tracing
- **Load Balancing**: Multiple load balancing algorithms
- **Canary Deployments**: Traffic splitting for gradual rollouts
- **Rate Limiting**: Request rate control
- **Fault Injection**: Test application resilience

## 🔧 Configuration

### Change Region/Zone

Edit `terraform.tfvars`:
```hcl
region = "us-central1"
cpu_node_locations = ["us-central1-a"]
```

### Scale CPU Nodes

```bash
# Manual scaling via gcloud
gcloud container clusters resize <cluster-name> \
  --node-pool cpu-pool \
  --num-nodes 3 \
  --region <region>

# Or update terraform.tfvars and apply
cpu_node_count = 3
```

### Deploy Your Application

1. Create your deployment and service YAML files
2. Create a Gateway and VirtualService for routing
3. Apply the manifests:

```bash
kubectl apply -f your-app-deployment.yaml
kubectl apply -f your-app-gateway.yaml
```

Example Gateway configuration:
```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: my-gateway
  namespace: my-app
spec:
  selector:
    istio: gateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: my-app
  namespace: my-app
spec:
  hosts:
  - "*"
  gateways:
  - my-gateway
  http:
  - route:
    - destination:
        host: my-app-service
        port:
          number: 80
```

## 💰 Cost Optimization

1. **Use Spot/Preemptible Instances**
   - Set in `terraform.tfvars`:
   ```hcl
   cpu_enable_spot = true
   ```

2. **Right-size Node Pool**
   - Adjust machine type and node count based on workload
   - Use smaller machine types for development

3. **Enable Cluster Autoscaler**
   ```hcl
   cpu_min_nodes = 1
   cpu_max_nodes = 5
   ```

4. **Scale Down When Not in Use**
   ```bash
   gcloud container clusters resize <cluster-name> \
     --node-pool cpu-pool \
     --num-nodes 1 \
     --region <region>
   ```

5. **Delete Resources When Not Needed**
   ```bash
   terraform destroy
   ```

## 🐛 Troubleshooting

### Pods Stuck in Pending

```bash
kubectl describe pod -n <namespace> <pod-name>
```

Common issues:
- **Insufficient resources**: Scale up node pool
- **Image pull errors**: Check image name and registry access
- **Node selector mismatch**: Verify pod scheduling constraints

### Istio Gateway Not Working

```bash
# Check Gateway status
kubectl get svc -n istio-system
kubectl get pods -n istio-system
kubectl logs -n istio-system -l app=istio-gateway

# Check Gateway configuration
kubectl get gateway,virtualservice -A
kubectl describe gateway <gateway-name> -n <namespace>
```

### Cannot Access Cluster

```bash
# Refresh credentials
gcloud container clusters get-credentials <cluster-name> \
  --region <region> \
  --project <project-id>

# Check cluster status in GCP Console
# Verify master authorized networks allow your IP
```

### Permission Issues

If you need cluster-admin for Istio:
```bash
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=<your-email>
```

## 🔒 Security Features

### Enabled by Default

1. ✅ **Private Nodes** - Nodes don't have public IP addresses
2. ✅ **Cloud NAT** - Private nodes access internet securely
3. ✅ **Private Google Access** - Access Google services without public IPs
4. ✅ **Workload Identity** - Secure GCP service access
5. ✅ **Shielded Nodes** - Secure boot and integrity monitoring
6. ✅ **Network Policies** - Pod-level network isolation
7. ✅ **Master Authorized Networks** - Control who can access cluster

### Additional Security Options

To make the control plane fully private:
```hcl
# In terraform.tfvars
enable_private_endpoint = true
```

To restrict control plane access to specific IPs:
```hcl
# In terraform.tfvars
master_authorized_networks = [
  {
    cidr_block   = "YOUR_IP/32"
    display_name = "Your office"
  }
]
```

## 📝 Common Commands

```bash
# View cluster info
kubectl cluster-info

# Get Istio Gateway IP
kubectl get svc istio-gateway -n istio-system

# Check Istio pods
kubectl get pods -n istio-system

# View Gateway configuration
kubectl get gateway,virtualservice -A

# View test app
kubectl get all -n test-app

# Port forward to a service
kubectl port-forward svc/<service-name> 8080:80 -n <namespace>

# View logs
kubectl logs -f -n <namespace> <pod-name>

# Execute command in pod
kubectl exec -it -n <namespace> <pod-name> -- /bin/sh
```

## 🧹 Cleanup

```bash
# Delete test application
kubectl delete namespace test-app

# Destroy Terraform infrastructure
terraform destroy

# Verify all resources are deleted
gcloud compute instances list
gcloud container clusters list
```

Or use the Makefile:
```bash
make clean    # Delete test app
make destroy  # Destroy infrastructure
```

## 📚 Additional Resources

- [Istio Documentation](https://istio.io/latest/docs/)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Istio Traffic Management](https://istio.io/latest/docs/tasks/traffic-management/)
- [Istio Security](https://istio.io/latest/docs/tasks/security/)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is licensed under the MIT License.
