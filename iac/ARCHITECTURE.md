# Architecture Overview

## Infrastructure Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          AWS Account                             │
└─────────────────────────────────────────────────────────────────┘
                                 │
                ┌────────────────┴────────────────┐
                │                                 │
        ┌───────▼────────────┐          ┌────────▼──────────┐
        │   VPC Module       │          │  EKS Module       │
        │  (modules/vpc)     │          │ (modules/eks)     │
        └──────────────────┬─┘          └────────┬──────────┘
                           │                     │
        ┌──────────────────▼──────────┐  ┌──────▼──────────────┐
        │  VPC Resources             │  │  EKS Resources     │
        ├────────────────────────────┤  ├────────────────────┤
        │ • VPC (10.0.0.0/16)       │  │ • EKS Cluster      │
        │ • Public Subnet            │  │ • Node Group       │
        │ • Private Subnet           │  │ • IAM Roles        │
        │ • Internet Gateway         │  │ • Security Groups  │
        │ • NAT Gateway              │  │ • CloudWatch Logs  │
        │ • Elastic IP               │  │                    │
        │ • Route Tables             │  │                    │
        └────────────────────────────┘  └────────────────────┘
                           │                     │
                           └──────────┬──────────┘
                                      │
                        ┌─────────────▼──────────────┐
                        │   Kubernetes Cluster       │
                        ├────────────────────────────┤
                        │ Control Plane (Managed)    │
                        │                            │
                        │  Worker Nodes:             │
                        │  • Min: 2 (configurable)   │
                        │  • Max: 5 (configurable)   │
                        │  • Type: t3.medium (config)│
                        │  • Disk: 20GB (config)     │
                        └────────────────────────────┘
```

## Module Dependencies

```
┌─────────────────────────┐
│   Root Module           │
│   (main directory)      │
└──────────┬──────────────┘
           │
    ┌──────┴──────┐
    │             │
    │             │
┌───▼──────┐  ┌──▼───────┐
│ VPC      │  │ EKS      │
│ Module   │  │ Module   │
└──────────┘  └────┬─────┘
                   │
            (depends on)
                   │
               VPC Module
```

## File Structure

```
EKS-Template/
├── modules/
│   ├── vpc/                      # VPC Module
│   │   ├── versions.tf           # Terraform & provider requirements
│   │   ├── variables.tf          # Input variables
│   │   ├── vpc.tf                # VPC & subnets
│   │   ├── igw.tf                # Internet Gateway
│   │   ├── nat_gateway.tf        # NAT Gateway & Elastic IP
│   │   ├── route_tables.tf       # Route table configuration
│   │   └── outputs.tf            # Module outputs
│   │
│   └── eks/                      # EKS Module
│       ├── versions.tf           # Terraform & provider requirements
│       ├── variables.tf          # Input variables (inc. node config)
│       ├── iam.tf                # IAM roles and policies
│       ├── eks.tf                # EKS cluster & security groups
│       ├── node_group.tf         # Node group (CONFIGURABLE)
│       └── outputs.tf            # Module outputs
│
├── main.tf                       # Provider configuration
├── root_module.tf                # Module instantiation
├── variables.tf                  # Root-level input variables
├── outputs.tf                    # Root-level outputs
│
├── terraform.tfvars.example      # Example configuration
├── README.md                     # Full documentation
├── USER_INPUTS.md                # User input guide
├── .gitignore                    # Git ignore rules
└── ARCHITECTURE.md               # This file
```

## Data Flow

### Configuration Input
```
terraform.tfvars
    ↓
variables.tf (root)
    ↓
root_module.tf (instantiates modules)
    ├→ VPC Module variables.tf
    │   ├→ vpc.tf
    │   ├→ igw.tf
    │   ├→ nat_gateway.tf
    │   └→ route_tables.tf
    │       ↓
    │   VPC resources created
    │
    └→ EKS Module variables.tf (NODE GROUP CONFIG HERE)
        ├→ iam.tf
        ├→ eks.tf
        └→ node_group.tf
            ↓
        EKS resources created
```

## Node Group Scaling Flow

```
User modifies terraform.tfvars
    ↓
Updates:
  - instance_type
  - node_group_min_size
  - node_group_max_size
  - node_group_desired_size
    ↓
terraform plan
    ↓
terraform apply
    ↓
EKS Node Group Updated
    ↓
EC2 instances scale accordingly
    ↓
Kubernetes nodes ready
```

## Resource Dependencies

```
VPC Creation Order:
1. VPC
2. Subnets (public & private)
3. Internet Gateway
4. Elastic IP for NAT
5. NAT Gateway
6. Route Tables
7. Route Table Associations

EKS Creation Order:
1. IAM Roles (cluster & nodes)
2. Security Groups
3. EKS Cluster
   ├─ Control plane starts
   └─ (depends on VPC/subnets)
4. EKS Node Group
   ├─ IAM role attachment
   ├─ Nodes launch
   └─ Nodes join cluster
```

## Network Architecture

```
┌──────────────────────────────────────────────────────┐
│              VPC (10.0.0.0/16)                       │
│                                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │   Public Subnet (10.0.1.0/24)                  │ │
│  │                                                │ │
│  │   ┌──────────────────────┐                    │ │
│  │   │  NAT Gateway + EIP   │  ◄───┐             │ │
│  │   └──────────┬───────────┘      │             │ │
│  │              │                   │             │ │
│  │   ┌──────────▼──────────────┐   │             │ │
│  │   │ Internet Gateway (IGW)  │   │             │ │
│  │   └───────────┬──────────────┘   │             │ │
│  │               │                  │             │ │
│  └───────────────┼──────────────────┼─────────────┘ │
│                  │                  │                │
│                  │ (0.0.0.0/0)      │                │
│                  │                  │                │
│  ┌───────────────▼──────────────────▼─────────────┐ │
│  │   Private Subnet (10.0.2.0/24)                 │ │
│  │                                                │ │
│  │   ┌──────────────────────────────────────────┐│ │
│  │   │      EKS Worker Nodes                    ││ │
│  │   │      • min_size nodes                    ││ │
│  │   │      • max_size configurable             ││ │
│  │   │      • instance_type: configurable       ││ │
│  │   │      • Outbound via NAT Gateway          ││ │
│  │   │                                          ││ │
│  │   │  ┌──────────────────────────────┐       ││ │
│  │   │  │ Kubernetes Cluster           │       ││ │
│  │   │  │ Control Plane (managed)      │       ││ │
│  │   │  │ Nodes join here              │       ││ │
│  │   │  └──────────────────────────────┘       ││ │
│  │   └──────────────────────────────────────────┘│ │
│  │                                                │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
└──────────────────────────────────────────────────────┘
```

## Key Customization Points

### 1. Node Group Configuration (Highest Priority)
Located in: `terraform.tfvars`

```
instance_type           = "t3.medium"     ← Instance type
node_group_min_size     = 2               ← Minimum nodes
node_group_max_size     = 5               ← Maximum nodes
node_group_desired_size = 2               ← Initial nodes
node_group_disk_size    = 20              ← Disk size GB
```

### 2. VPC Configuration
Located in: `terraform.tfvars`

```
vpc_cidr            = "10.0.0.0/16"       ← VPC network
public_subnet_cidr  = "10.0.1.0/24"       ← Public subnet
private_subnet_cidr = "10.0.2.0/24"       ← Private subnet
```

### 3. Cluster Configuration
Located in: `terraform.tfvars`

```
cluster_name       = "my-eks-cluster"     ← Cluster name
kubernetes_version = "1.30"               ← K8s version
```

## Outputs Available After Creation

Root module provides these outputs:

```
vpc_id                    → VPC resource ID
vpc_cidr                  → VPC CIDR block
public_subnet_id          → Public subnet ID
private_subnet_id         → Private subnet ID
nat_gateway_ip            → NAT gateway Elastic IP
eks_cluster_id            → EKS cluster name
eks_cluster_arn           → EKS cluster ARN
eks_cluster_endpoint      → Kubernetes API endpoint
eks_cluster_version       → Kubernetes version
eks_node_group_id         → Node group ID
configure_kubectl         → Command to configure kubectl
```

## Resource Costs

### Fixed Monthly Costs:
- EKS Cluster: $0.10/hour ≈ $73/month
- NAT Gateway: $32/month + data transfer
- EBS volumes: ~$1/GB-month

### Variable Costs (Per Node):
- Instance: Depends on `instance_type` and region
- Data transfer: Outbound traffic via NAT

### Example (t3.medium, 2 nodes, US-East-1):
- EKS Cluster: $73
- 2 × t3.medium: ~$58 ($0.04/hour each)
- NAT Gateway: $32
- **Total: ~$163/month**

## Troubleshooting Path

```
Issue Occurs
    ↓
Check terraform.tfvars values
    ↓
Run: terraform plan
    ↓
Check error messages
    ↓
Verify AWS permissions
    ↓
Check VPC availability zone
    ↓
Check instance type availability
    ↓
Review AWS CloudFormation events
    ↓
Check Security Groups
    ↓
Verify IAM roles
```

## Next Steps After Infrastructure Creation

1. **Configure kubectl:**
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name <cluster_name>
   ```

2. **Verify cluster:**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

3. **Deploy applications:**
   Use kubectl or Helm to deploy your workloads

4. **Set up monitoring:**
   Configure CloudWatch, Prometheus, or other monitoring

5. **Configure autoscaling:**
   Install Cluster Autoscaler or KARPENTER

6. **Set up ingress:**
   Install AWS Load Balancer Controller or NGINX Ingress

7. **Enable RBAC:**
   Configure role-based access control for teams
