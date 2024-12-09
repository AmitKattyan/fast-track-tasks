output "eks_cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
}

output "eks_vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "node_group_name" {
  value = aws_eks_node_group.eks_node_group.id
}
