# Contributing Guide

Thank you for your interest in contributing to this project! This guide will help you understand the project structure and how to contribute effectively.

## 📁 Project Structure

```
GCP/ai-lab/
├── main.tf              # Root module orchestration
├── variables.tf         # Root-level variables
├── outputs.tf           # Root-level outputs
├── provider.tf          # Provider configuration
├── modules/             # Reusable Terraform modules
│   ├── network/        # VPC and subnet
│   ├── gke-cluster/    # GKE cluster configuration
│   └── node-pool/      # Node pool management
├── k8s/                # Kubernetes manifests
├── scripts/            # Automation scripts
└── docs/               # Documentation

Documentation Files:
├── README.md           # Main documentation
├── QUICKSTART.md       # Quick start guide
├── MODULES.md          # Module documentation
├── ARCHITECTURE.md     # Architecture overview
├── COSTS.md            # Cost information
├── MIGRATION_GUIDE.md  # Migration instructions
└── CONTRIBUTING.md     # This file
```

## 🎯 How to Contribute

### 1. Reporting Issues

When reporting issues, please include:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Environment details (Terraform version, GCP region, etc.)
- Relevant logs or error messages

### 2. Suggesting Enhancements

For feature requests:
- Describe the use case
- Explain why this would be valuable
- Provide examples if possible
- Consider implementation complexity

### 3. Code Contributions

#### Before You Start

1. Check existing issues and pull requests
2. Discuss major changes in an issue first
3. Follow the project's coding style
4. Ensure your changes don't break existing functionality

#### Development Workflow

```bash
# 1. Fork and clone the repository
git clone https://github.com/your-username/llm-gke-deployment.git
cd llm-gke-deployment

# 2. Create a feature branch
git checkout -b feature/your-feature-name

# 3. Make your changes

# 4. Test your changes
terraform init
terraform validate
terraform plan

# 5. Commit with clear messages
git commit -m "feat: add support for A100 GPUs"

# 6. Push and create pull request
git push origin feature/your-feature-name
```

## 📝 Coding Standards

### Terraform Code Style

```hcl
# Use descriptive resource names
resource "google_compute_network" "vpc" {  # Good
  name = var.network_name
}

# Format code with terraform fmt
terraform fmt -recursive

# Add comments for complex logic
# This creates a VPC-native subnet with secondary ranges
resource "google_compute_subnetwork" "subnet" {
  # ... configuration
}

# Use meaningful variable names
variable "gpu_type" {          # Good
  description = "Type of GPU"
  type        = string
}

variable "x" {                 # Bad
  type = string
}
```

### Module Design Principles

1. **Single Responsibility**: Each module should do one thing well
2. **Minimal Interface**: Expose only necessary variables and outputs
3. **Documentation**: Every module needs a README.md
4. **Validation**: Add validation rules for critical variables
5. **Defaults**: Provide sensible defaults where possible

### Documentation Standards

#### Module README Structure

```markdown
# Module Name

Brief description

## Features
- Feature 1
- Feature 2

## Usage
```hcl
module "example" {
  source = "./modules/example"
  # ...
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|

## Outputs
| Name | Description |
|------|-------------|

## Notes
Additional information
```

### Commit Message Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add support for A100 GPUs
fix: correct GPU taint configuration
docs: update cost estimation guide
refactor: reorganize network module
test: add validation for GPU types
chore: update Terraform providers
```

## 🧪 Testing

### Before Submitting PR

1. **Validate Terraform Code**
   ```bash
   terraform fmt -check -recursive
   terraform validate
   ```

2. **Test Module Independently**
   ```bash
   cd modules/your-module
   terraform init
   terraform validate
   ```

3. **Test Integration**
   ```bash
   terraform plan
   ```

4. **Check Documentation**
   - All modules have README.md
   - Variable descriptions are clear
   - Examples are provided

### Testing Checklist

- [ ] Code formatted with `terraform fmt`
- [ ] Configuration validated with `terraform validate`
- [ ] No linting errors
- [ ] Module README updated
- [ ] Examples provided
- [ ] Variables have descriptions
- [ ] Sensitive outputs marked as sensitive
- [ ] Default values are sensible

## 📚 Documentation Contributions

### What to Document

- New features and how to use them
- Configuration options
- Common use cases
- Troubleshooting tips
- Cost implications
- Security considerations

### Documentation Files to Update

When adding features, consider updating:
- `README.md` - Main documentation
- `MODULES.md` - If adding/modifying modules
- `ARCHITECTURE.md` - If changing architecture
- `COSTS.md` - If impacting costs
- Module-specific `README.md` files

## 🔧 Module Contribution Guidelines

### Creating a New Module

1. **Structure**
   ```
   modules/your-module/
   ├── main.tf
   ├── variables.tf
   ├── outputs.tf
   └── README.md
   ```

2. **Required Files**
   - `main.tf` - Resource definitions
   - `variables.tf` - Input variables
   - `outputs.tf` - Output values
   - `README.md` - Documentation

3. **Template**

   **main.tf**:
   ```hcl
   # Module: your-module
   # Purpose: Brief description

   resource "google_resource_type" "name" {
     # Configuration
   }
   ```

   **variables.tf**:
   ```hcl
   variable "required_var" {
     description = "Clear description"
     type        = string
   }

   variable "optional_var" {
     description = "Clear description"
     type        = string
     default     = "sensible_default"
   }
   ```

   **outputs.tf**:
   ```hcl
   output "important_value" {
     description = "Clear description"
     value       = resource.attribute
   }
   ```

### Modifying Existing Modules

1. **Backward Compatibility**: Don't break existing users
2. **Deprecation**: Mark old features as deprecated before removing
3. **Migration Path**: Provide clear upgrade instructions
4. **Testing**: Test with existing configurations

## 🐛 Debugging Tips

### Common Issues

1. **Module Not Found**
   ```bash
   terraform get  # Download modules
   terraform init # Initialize
   ```

2. **State Issues**
   ```bash
   terraform state list  # List resources
   terraform state show resource.name  # Inspect resource
   ```

3. **Plan Differences**
   ```bash
   terraform plan -out=tfplan  # Save plan
   terraform show tfplan       # Inspect plan
   ```

## 🎨 Best Practices

### DO ✅

- Write clear, descriptive commit messages
- Add comments for complex logic
- Provide examples in documentation
- Test changes thoroughly
- Keep PRs focused and small
- Update relevant documentation
- Follow existing code style
- Use meaningful names

### DON'T ❌

- Submit large, unfocused PRs
- Break backward compatibility without notice
- Skip testing
- Leave code unformatted
- Ignore linting errors
- Commit sensitive data
- Hardcode values
- Skip documentation

## 🚀 Release Process

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

### Changelog

Update CHANGELOG.md:
```markdown
## [1.1.0] - 2024-01-15

### Added
- Support for A100 GPUs
- Cost estimation calculator

### Changed
- Updated default GPU type to T4

### Fixed
- GPU taint configuration
```

## 💬 Communication

### Where to Ask Questions

- **Issues**: Bug reports, feature requests
- **Discussions**: General questions, ideas
- **Pull Requests**: Code review, feedback

### Response Times

- We aim to respond to issues within 2-3 days
- PRs will be reviewed within 1 week
- Critical bugs will be addressed ASAP

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

## 🙏 Recognition

All contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in documentation

## 📞 Contact

- GitHub Issues: For bugs and features
- Email: [Your email if applicable]
- Slack/Discord: [If applicable]

---

**Thank you for contributing! Your efforts help make this project better for everyone.** 🎉

