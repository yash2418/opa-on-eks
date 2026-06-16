# Quick Reference - Required User Inputs

## Node Group Configuration (Main Parameters to Customize)

These parameters control the EKS worker node behavior and should be customized based on your workload requirements.

### Instance Type

The EC2 instance type determines the compute power of your nodes.

**Common Options:**
- `t3.small` - 2 vCPU, 2 GB RAM (burstable, cost-effective for dev/test)
- `t3.medium` - 2 vCPU, 4 GB RAM (recommended for development)
- `t3.large` - 2 vCPU, 8 GB RAM (heavier dev workloads)
- `m5.large` - 2 vCPU, 8 GB RAM (general purpose, production)
- `m5.xlarge` - 4 vCPU, 16 GB RAM (production with more capacity)
- `c5.large` - 2 vCPU, 4 GB RAM (compute-optimized)
- `c5.2xlarge` - 8 vCPU, 16 GB RAM (compute-intensive workloads)

**Where to Set:** `terraform.tfvars` line ~25
```hcl
instance_type = "t3.medium"  # Change this value
```

---

### Minimum Nodes (node_group_min_size)

The minimum number of nodes that will always run, even if not needed.

**Recommendations:**
- Development: `1` or `2`
- Production: `3` (for high availability)
- Minimum allowed: `1`

**Impact:** Higher min sizes ensure capacity but increase costs.

**Where to Set:** `terraform.tfvars` line ~26
```hcl
node_group_min_size = 2  # Change this value
```

---

### Maximum Nodes (node_group_max_size)

The maximum number of nodes that can scale up during high demand.

**Recommendations:**
- Development: `3` to `5`
- Production: `10` to `20` (depends on workload)
- Should be significantly higher than desired size

**Impact:** Higher max sizes allow more scaling but increase potential costs.

**Where to Set:** `terraform.tfvars` line ~27
```hcl
node_group_max_size = 5  # Change this value
```

---

### Desired Nodes (node_group_desired_size)

The initial number of nodes to create. Must be between min and max.

**Recommendations:**
- Usually same as min_size for cost efficiency
- Can be higher if immediate capacity is needed
- Must satisfy: `min_size <= desired_size <= max_size`

**Where to Set:** `terraform.tfvars` line ~28
```hcl
node_group_desired_size = 2  # Change this value
```

---

### Disk Size (node_group_disk_size)

The root volume size in GB for each node's storage.

**Recommendations:**
- Minimum: `20` GB (default, for small workloads)
- Medium: `50` GB (for persistent data)
- Large: `100` GB (for data-intensive applications)

**Impact:** Affects node launch time and cost minimally.

**Where to Set:** `terraform.tfvars` line ~29
```hcl
node_group_disk_size = 20  # Change this value (in GB)
```

---

## Other Important Parameters

### Cluster Name
The name of your EKS cluster
**Default:** `eks-cluster`
**Example:** `my-production-cluster`

### Kubernetes Version
**Default:** `1.30`
**Options:** `1.28`, `1.29`, `1.30`, `1.31`

### VPC CIDR
Network range for your VPC
**Default:** `10.0.0.0/16`

---

## Example Configurations

### ✅ Minimal Development Setup
```hcl
instance_type           = "t3.small"
node_group_min_size     = 1
node_group_max_size     = 2
node_group_desired_size = 1
node_group_disk_size    = 20
```

### ✅ Standard Development Setup
```hcl
instance_type           = "t3.medium"     # Default
node_group_min_size     = 2               # Default
node_group_max_size     = 5               # Default
node_group_desired_size = 2               # Default
node_group_disk_size    = 20              # Default
```

### ✅ Production Setup (HA)
```hcl
instance_type           = "m5.large"
node_group_min_size     = 3
node_group_max_size     = 10
node_group_desired_size = 3
node_group_disk_size    = 50
```

### ✅ High-Performance Computing
```hcl
instance_type           = "c5.2xlarge"
node_group_min_size     = 2
node_group_max_size     = 8
node_group_desired_size = 3
node_group_disk_size    = 100
```

---

## How to Modify These Parameters

1. **Create terraform.tfvars from example:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars with your values:**
   ```bash
   nano terraform.tfvars  # or use your preferred editor
   ```

3. **Plan changes:**
   ```bash
   terraform plan
   ```

4. **Apply changes:**
   ```bash
   terraform apply
   ```

---

## Estimated Costs

**Instance Type × Nodes × Hours × Region Cost**

Example (US East 1 pricing, approximate):

| Setup | Instance | Min | Max | Desired | Hourly | Monthly (730 hrs) |
|-------|----------|-----|-----|---------|--------|------------------|
| Dev Small | t3.small | 1 | 2 | 1 | $0.02 | $15 |
| Dev Standard | t3.medium | 2 | 5 | 2 | $0.08 | $58 |
| Prod HA | m5.large | 3 | 10 | 3 | $0.30 | $219 |
| High Performance | c5.2xlarge | 2 | 8 | 3 | $0.68 | $497 |

*Costs are approximate and don't include NAT Gateway ($32/month) and other AWS services*

---

## Validation Rules

These rules are enforced by Terraform:

```
✓ min_size > 0
✓ max_size >= min_size
✓ desired_size >= min_size AND desired_size <= max_size
✓ instance_type must be valid AWS EC2 type
✓ disk_size >= 20
```

If you violate these rules, Terraform will show an error before creating resources.

---

## Quick Commands Reference

```bash
# Initialize
terraform init

# View what will be created
terraform plan

# Create infrastructure
terraform apply

# View outputs (cluster endpoint, kubeconfig command)
terraform output

# Modify configuration
nano terraform.tfvars
terraform plan
terraform apply

# Destroy everything
terraform destroy

# Get specific output
terraform output configure_kubectl
```

---

## Getting Help

- Check main [README.md](README.md) for detailed documentation
- AWS EKS Documentation: https://docs.aws.amazon.com/eks/
- Instance Type Selector: https://instances.vantage.sh/
