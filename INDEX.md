# Project Index - LLM on GKE

Quick reference guide for navigating the project.

## 🎯 Start Here

| If you want to... | Read this... |
|-------------------|--------------|
| **Get started quickly** | [QUICKSTART.md](QUICKSTART.md) |
| **Understand the project** | [README.md](README.md) |
| **See architecture** | [ARCHITECTURE.md](ARCHITECTURE.md) |
| **Optimize costs** | [COSTS.md](COSTS.md) |
| **Contribute** | [CONTRIBUTING.md](CONTRIBUTING.md) |

## 📁 File Structure

```
GCP/ai-lab/
│
├── 📖 Documentation (Start Here!)
│   ├── INDEX.md              ← You are here
│   ├── README.md             ← Main documentation
│   ├── QUICKSTART.md         ← 20-minute quick start
│   ├── ARCHITECTURE.md       ← Architecture details
│   ├── COSTS.md              ← Cost optimization
│   └── CONTRIBUTING.md       ← How to contribute
│
├── 🏗️ Infrastructure Code
│   ├── main.tf              ← Root orchestration
│   ├── variables.tf         ← Input variables
│   ├── outputs.tf           ← Output values
│   ├── provider.tf          ← Provider config
│   └── terraform.tfvars.example
│
├── 📦 Terraform Modules
│   ├── modules/network/     ← VPC & subnet
│   ├── modules/gke-cluster/ ← GKE cluster
│   └── modules/node-pool/   ← Node pools
│
├── ☸️ Kubernetes
│   └── k8s/                 ← K8s manifests
│       ├── namespace.yaml
│       ├── llm-deployment.yaml
│       ├── llm-service.yaml
│       ├── llm-hpa.yaml
│       └── ...
│
├── 🤖 Automation
│   └── scripts/
│       ├── setup.sh         ← Initial setup
│       ├── deploy.sh        ← Full deployment
│       └── test-llm.sh      ← Testing
│
└── 🛠️ Tools
    ├── Makefile             ← Common commands
    └── .gitignore           ← Git ignore rules
```

## 🚀 Quick Commands

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make init` | Initialize Terraform |
| `make plan` | Preview changes |
| `make apply` | Deploy infrastructure |
| `make connect` | Connect kubectl |
| `make deploy-llm` | Deploy LLM |
| `make status` | Check status |
| `make logs` | View logs |
| `make test-llm` | Test LLM endpoint |
| `terraform destroy` | Delete everything |

## 📚 Documentation Deep Dive

### For First-Time Users
1. Read [QUICKSTART.md](QUICKSTART.md)
2. Run `./scripts/setup.sh`
3. Run `./scripts/deploy.sh`
4. Read [README.md](README.md) for details

### For Architects
1. Read [ARCHITECTURE.md](ARCHITECTURE.md)
2. Review module structure in `modules/` directory
3. Check [COSTS.md](COSTS.md) for cost planning

### For Contributors
1. Read [CONTRIBUTING.md](CONTRIBUTING.md)
2. Review module structure
3. Follow coding standards

## 🎯 Common Workflows

### Development Workflow
```bash
1. make init       # Initialize
2. make plan       # Preview
3. make apply      # Deploy
4. make connect    # Connect
5. make deploy-llm # Deploy LLM
```

### Testing Workflow
```bash
1. make status     # Check status
2. make logs       # View logs
3. make test-llm   # Test endpoint
4. make gpu-check  # Check GPUs
```

### Cleanup Workflow
```bash
1. kubectl delete namespace llm-inference
2. terraform destroy
```

## 📊 Module Reference

| Module | Purpose | Resources |
|--------|---------|-----------|
| **network** | Networking | VPC, Subnet |
| **gke-cluster** | Cluster | GKE Cluster |
| **node-pool** | Nodes | CPU Pool, GPU Pool |

## 🔗 Quick Links

### Internal
- [Root main.tf](main.tf)
- [Variables](variables.tf)
- [Outputs](outputs.tf)
- [Modules](modules/)
- [K8s Manifests](k8s/)
- [Scripts](scripts/)

### External
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [vLLM Documentation](https://docs.vllm.ai/)
- [Hugging Face TGI](https://github.com/huggingface/text-generation-inference)

## 📈 Project Stats

- **Total Files**: 33
- **Terraform Modules**: 3
- **K8s Manifests**: 9
- **Documentation Pages**: 5
- **Automation Scripts**: 3

## 💡 Tips

- 💰 Enable `gpu_enable_spot = true` for 60-70% cost savings
- 🔄 Set `gpu_min_nodes = 0` to scale to zero when idle
- 📊 Check `make status` regularly
- 🧪 Run `make test-llm` to verify deployment
- 📖 Read module READMEs for customization options

## 🆘 Need Help?

1. Check [README.md](README.md) troubleshooting section
2. Review [ARCHITECTURE.md](ARCHITECTURE.md) for design questions
3. Check module READMEs in `modules/` directory for module details
4. See [COSTS.md](COSTS.md) for cost optimization

## 📞 Support

- Issues: GitHub Issues
- Questions: GitHub Discussions
- Docs: This repository

---

**Happy Deploying! 🚀**

