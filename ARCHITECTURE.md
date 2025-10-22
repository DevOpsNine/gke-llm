# Architecture Documentation

This document provides a detailed overview of the infrastructure architecture for deploying LLMs on GKE with GPU nodes.

## 🏗️ Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         GCP Project                              │
│                                                                   │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                    VPC Network                          │    │
│  │  (10.0.0.0/24 + secondary ranges)                      │    │
│  │                                                          │    │
│  │  ┌────────────────────────────────────────────────┐    │    │
│  │  │         Regional Subnet (us-central1)          │    │    │
│  │  │                                                 │    │    │
│  │  │  ┌──────────────────────────────────────┐     │    │    │
│  │  │  │   GKE Cluster (llm-deployment)       │     │    │    │
│  │  │  │                                       │     │    │    │
│  │  │  │  ┌─────────────────────────────┐    │     │    │    │
│  │  │  │  │   CPU Node Pool             │    │     │    │    │
│  │  │  │  │   - n1-standard-4           │    │     │    │    │
│  │  │  │  │   - Min: 1, Max: 5 nodes    │    │     │    │    │
│  │  │  │  │   - Auto-scaling: ✓         │    │     │    │    │
│  │  │  │  │   - Labels: workload=general│    │     │    │    │
│  │  │  │  └─────────────────────────────┘    │     │    │    │
│  │  │  │                                       │     │    │    │
│  │  │  │  ┌─────────────────────────────┐    │     │    │    │
│  │  │  │  │   GPU Node Pool             │    │     │    │    │
│  │  │  │  │   - n1-standard-8 + T4      │    │     │    │    │
│  │  │  │  │   - Min: 0, Max: 3 nodes    │    │     │    │    │
│  │  │  │  │   - Auto-scaling: ✓         │    │     │    │    │
│  │  │  │  │   - Taint: nvidia.com/gpu   │    │     │    │    │
│  │  │  │  │   - Labels: workload=gpu-llm│    │     │    │    │
│  │  │  │  └─────────────────────────────┘    │     │    │    │
│  │  │  │                                       │     │    │    │
│  │  │  │  ┌─────────────────────────────┐    │     │    │    │
│  │  │  │  │   Kubernetes Workloads       │    │     │    │    │
│  │  │  │  │                              │    │     │    │    │
│  │  │  │  │   ┌──────────────────────┐  │    │     │    │    │
│  │  │  │  │   │ LLM Deployment       │  │    │     │    │    │
│  │  │  │  │   │ - vLLM/TGI           │  │    │     │    │    │
│  │  │  │  │   │ - GPU: 1x T4         │  │    │     │    │    │
│  │  │  │  │   │ - Replicas: 1-3      │  │    │     │    │    │
│  │  │  │  │   └──────────────────────┘  │    │     │    │    │
│  │  │  │  │                              │    │     │    │    │
│  │  │  │  │   ┌──────────────────────┐  │    │     │    │    │
│  │  │  │  │   │ LoadBalancer Service │  │    │     │    │    │
│  │  │  │  │   │ - External IP        │  │    │     │    │    │
│  │  │  │  │   │ - Port: 80 → 8000    │  │    │     │    │    │
│  │  │  │  │   └──────────────────────┘  │    │     │    │    │
│  │  │  │  └─────────────────────────────┘    │     │    │    │
│  │  │  └───────────────────────────────────────┘     │    │    │
│  │  └────────────────────────────────────────────────┘    │    │
│  └──────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Module Dependency Graph

```
┌─────────────┐
│   Network   │
│   Module    │
└──────┬──────┘
       │ provides: network_name, subnet_name, IP ranges
       ↓
┌─────────────┐
│ GKE Cluster │
│   Module    │
└──────┬──────┘
       │ provides: cluster_name, endpoint
       ├────────────────────┐
       ↓                    ↓
┌─────────────┐      ┌─────────────┐
│  CPU Node   │      │  GPU Node   │
│ Pool Module │      │ Pool Module │
└─────────────┘      └─────────────┘
```

## 📊 Network Architecture

### IP Address Allocation

| Resource | CIDR Range | Capacity | Purpose |
|----------|-----------|----------|---------|
| Subnet (Primary) | 10.0.0.0/24 | 256 IPs | Node IPs |
| Pods (Secondary) | 10.1.0.0/16 | 65,536 IPs | Pod IPs |
| Services (Secondary) | 10.2.0.0/16 | 65,536 IPs | Service IPs |

### Network Flow

```
Internet
   ↓
LoadBalancer (External IP)
   ↓
Service (ClusterIP: 10.2.x.x)
   ↓
Pod (10.1.x.x) on GPU Node (10.0.0.x)
   ↓
LLM Container (vLLM/TGI)
```

## 🎯 Resource Hierarchy

```
GCP Project
└── VPC Network
    └── Subnet
        └── GKE Cluster
            ├── System Node Pool (auto-created, deleted)
            ├── CPU Node Pool
            │   ├── Node 1 (n1-standard-4)
            │   ├── Node 2 (n1-standard-4)
            │   └── Node 3-5 (auto-scaled)
            └── GPU Node Pool
                ├── Node 1 (n1-standard-8 + T4)
                ├── Node 2 (auto-scaled)
                └── Node 3 (auto-scaled)
```

## 🔒 Security Architecture

### Network Security

```
┌────────────────────────────────────────┐
│         Network Policies               │
│  - Namespace isolation                 │
│  - Pod-to-pod communication rules      │
└────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────┐
│      Firewall Rules (GCP)              │
│  - Control ingress/egress              │
│  - Managed by GKE                      │
└────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────┐
│      Shielded Nodes                    │
│  - Secure boot: ✓                      │
│  - Integrity monitoring: ✓             │
└────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────┐
│      Workload Identity                 │
│  - GCP service access                  │
│  - No service account keys             │
└────────────────────────────────────────┘
```

## 🚀 Deployment Flow

```
1. terraform init
   ↓ Download providers & modules
   
2. terraform plan
   ↓ Calculate changes
   
3. terraform apply
   ↓
   ├─→ Create VPC Network (30s)
   │   └─→ Create Subnet (30s)
   │
   ├─→ Create GKE Cluster (5-7 min)
   │   └─→ Configure cluster settings
   │
   ├─→ Create CPU Node Pool (2-3 min)
   │   └─→ Provision VMs
   │
   └─→ Create GPU Node Pool (3-5 min)
       ├─→ Provision VMs with GPUs
       └─→ Install NVIDIA drivers
   
4. kubectl apply -f k8s/
   ↓
   ├─→ Create namespace
   ├─→ Deploy LLM pods
   ├─→ Create service
   └─→ Setup HPA
   
5. Service LoadBalancer
   ↓ Allocate external IP (1-2 min)
   
6. LLM Ready! 🎉
```

## 📈 Scaling Architecture

### Cluster Autoscaling

```
Load Increase
   ↓
HPA scales pods (30s-1m)
   ↓
If nodes full → Cluster Autoscaler (2-5m)
   ↓
New node provisioned
   ↓
Pod scheduled on new node
```

### GPU Node Scaling

```
No Load → 0 GPU nodes (save $$$)
   ↓
Request arrives
   ↓
Scale up to 1 GPU node (3-5 min)
   ↓
High load detected
   ↓
Scale up to 2-3 GPU nodes
   ↓
Load decreases
   ↓
Scale down (after stabilization period)
```

## 🔧 Component Details

### GKE Cluster Features

| Feature | Status | Purpose |
|---------|--------|---------|
| VPC-Native | ✓ | Pod networking in VPC |
| Workload Identity | ✓ | Secure GCP access |
| Network Policies | ✓ | Pod-level firewall |
| Shielded Nodes | ✓ | Security hardening |
| Auto-repair | ✓ | Node health |
| Auto-upgrade | ✓ | Kubernetes updates |
| Logging | ✓ | Cloud Logging |
| Monitoring | ✓ | Cloud Monitoring |

### Node Pool Comparison

| Aspect | CPU Pool | GPU Pool |
|--------|----------|----------|
| **Purpose** | General workloads | LLM inference |
| **Machine Type** | n1-standard-4 | n1-standard-8 |
| **GPU** | None | 1x Tesla T4 |
| **Disk** | 100GB Standard | 200GB SSD |
| **Taint** | None | nvidia.com/gpu |
| **Label** | workload=general | workload=gpu-llm |
| **Min Nodes** | 1 | 0 |
| **Max Nodes** | 5 | 3 |
| **Cost/hour** | ~$0.20 | ~$0.73 |

## 🎨 Customization Points

### Easy Customizations

1. **GPU Type**: Change `gpu_type` variable
2. **Scaling Limits**: Adjust `min_nodes`/`max_nodes`
3. **Machine Types**: Change `machine_type` variables
4. **Region**: Set `region` variable
5. **Spot Instances**: Toggle `enable_spot` flags

### Advanced Customizations

1. **Multiple GPU Pools**: Add more node pool modules
2. **Private Cluster**: Enable private cluster config
3. **Multiple Regions**: Duplicate modules per region
4. **Custom Networks**: Modify network module
5. **Additional Node Pools**: Add specialized pools

## 📊 Resource Relationships

```
project_id ─────────────┐
                        ↓
                    All Resources

region ─────────┬───────────────┐
                ↓               ↓
            Subnet          GKE Cluster
                                ↓
                          Node Pools

network_name ───┬───────────┐
                ↓           ↓
            Subnet      GKE Cluster

cluster_name ───────┬────────┐
                    ↓        ↓
              CPU Pool   GPU Pool
```

## 🔍 Monitoring & Observability

```
┌─────────────────────────────────────┐
│      Cloud Monitoring               │
│  - Cluster metrics                  │
│  - Node metrics                     │
│  - Pod metrics                      │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│      Cloud Logging                  │
│  - Container logs                   │
│  - Audit logs                       │
│  - System logs                      │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│      Kubernetes Dashboard           │
│  - Resource utilization             │
│  - Pod status                       │
│  - Events                           │
└─────────────────────────────────────┘
```

## 💰 Cost Breakdown

```
Total Monthly Cost (~$1,034)
├── GKE Management: $74.40 (7%)
├── CPU Nodes: $292 (28%)
├── GPU Nodes: $588 (57%)
├── Networking: $40 (4%)
└── Storage: $40 (4%)
```

## 🎯 High Availability

- **Regional Cluster**: Nodes spread across multiple zones
- **Auto-repair**: Unhealthy nodes automatically replaced
- **Auto-upgrade**: Managed updates with minimal downtime
- **Load Balancer**: Multi-zone load distribution
- **Pod Replicas**: Multiple instances for redundancy

## 📚 Additional Resources

- [Network Module Details](modules/network/README.md)
- [GKE Cluster Module Details](modules/gke-cluster/README.md)
- [Node Pool Module Details](modules/node-pool/README.md)
- [Complete Modules Guide](MODULES.md)
- [Cost Optimization](COSTS.md)

