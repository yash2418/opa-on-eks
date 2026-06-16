resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-${var.node_group_name}"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.private_subnet_ids
  version         = var.kubernetes_version

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  instance_types = [var.instance_type]
  disk_size      = var.disk_size

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-${var.node_group_name}-node-group"
      Environment = var.environment
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
    aws_iam_role_policy_attachment.eks_ssm_managed_instance_core,
  ]

  tags_all = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-${var.node_group_name}-node-group"
      Environment = var.environment
    }
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
}
