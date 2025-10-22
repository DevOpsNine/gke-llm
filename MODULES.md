# Terraform Modules Documentation

This document describes the modular structure of the LLM on GKE Terraform configuration.

## 📁 Module Structure

```
GCP/ai-lab/
├── main.tf              # Root module - orchestrates all modules
├── variables.tf         # Root variables
├── outputs.tf          # Root outputs
├── provider.tf         # Provider configuration
└── modules/
    ├── network/        # VPC and subnet module
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    ├── gke-cluster/    # GKE cluster module
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── node-pool/      # Node pool module (CPU/GPU)
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## 🎯 Module Overview

### 1. Network Module (`modules/network`)

**Purpose:** Creates VPC network and subnet with secondary IP ranges for GKE

**Resources:**
- `google_compute_network` - VPC network
- `google_compute_subnetwork` - Regional subnet with secondary ranges

**Key Features:**
- Custom VPC with auto-creation disabled
- Secondary IP ranges for pods and services
- VPC-native cluster support

**Usage:**
```hcl
module "network" {
  source = "./modules/network"

  project_id    = var.project_id
  network_name  = "${var.project_name}-vpc"
  subnet_name   = "${var.project_name}-subnet"
  region        = var.region
  subnet_cidr   = "10.0.0.0/24"
  pods_cidr     = "10.1.0.0/16"
  services_cidr = "10.2.0.0/16"
}
```

### 2. GKE Cluster Module (`modules/gke-cluster`)

**Purpose:** Creates GKE cluster with security and best practices enabled

**Resources:**
- `google_container_cluster` - GKE cluster

**Key Features:**
- Workload Identity enabled
- Network policies enabled
- Shielded nodes
- Auto-scaling support
- Logging and monitoring integration
- Daily maintenance window

**Usage:**
```hcl
module "gke_cluster" {
  source = "./modules/gke-cluster"

  project_id          = var.project_id
  cluster_name        = "${var.project_name}-gke-cluster"
  region              = var.region
  network_name        = module.network.network_name
  subnet_name         = module.network.subnet_name
  pods_range_name     = module.network.pods_range_name
  services_range_name = module.network.services_range_name
}
```

### 3. Node Pool Module (`modules/node-pool`)

**Purpose:** Creates managed node pools (supports both CPU and GPU)

**Resources:**
- `google_container_node_pool` - GKE node pool

**Key Features:**
- Unified module for CPU and GPU nodes
- Conditional GPU configuration
- Auto-scaling support
- Spot/preemptible instances support
- Automatic GPU taints for GPU nodes
- Custom labels for workload targeting
- Shielded instances

**Usage (CPU):**
```hcl
module "cpu_node_pool" {
  source = "./modules/node-pool"

  project_id     = var.project_id
  node_pool_name = "cpu-pool"
  cluster_name   = module.gke_cluster.cluster_name
  region         = var.region
  machine_type   = "n1-standard-4"
  node_count     = 2
  min_node_count = 1
  max_node_count = 5

  labels = { workload = "general" }
}
```

**Usage (GPU):**
```hcl
module "gpu_node_pool" {
  source = "./modules/node-pool"

  project_id     = var.project_id
  node_pool_name = "gpu-pool"
  cluster_name   = module.gke_cluster.cluster_name
  region         = var.region
  machine_type   = "n1-standard-8"
  node_count     = 1
  min_node_count = 0
  max_node_count = 3

  # GPU configuration
  gpu_type  = "nvidia-tesla-t4"
  gpu_count = 1

  labels = { workload = "gpu-llm" }
  enable_spot_instances = true
}
```

## 🔄 Module Dependencies

```
network
  ↓
gke-cluster
  ↓
├─→ cpu_node_pool
└─→ gpu_node_pool
```

Dependencies are managed using `depends_on` in the root `main.tf`:
- GKE cluster depends on network
- Node pools depend on GKE cluster

## 🎨 Module Design Principles

### 1. Single Responsibility
Each module has a clear, focused purpose:
- **Network**: Networking only
- **GKE Cluster**: Cluster configuration only
- **Node Pool**: Node pool management only

### 2. Reusability
Modules can be reused across different environments:
```hcl
# Development environment
module "dev_network" {
  source = "./modules/network"
  # ... dev config
}

# Production environment
module "prod_network" {
  source = "./modules/network"
  # ... prod config
}
```

### 3. Composability
Modules are designed to work together:
- Outputs from one module feed inputs to another
- Clear interfaces between modules
- Loose coupling for flexibility

### 4. Configurability
All important parameters are exposed as variables:
- Sensible defaults provided
- Easy to override
- Validation where appropriate

## 🔧 Customization Examples

### Adding a New Node Pool

```hcl
# In main.tf
module "inference_node_pool" {
  source = "./modules/node-pool"

  project_id     = var.project_id
  node_pool_name = "inference-pool"
  cluster_name   = module.gke_cluster.cluster_name
  region         = var.region
  machine_type   = "n1-highmem-8"
  node_count     = 3
  min_node_count = 2
  max_node_count = 10

  labels = {
    workload = "inference"
  }
}
```

### Using Multiple GPU Types

```hcl
module "t4_gpu_pool" {
  source = "./modules/node-pool"
  # ... T4 configuration
  gpu_type = "nvidia-tesla-t4"
}

module "a100_gpu_pool" {
  source = "./modules/node-pool"
  # ... A100 configuration
  gpu_type = "nvidia-tesla-a100"
}
```

### Creating Multi-Region Setup

```hcl
# Region 1
module "network_us_central" {
  source = "./modules/network"
  region = "us-central1"
  # ...
}

module "cluster_us_central" {
  source       = "./modules/gke-cluster"
  region       = "us-central1"
  network_name = module.network_us_central.network_name
  # ...
}

# Region 2
module "network_us_east" {
  source = "./modules/network"
  region = "us-east1"
  # ...
}

module "cluster_us_east" {
  source       = "./modules/gke-cluster"
  region       = "us-east1"
  network_name = module.network_us_east.network_name
  # ...
}
```

## 📚 Module Versioning (Future)

For production use, consider publishing modules to a registry:

```hcl
module "network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 5.0"
  # ...
}
```

Or use Git tags:

```hcl
module "network" {
  source = "git::https://github.com/your-org/terraform-modules.git//network?ref=v1.0.0"
  # ...
}
```

## 🧪 Testing Modules

### Individual Module Testing

```bash
# Test network module
cd modules/network
terraform init
terraform plan -var-file=test.tfvars

# Test GKE cluster module
cd modules/gke-cluster
terraform init
terraform plan -var-file=test.tfvars
```

### Integration Testing

```bash
# Test full stack from root
terraform plan
```

## 📖 Best Practices

### 1. Module Input Variables
- Use descriptive names
- Provide descriptions
- Set sensible defaults
- Add validation where needed

### 2. Module Outputs
- Export useful values
- Use descriptive names
- Mark sensitive outputs appropriately

### 3. Module Documentation
- README.md in each module
- Usage examples
- Input/output tables
- Notes and caveats

### 4. Module Versioning
- Use semantic versioning
- Document breaking changes
- Maintain CHANGELOG.md

### 5. Module Testing
- Test modules independently
- Test module composition
- Validate with different configurations

## 🔍 Troubleshooting

### Module Not Found
```
Error: Module not found
```
**Solution:** Ensure paths are correct and run `terraform init`

### Circular Dependencies
```
Error: Cycle in module dependencies
```
**Solution:** Review `depends_on` and implicit dependencies

### Variable Not Declared
```
Error: Reference to undeclared input variable
```
**Solution:** Declare variable in module's `variables.tf`

### Output Not Available
```
Error: Unsupported attribute
```
**Solution:** Ensure output is declared in module's `outputs.tf`

## 🚀 Migration from Monolithic

If migrating from the old monolithic `main.tf`:

1. **Backup existing state:**
   ```bash
   terraform state pull > terraform.tfstate.backup
   ```

2. **Initialize new modules:**
   ```bash
   terraform init
   ```

3. **Plan and verify:**
   ```bash
   terraform plan
   ```

4. **Apply if no changes:**
   ```bash
   terraform apply
   ```

**Note:** The refactored modular structure should show "no changes" if resources are already deployed.

## 📞 Support

- Check individual module READMEs for detailed documentation
- Review [main README.md](README.md) for overall project documentation
- See [COSTS.md](COSTS.md) for cost optimization strategies

## 🤝 Contributing

When adding new modules:
1. Create module directory under `modules/`
2. Include `main.tf`, `variables.tf`, `outputs.tf`
3. Add comprehensive `README.md`
4. Update this document
5. Test independently and as part of the stack

