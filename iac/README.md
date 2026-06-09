# EKS Terraform Modules

This repository contains two Terraform modules for deploying a complete EKS infrastructure on AWS:

1. **VPC Module** - Creates a VPC with public/private subnets, Internet Gateway, and NAT Gateway
2. **EKS Module** - Creates an EKS cluster with a configurable node group

## Directory Structure

```
.
├── modules/
│   ├── vpc/
│   │   ├── versions.tf
│   │   ├── variables.tf
│   │   ├── vpc.tf
│   │   ├── igw.tf
│   │   ├── nat_gateway.tf
│   │   ├── route_tables.tf
│   │   └── outputs.tf
│   └── eks/
│       ├── versions.tf
│       ├── variables.tf
│       ├── iam.tf
│       ├── eks.tf
│       ├── node_group.tf
│       └── outputs.tf
├── main.tf
├── root_module.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
└── README.md
```

## Prerequisites

- Terraform >= 1.0
- AWS Account and AWS CLI configured with appropriate credentials
- AWS IAM permissions to create EKS, EC2, VPC, and IAM resources

## VPC Module

The VPC module creates the following resources:

### Resources Created:
- **VPC** - Main Virtual Private Cloud
- **Public Subnet** - For NAT Gateway and load balancers
- **Private Subnet** - For EKS worker nodes
- **Internet Gateway (IGW)** - For public internet access
- **NAT Gateway** - For private subnet outbound traffic
- **Elastic IP** - For NAT Gateway
- **Route Tables** - For public and private subnets with appropriate routes

### VPC Module Variables:

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `project_name` | Project name prefix for resources | - | string (required) |
| `vpc_cidr` | CIDR block for VPC | `10.0.0.0/16` | string |
| `public_subnet_cidr` | CIDR for public subnet | `10.0.1.0/24` | string |
| `private_subnet_cidr` | CIDR for private subnet | `10.0.2.0/24` | string |
| `aws_region` | AWS region | `us-east-1` | string |
| `availability_zone` | Availability zone | `us-east-1a` | string |
| `environment` | Environment name (dev/staging/prod) | `dev` | string |
| `tags` | Common tags for resources | `{}` | map(string) |

### VPC Module Outputs:

- `vpc_id` - VPC ID
- `vpc_cidr` - VPC CIDR block
- `public_subnet_id` - Public subnet ID
- `private_subnet_id` - Private subnet ID
- `nat_gateway_id` - NAT Gateway ID
- `internet_gateway_id` - Internet Gateway ID
- `nat_gateway_ip` - NAT Gateway Elastic IP

## EKS Module

The EKS module creates the following resources:

### Resources Created:
- **EKS Cluster** - Managed Kubernetes control plane
- **Node Group** - Managed worker nodes (configurable)
- **IAM Roles** - For cluster and node groups
- **Security Groups** - For cluster control plane and worker nodes
- **CloudWatch Logs** - For cluster logging

### EKS Module Variables (USER CONFIGURABLE):

#### Required Parameters:

| Variable | Description | Type |
|----------|-------------|------|
| `cluster_name` | Name of EKS cluster | string (required) |
| `vpc_id` | VPC ID for cluster | string (required) |
| `subnet_ids` | Public subnet IDs | list(string) (required) |
| `private_subnet_ids` | Private subnet IDs for nodes | list(string) (required) |
| `project_name` | Project name prefix | string (required) |

#### Node Group Parameters (USER CONFIGURABLE):

| Variable | Description | Default | Type | Validation |
|----------|-------------|---------|------|-----------|
| `instance_type` | EC2 instance type | `t3.medium` | string | - |
| `node_group_min_size` | Minimum number of nodes | `2` | number | > 0 |
| `node_group_max_size` | Maximum number of nodes | `5` | number | >= min_size |
| `node_group_desired_size` | Desired number of nodes | `2` | number | between min & max |
| `disk_size` | Disk size in GB | `20` | number | - |

#### Optional Parameters:

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `kubernetes_version` | Kubernetes version | `1.30` | string |
| `node_group_name` | Node group name | `primary` | string |
| `environment` | Environment name | `dev` | string |
| `tags` | Common tags | `{}` | map(string) |

### Instance Type Recommendations:

**Development Environments:**
- `t3.small` - Light workloads, testing
- `t3.medium` - Standard dev workloads
- `t3.large` - Heavier dev workloads

**Production Environments:**
- `m5.large` - General purpose, balanced workloads
- `m5.xlarge` - High availability requirements
- `c5.large` - Compute optimized workloads
- `c5.xlarge` - Heavy compute workloads

### EKS Module Outputs:

- `cluster_id` - EKS cluster ID
- `cluster_arn` - EKS cluster ARN
- `cluster_endpoint` - Kubernetes API endpoint
- `cluster_version` - Kubernetes version
- `cluster_security_group_id` - Control plane security group
- `node_group_security_group_id` - Node group security group
- `node_group_id` - Node group ID
- `cluster_oidc_issuer_url` - OIDC issuer URL for IRSA

## Usage

### Step 1: Prepare Configuration

Copy the example terraform variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

### Step 2: Edit terraform.tfvars

Edit `terraform.tfvars` with your desired configuration:

```hcl
# AWS Configuration
aws_region = "us-east-1"

# Project Configuration
project_name = "my-eks-project"
environment  = "dev"

# VPC Configuration
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
availability_zone   = "us-east-1a"

# EKS Cluster Configuration
cluster_name       = "my-eks-cluster"
kubernetes_version = "1.30"

# Node Group Configuration - CUSTOMIZE THIS SECTION
instance_type           = "t3.medium"     # Change instance type here
node_group_min_size     = 2               # Minimum nodes
node_group_max_size     = 5               # Maximum nodes
node_group_desired_size = 2               # Initial desired nodes
node_group_disk_size    = 20              # Node disk size in GB

# Common Tags
common_tags = {
  Terraform   = "true"
  Project     = "EKS"
  ManagedBy   = "Terraform"
  Environment = "dev"
}
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Review Plan

```bash
terraform plan
```

This will show all resources that will be created. Review carefully.

### Step 5: Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm resource creation.

### Step 6: Configure kubectl

After resources are created, configure kubectl using the output command:

```bash
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
```

Or use the output from terraform:

```bash
terraform output configure_kubectl
```

Then verify cluster access:

```bash
kubectl get nodes
```

## Customizing Node Group Parameters

The node group parameters can be customized in the `terraform.tfvars` file:

### Example 1: Production Setup

```hcl
instance_type           = "m5.xlarge"
node_group_min_size     = 3
node_group_max_size     = 10
node_group_desired_size = 5
node_group_disk_size    = 50
```

### Example 2: Development Setup

```hcl
instance_type           = "t3.small"
node_group_min_size     = 1
node_group_max_size     = 3
node_group_desired_size = 1
node_group_disk_size    = 20
```

### Example 3: Compute-Optimized Setup

```hcl
instance_type           = "c5.2xlarge"
node_group_min_size     = 2
node_group_max_size     = 8
node_group_desired_size = 3
node_group_disk_size    = 30
```

## Scaling Nodes

To scale the node group after creation, modify the parameters in `terraform.tfvars`:

```hcl
node_group_desired_size = 5  # Change from 2 to 5
```

Then apply:

```bash
terraform apply
```

**Note:** The node group is configured to ignore changes to `desired_size` made outside of Terraform (e.g., by auto-scaler). To manually scale, update `terraform.tfvars`.

## Updating Kubernetes Version

To update the Kubernetes version:

1. Update `kubernetes_version` in `terraform.tfvars`
2. Run `terraform plan` to review changes
3. Run `terraform apply` to update both cluster and nodes

```hcl
kubernetes_version = "1.31"  # Update version
```

## Required User Inputs Summary

### Mandatory Inputs:

1. **AWS Region** - Where to deploy (default: `us-east-1`)
2. **Project Name** - Prefix for all resources
3. **Cluster Name** - Name of EKS cluster

### Node Group Inputs (Highly Configurable):

1. **Instance Type** - EC2 instance type (default: `t3.medium`)
2. **Minimum Nodes** - Minimum auto-scaling size (default: `2`)
3. **Maximum Nodes** - Maximum auto-scaling size (default: `5`)
4. **Desired Nodes** - Initial number of nodes (default: `2`)
5. **Disk Size** - Root volume size in GB (default: `20`)

### Optional Inputs:

1. **VPC CIDR** - VPC network range (default: `10.0.0.0/16`)
2. **Subnets** - Subnet CIDRs (customizable)
3. **Kubernetes Version** - K8s version (default: `1.30`)
4. **Environment** - Environment name (default: `dev`)
5. **Tags** - Custom resource tags

## Destroying Infrastructure

To destroy all created resources:

```bash
terraform destroy
```

Type `yes` when prompted. This will remove:
- EKS cluster and node groups
- VPC and subnets
- NAT Gateway and Elastic IP
- Internet Gateway
- Route tables
- Security groups
- IAM roles and policies

## Best Practices

1. **Use terraform.tfvars** - Keep production values separate from code
2. **State Management** - Use remote state (S3 + DynamoDB) for team environments
3. **Version Control** - Commit only `*.tf` files, NOT `terraform.tfvars`
4. **Review Plans** - Always review `terraform plan` output before applying
5. **Tags** - Use meaningful tags for cost tracking and resource management
6. **Backups** - Keep terraform state backed up

## Troubleshooting

### VPC Creation Issues
- Ensure AWS credentials are configured
- Check IAM permissions for VPC, subnet, and routing operations
- Verify availability zone exists in selected region

### EKS Cluster Issues
- Check security group rules allow necessary traffic
- Verify subnets are in correct VPC
- Ensure IAM roles have required permissions

### Node Group Issues
- Verify EC2 capacity in selected region
- Check instance type availability in availability zone
- Ensure sufficient AWS account limits

### Kubectl Connection Issues
```bash
# Verify cluster is ready
aws eks describe-cluster --name my-eks-cluster --region us-east-1

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Test connection
kubectl cluster-info
```

## Support

For issues or questions, refer to:
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
