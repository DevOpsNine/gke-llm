# Quick Start Guide

Get your LLM up and running on GKE in under 20 minutes!

## ⚡ Fast Track Deployment

### Prerequisites (5 minutes)
```bash
# 1. Install tools (if not already installed)
# macOS:
brew install --cask google-cloud-sdk
brew install terraform kubectl

# 2. Authenticate
gcloud auth login
gcloud auth application-default login

# 3. Set your project
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID
```

### Deploy (15 minutes)
```bash
# 1. Configure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars - set your project_id

# 2. Run automated deployment
./scripts/setup.sh
./scripts/deploy.sh

# Done! ✓
```

## 🎯 Minimal Configuration

Edit `terraform.tfvars` with just these required values:
```hcl
project_id = "your-gcp-project-id"
```

Everything else uses sensible defaults!

## 🧪 Test Your Deployment

```bash
# Wait 5-10 minutes for model to load, then:
./scripts/test-llm.sh
```

## 📝 Manual Steps (if you prefer)

```bash
# 1. Initialize
terraform init

# 2. Deploy infrastructure
terraform apply -auto-approve

# 3. Connect to cluster
gcloud container clusters get-credentials llm-deployment-gke-cluster \
  --region us-central1 --project $PROJECT_ID

# 4. Deploy LLM
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/llm-deployment.yaml
kubectl apply -f k8s/llm-service.yaml

# 5. Get service IP
kubectl get svc -n llm-inference -w
```

## 🔍 Troubleshooting

### Issue: "Insufficient GPU quota"
```bash
# Check quota
gcloud compute project-info describe --project=$PROJECT_ID

# Request increase:
# Go to: https://console.cloud.google.com/iam-admin/quotas
# Search: "GPUs (all regions)"
# Request: Increase to at least 1
```

### Issue: "Pods stuck in Pending"
```bash
kubectl describe pod -n llm-inference

# Usually means:
# - GPUs not available → Check quota
# - Nodes not ready → Wait a few minutes
```

### Issue: "Service has no external IP"
```bash
# Wait a few minutes, then check again
kubectl get svc -n llm-inference -w

# Force check
kubectl describe svc llm-inference -n llm-inference
```

## 💡 Quick Commands

```bash
# Check status
make status

# View logs
make logs

# Scale GPU nodes
make scale-gpu NODES=2

# Destroy everything
terraform destroy -auto-approve
```

## 🎨 Customize Your Model

Edit `k8s/llm-deployment.yaml`:
```yaml
env:
- name: MODEL_NAME
  value: "mistralai/Mistral-7B-Instruct-v0.2"  # Change this!
```

Popular choices:
- `microsoft/phi-2` (2.7B - fastest)
- `mistralai/Mistral-7B-Instruct-v0.2` (7B - balanced)
- `meta-llama/Llama-2-7b-chat-hf` (7B - most capable)

Then redeploy:
```bash
kubectl delete deployment llm-inference -n llm-inference
kubectl apply -f k8s/llm-deployment.yaml
```

## 📞 Need Help?

- Check [README.md](README.md) for detailed instructions
- See [COSTS.md](COSTS.md) for cost optimization
- Run `make help` for available commands

## 🧹 Cleanup

```bash
# Remove Kubernetes resources
kubectl delete namespace llm-inference

# Destroy infrastructure
terraform destroy

# Estimated time: 5 minutes
```

---

**Next Steps:**
- Read the full [README.md](README.md)
- Optimize costs with [COSTS.md](COSTS.md)
- Try different models and configurations!

