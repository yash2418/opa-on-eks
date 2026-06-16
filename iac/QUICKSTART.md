# Quick Start Guide

Get your EKS cluster up and running in 5 minutes!

## Prerequisites

- Terraform installed (v1.0+)
- AWS CLI configured with credentials
- kubectl installed (optional, for managing cluster after creation)

## Step 1: Prepare Your Configuration (1 minute)

```bash
# Navigate to the project directory
cd /home/ccdeveloper/Projects/EKS-Template

# Create your configuration from the example
cp terraform.tfvars.example terraform.tfvars
```

## Step 2: Edit Configuration (2 minutes)

Edit `terraform.tfvars` with your desired values:

```bash
nano terraform.tfvars
```

**Key Parameters to Modify:**

```hcl
# Your AWS region
aws_region = "us-east-1"

# Give your project a name
project_name = "my-project"

# EKS cluster name
cluster_name = "my-eks-cluster"

# Node Group - THE MOST IMPORTANT SECTION
# These control your worker node configuration

instance_type           = "t3.medium"     # EC2 instance type
node_group_min_size     = 2               # Minimum nodes (never go below)
node_group_max_size     = 5               # Maximum nodes (auto-scaling limit)
node_group_desired_size = 2               # Starting number of nodes
node_group_disk_size    = 20              # Disk size in GB per node
```

**Recommended Presets:**

- **Small Dev:** `instance_type = "t3.small"`, min=1, max=2, desired=1
- **Medium Dev:** `instance_type = "t3.medium"`, min=2, max=5, desired=2 (default)
- **Production:** `instance_type = "m5.large"`, min=3, max=10, desired=3

## Step 3: Initialize Terraform (1 minute)

```bash
terraform init
```

**Output:** You'll see Terraform downloads providers and initializes the working directory.

## Step 4: Review Plan (1 minute)

```bash
terraform plan
```

**What to check:**
- ✅ All resource counts are as expected
- ✅ No errors in the plan output
- ✅ Your node group parameters are correct

## Step 5: Create Infrastructure (15-20 minutes total, mostly waiting)

```bash
terraform apply
```

When prompted, type: `yes`

**What happens:**
1. VPC and networking resources are created (~2 min)
2. EKS cluster is created (~10 min)
3. Worker nodes launch (~5 min)
4. Nodes join the cluster (~3 min)

**Watch the progress** in the AWS Console:
- VPC Dashboard: See your VPC and subnets
- EC2 Dashboard: See your instances launching
- EKS Dashboard: See your cluster and nodes

## Step 6: Connect to Your Cluster (1 minute)

After `terraform apply` completes:

```bash
# Option 1: Use the terraform output command
terraform output configure_kubectl

# Option 2: Manual command (replace cluster-name and region)
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Verify connection
kubectl get nodes
```

You should see your worker nodes listed!

---

## Common Next Steps

### Scale Your Cluster

Edit `terraform.tfvars` to change node count:

```hcl
node_group_desired_size = 5  # Scale to 5 nodes
```

Then apply:

```bash
terraform apply
```

### Change Instance Type

Edit `terraform.tfvars`:

```hcl
instance_type = "m5.large"  # Upgrade from t3.medium
```

Then apply:

```bash
terraform apply
```

### Deploy Your First Application

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

### View Cluster Information

```bash
# Get cluster details
aws eks describe-cluster --name my-eks-cluster --region us-east-1

# Get kubeconfig
terraform output eks_cluster_endpoint

# Get certificate authority
terraform output eks_cluster_version
```

---

## Troubleshooting

### "Error: error acquiring the state lock"
**Solution:** Wait a moment and try again (another apply might be in progress)

### "Error: subnet does not have 'mapPublicIpOnLaunch' set"
**Solution:** This is automatic. Just ensure your AZ is correct in terraform.tfvars

### "Nodes not joining cluster"
**Solution:** 
```bash
# Check node status
kubectl get nodes -v=5
# Or check AWS console for instance health
```

### "terraform plan shows lots of changes unexpectedly"
**Solution:** 
```bash
# Check your terraform.tfvars for accidental changes
# Then revert if needed and try again
git checkout terraform.tfvars
```

### Can't connect with kubectl
**Solution:**
```bash
# Re-configure kubeconfig
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster --force
kubectl cluster-info
```

---

## Cleanup

To destroy everything and stop paying:

```bash
terraform destroy
```

When prompted, type: `yes`

**What gets deleted:**
- ✅ EKS cluster
- ✅ All worker nodes
- ✅ VPC and networking
- ✅ All IAM roles
- ✅ All security groups

**What doesn't get deleted:**
- ⚠️ CloudWatch logs (manual cleanup if needed)
- ⚠️ Elastic IPs if they were detached (manual cleanup if needed)

---

## Cost Estimation

**Using Default Settings (t3.medium, 2 nodes):**

| Component | Hourly | Monthly |
|-----------|--------|---------|
| EKS Cluster | $0.10 | $73 |
| 2 × t3.medium EC2 | $0.08 | $58 |
| NAT Gateway | $0.045 | $32 |
| **Total** | **$0.225** | **~$163** |

**Costs vary by:**
- Region (US-East-1 shown)
- Instance type selected
- Number of nodes
- Data transfer

---

## Useful Commands Reference

```bash
# Initialize project
terraform init

# View what will be created
terraform plan

# Create infrastructure
terraform apply

# Destroy infrastructure
terraform destroy

# View outputs
terraform output

# Get specific output
terraform output eks_cluster_id

# Refresh state
terraform refresh

# View current state
terraform state list
terraform state show module.vpc.aws_vpc.main

# Connect to cluster
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>

# Check nodes
kubectl get nodes

# Check all pods
kubectl get pods -A

# Check cluster info
kubectl cluster-info

# Describe a node
kubectl describe node <node-name>
```

---

## Need More Help?

- **Detailed Documentation:** See [README.md](README.md)
- **Architecture Details:** See [ARCHITECTURE.md](ARCHITECTURE.md)
- **User Input Guide:** See [USER_INPUTS.md](USER_INPUTS.md)
- **Terraform Docs:** https://www.terraform.io/docs
- **AWS EKS Guide:** https://docs.aws.amazon.com/eks/latest/userguide/
- **Kubernetes:** https://kubernetes.io/docs/

---

## Example: Complete Setup in One Go

```bash
# 1. Prepare
cp terraform.tfvars.example terraform.tfvars

# 2. Edit with production settings
cat > terraform.tfvars << 'EOF'
aws_region = "us-east-1"
project_name = "prod-api"
cluster_name = "prod-api-cluster"
instance_type = "m5.large"
node_group_min_size = 3
node_group_max_size = 10
node_group_desired_size = 3
node_group_disk_size = 50
EOF

# 3. Initialize and apply
terraform init
terraform apply  # Type 'yes' when prompted

# 4. Configure kubectl and verify
aws eks update-kubeconfig --region us-east-1 --name prod-api-cluster
kubectl get nodes

# Done! ✅
```

---

**Happy clustering! 🚀**
