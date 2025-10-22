# LLM Deployment on GKE with GPU

This Terraform configuration deploys a production-ready Google Kubernetes Engine (GKE) cluster with GPU nodes for running Large Language Models (LLMs).

## 🏗️ Architecture

- **Modular Design**: Clean separation of concerns with reusable Terraform modules
- **VPC Network**: Custom VPC with separate IP ranges for nodes, pods, and services
- **GKE Cluster**: Regional cluster with high availability
- **Node Pools**:
  - **CPU Pool**: For general workloads and system components
  - **GPU Pool**: For LLM inference with NVIDIA GPUs
- **Auto-scaling**: Both node pools and pod autoscaling configured
- **Security**: Workload Identity, Shielded Nodes, and Network Policies enabled

## 📦 Modular Structure

This project uses a modular Terraform architecture for better maintainability and reusability:

```
├── main.tf              # Orchestrates all modules
├── modules/
│   ├── network/        # VPC and subnet configuration
│   ├── gke-cluster/    # GKE cluster setup
│   └── node-pool/      # Node pool management (CPU/GPU)
├── k8s/                # Kubernetes manifests
└── scripts/            # Automation scripts
```

📖 **Documentation:**
- **[MODULES.md](MODULES.md)** - Detailed module documentation
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and design
- **[COSTS.md](COSTS.md)** - Cost estimation and optimization
- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 20 minutes

## 📋 Prerequisites

1. **Google Cloud Platform Account**
   - Active GCP project with billing enabled
   - Sufficient GPU quota for your region

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
project_name = "llm-deployment"
region       = "us-central1"
```

### Step 2: Check GPU Quota

```bash
# Check your GPU quota
gcloud compute project-info describe --project=YOUR_PROJECT_ID

# Request quota increase if needed
# Go to: https://console.cloud.google.com/iam-admin/quotas
# Filter by: "GPUs (all regions)" or specific GPU type
```

### Step 3: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

This will take 10-15 minutes to complete.

### Step 4: Connect to Cluster

```bash
# Get cluster credentials
gcloud container clusters get-credentials llm-deployment-gke-cluster \
  --region us-central1 \
  --project YOUR_PROJECT_ID

# Verify connection
kubectl get nodes
kubectl get pods --all-namespaces
```

### Step 5: Deploy LLM

Choose your inference framework:

#### Option A: vLLM (Recommended for performance)

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy vLLM
kubectl apply -f k8s/llm-deployment.yaml
kubectl apply -f k8s/llm-service.yaml
kubectl apply -f k8s/llm-hpa.yaml

# Check deployment
kubectl get pods -n llm-inference -w
```

#### Option B: Text Generation Inference (TGI)

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# If using gated models, create secret
kubectl create secret generic huggingface-token \
  --from-literal=token=YOUR_HF_TOKEN \
  -n llm-inference

# Deploy TGI
kubectl apply -f k8s/text-generation-inference.yaml

# Check deployment
kubectl get pods -n llm-inference -w
```

### Step 6: Test the Deployment

```bash
# Get the external IP
kubectl get service llm-inference -n llm-inference

# Wait for EXTERNAL-IP to be assigned (may take a few minutes)
export LLM_ENDPOINT=$(kubectl get service llm-inference -n llm-inference -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test with curl (vLLM OpenAI-compatible API)
curl http://$LLM_ENDPOINT/v1/models

# Generate text
curl http://$LLM_ENDPOINT/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistralai/Mistral-7B-Instruct-v0.2",
    "prompt": "Write a haiku about Kubernetes:",
    "max_tokens": 100,
    "temperature": 0.7
  }'
```

## 🎯 GPU Types and Availability

| GPU Type | Memory | Use Case | Availability |
|----------|--------|----------|-------------|
| `nvidia-tesla-t4` | 16GB | Cost-effective inference | Most regions |
| `nvidia-tesla-v100` | 16GB | High performance | Limited regions |
| `nvidia-tesla-a100` | 40GB | Large models | Very limited |
| `nvidia-l4` | 24GB | Latest generation | Select regions |

Check availability:
```bash
gcloud compute accelerator-types list --filter="zone:us-central1"
```

## 📊 Monitoring

### View Pod Logs
```bash
kubectl logs -f -n llm-inference -l app=llm-inference
```

### Check GPU Usage
```bash
# Install nvidia-smi on GPU pod
kubectl exec -it -n llm-inference $(kubectl get pod -n llm-inference -l app=llm-inference -o jsonpath='{.items[0].metadata.name}') -- nvidia-smi

# Watch GPU usage
kubectl exec -it -n llm-inference $(kubectl get pod -n llm-inference -l app=llm-inference -o jsonpath='{.items[0].metadata.name}') -- watch -n 1 nvidia-smi
```

### Check Node Status
```bash
kubectl describe nodes -l workload=gpu-llm
```

### View Metrics in GCP Console
- Navigate to: GKE → Clusters → llm-deployment-gke-cluster → Observability

## 🔧 Configuration

### Change Model

Edit `k8s/llm-deployment.yaml`:
```yaml
env:
- name: MODEL_NAME
  value: "mistralai/Mistral-7B-Instruct-v0.2"  # Change this
```

Popular models:
- `mistralai/Mistral-7B-Instruct-v0.2` (7B parameters, 16GB VRAM)
- `meta-llama/Llama-2-7b-chat-hf` (7B parameters, 16GB VRAM)
- `meta-llama/Llama-2-13b-chat-hf` (13B parameters, 32GB VRAM)
- `microsoft/phi-2` (2.7B parameters, 6GB VRAM)

### Scale GPU Nodes

```bash
# Manual scaling
gcloud container clusters resize llm-deployment-gke-cluster \
  --node-pool gpu-pool \
  --num-nodes 2 \
  --region us-central1

# Or update terraform.tfvars and apply
```

### Enable Ingress with Domain

1. Update `k8s/ingress.yaml` with your domain
2. Apply:
```bash
kubectl apply -f k8s/ingress.yaml
```

## 💰 Cost Optimization

1. **Use Spot/Preemptible Instances**
   - Add to GPU node pool in `main.tf`:
   ```hcl
   spot = true
   ```

2. **Scale Down During Off-Hours**
   ```bash
   # Scale to 0 nodes
   gcloud container clusters resize llm-deployment-gke-cluster \
     --node-pool gpu-pool \
     --num-nodes 0 \
     --region us-central1
   ```

3. **Use Cheaper GPU Types**
   - T4 is most cost-effective for inference
   - L4 offers better performance per dollar

4. **Enable Cluster Autoscaler**
   - Already configured in Terraform
   - Set `gpu_min_nodes = 0` to scale to zero

## 🐛 Troubleshooting

### Pods Stuck in Pending

```bash
kubectl describe pod -n llm-inference <pod-name>
```

Common issues:
- **Insufficient GPU quota**: Request increase in GCP Console
- **No GPU nodes available**: Check node pool status
- **Image pull errors**: Verify image name and network connectivity

### GPU Not Detected

```bash
# Check NVIDIA driver installation
kubectl get daemonset -n kube-system | grep nvidia

# Reinstall if needed
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded-latest.yaml
```

### Out of Memory

- Reduce `GPU_MEMORY_UTILIZATION` in deployment
- Use a smaller model
- Add more GPUs per node
- Use quantized models (4-bit, 8-bit)

## 🔒 Security Best Practices

1. **Use Private Cluster** (Production)
   - Add to `main.tf`:
   ```hcl
   private_cluster_config {
     enable_private_nodes    = true
     enable_private_endpoint = false
   }
   ```

2. **Enable Binary Authorization**
3. **Use Workload Identity** (already enabled)
4. **Implement Network Policies**
5. **Rotate Credentials Regularly**

## 🧹 Cleanup

```bash
# Delete Kubernetes resources
kubectl delete namespace llm-inference

# Destroy Terraform infrastructure
terraform destroy

# Verify all resources are deleted
gcloud compute instances list
gcloud container clusters list
```

## 📚 Additional Resources

- [GKE GPU Documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/gpus)
- [vLLM Documentation](https://docs.vllm.ai/)
- [Text Generation Inference](https://github.com/huggingface/text-generation-inference)
- [GPU Quotas](https://cloud.google.com/compute/quotas)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is licensed under the MIT License.

