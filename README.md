# OPA on EKS - Complete Repository

This repository contains infrastructure and policy enforcement configurations for deploying Open Policy Agent (OPA) with Gatekeeper on Amazon EKS (Elastic Kubernetes Service).

## 📁 Repository Structure

```
opa-on-eks/
├── argocd/                           # Argo CD configuration
│   ├── *.yaml                        # Argo CD Applications for services and Gatekeeper app
|
├── constraint-templates-hv/          # OPA/Gatekeeper constraint templates set 1
│   ├── Examples/                     # Example YAML manifests demonstrating policies
│   ├── *.yaml                        # Constraint templates and constraints
│   └── [Various template and constraint files]
│
├── constraint-templates-yr/          # OPA/Gatekeeper constraint templates set 2
│   ├── Examples/                     # Example YAML manifests demonstrating policies
│   ├── *.yaml                        # Constraint templates and constraints
│   └── [Various template and constraint files]
│
├── iac/                              # Infrastructure as Code (Terraform)
│   ├── modules/                      # Terraform modules
│   │   ├── vpc/                      # VPC module for networking
│   │   └── eks/                      # EKS module for Kubernetes cluster
│   ├── *.tf                          # Terraform configuration files
│   ├── terraform.tfvars.example      # Example variables configuration
│   ├── README.md                     # IaC detailed documentation
│   ├── QUICKSTART.md                 # Quick start guide for IaC
│   ├── ARCHITECTURE.md               # Architecture overview
│   └── USER_INPUTS.md                # User input configuration guide
│
└── README.md                         # This file
```

## 🔧 Directory Overview

### 1. Constraint Templates - Set 1 (`constraint-templates-hv/`)

This directory contains OPA/Gatekeeper constraint templates for policy enforcement.

**Contents:**
- **Examples/** - Example Kubernetes manifests that demonstrate both allowed and denied scenarios for policies
  - Pod specifications (allowed and denied)
  - Service configurations
  - Deployment examples

**Purpose:** Provides a complete set of policy definitions and test cases for validating policy behavior.

---

### 2. Constraint Templates - Set 2 (`constraint-templates-yr/`)

The primary directory containing OPA/Gatekeeper constraint templates and constraints for enforcing Kubernetes policies.

**Key Files:**
- `*-template.yaml` - ConstraintTemplate definitions that define policy rules using Rego
- `*-constraint.yaml` - Constraint manifests that enforce the templates
- **Examples/** - Example YAML files for testing policies

**Included Policies:**
- **allowed-registries** - Restrict container image registries
- **deny-default-namespace** - Prevent deployment to default namespace
- **deny-load-balancer-service** - Block LoadBalancer service type
- **required-readiness-probe** - Enforce readiness probes on containers
- **required-resources** - Mandate resource requests/limits
- **required-label** - Enforce specific labels on resources
- **restrict-max-replica-count** - Limit maximum replicas in deployments

**Example Scenarios:**
- Pod configurations (valid and invalid)
- Service configurations (allowed and denied)
- Deployment manifests with various configurations

**Purpose:** Provides policy enforcement rules and test manifests for validating Kubernetes cluster compliance.

---

### 3. Infrastructure as Code (`iac/`)

Terraform configuration for provisioning AWS EKS cluster infrastructure.

**Structure:**

#### Root Level Configuration Files:
- `main.tf` - AWS provider configuration
- `root_module.tf` - Module instantiation
- `variables.tf` - Root-level input variables
- `outputs.tf` - Root-level outputs
- `backend.tf` - Terraform state backend configuration
- `terraform.tfvars.example` - Example configuration template

#### Modules:
- **vpc/** - Creates VPC, subnets, Internet Gateway, NAT Gateway, and route tables
- **eks/** - Creates EKS cluster, node groups, IAM roles, and security groups

#### Documentation:
- **README.md** - Comprehensive guide covering all aspects of the infrastructure
- **QUICKSTART.md** - 5-minute quick start guide for getting EKS cluster running
- **ARCHITECTURE.md** - Detailed architecture overview and component interactions
- **USER_INPUTS.md** - User configuration reference guide with examples and cost estimates

**Key Features:**
- Automated EKS cluster creation with configurable node groups
- Complete networking infrastructure (VPC, subnets, gateways)
- IAM role and policy management
- Scalable node group configuration (min, max, desired size)
- Support for multiple EC2 instance types
- Remote state management via S3
- Terraform validation and best practices

**Quick Start:**
```bash
cd iac
terraform init
terraform plan
terraform apply
```

See [iac/QUICKSTART.md](iac/QUICKSTART.md) for detailed instructions.

---

## 🎯 Quick Start Guide

### Prerequisites
- AWS Account with appropriate permissions
- Terraform >= 1.0 installed
- AWS CLI configured
- kubectl installed (for interacting with the cluster)

### 1. Set Up Infrastructure

```bash
cd iac
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

### 2. Deploy OPA/Gatekeeper

```bash
# Configure kubectl to access your EKS cluster
aws eks update-kubeconfig --region <region> --name <cluster-name>

# Apply constraint templates from constraint-templates-yr/
kubectl apply -f constraint-templates-yr/
```

### 3. Test Policies

```bash
# Apply test manifests to verify policies are working
kubectl apply -f constraint-templates-yr/Examples/
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| [iac/README.md](iac/README.md) | Complete Terraform module documentation |
| [iac/QUICKSTART.md](iac/QUICKSTART.md) | 5-minute quick start guide |
| [iac/ARCHITECTURE.md](iac/ARCHITECTURE.md) | Architecture and component overview |
| [iac/USER_INPUTS.md](iac/USER_INPUTS.md) | Configuration parameters and examples |

---

## 🛡️ Policy Enforcement

The constraint templates enforce security and compliance policies:

1. **Image Registry Control** - Restrict container images to approved registries
2. **Namespace Isolation** - Prevent using default namespace
3. **Network Policy** - Block LoadBalancer service types
4. **Reliability** - Require readiness probes for containers
5. **Resource Management** - Enforce CPU/memory requests and limits
6. **Labeling** - Enforce required labels for tracking
7. **Scaling Limits** - Restrict maximum replica counts

Each policy includes:
- Template definition with Rego rules
- Constraint for enforcement
- Example manifests showing allowed/denied scenarios

---

## 🚀 Features

### Infrastructure
✅ Fully automated EKS cluster provisioning  
✅ Scalable node group configuration  
✅ Secure networking (VPC, NAT, IGW)  
✅ IAM role management  
✅ Remote state management  
✅ Support for multiple AWS regions

### Policy Management
✅ Pre-configured OPA/Gatekeeper templates  
✅ Example test cases for each policy  
✅ Deny-by-default security model  
✅ Easy policy customization  
✅ Comprehensive validation examples

---

## 📋 Requirements

### For Infrastructure Deployment
- Terraform >= 1.0
- AWS CLI v2
- AWS Account with permissions for:
  - EKS
  - EC2
  - VPC
  - IAM
  - S3 (for state backend)

### For Policy Enforcement
- kubectl
- Helm (optional, for package management)
- Gatekeeper installed on EKS cluster

---

## 💡 Common Tasks

### Scale the Cluster
Edit `iac/terraform.tfvars`:
```hcl
node_group_min_size     = 3
node_group_max_size     = 10
node_group_desired_size = 3
```
Then run: `terraform apply`

### Change Instance Type
Edit `iac/terraform.tfvars`:
```hcl
instance_type = "m5.large"  # Change from t3.medium
```

### View Cluster Information
```bash
cd iac
terraform output
```

### Destroy All Infrastructure
```bash
cd iac
terraform destroy
```

---

## 🔗 Related Resources

- [OPA Documentation](https://www.openpolicyagent.org/)
- [Gatekeeper Documentation](https://open-policy-agent.github.io/gatekeeper/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
