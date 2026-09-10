output "cluster_id" {
  value = aws_eks_cluster.trainerstacks.id
  description = "EKS Cluster ID"
}

output "cluster_name" {
  value = aws_eks_cluster.trainerstacks.name
  description = "EKS Cluster Name"
}

output "cluster_arn" {
  value = aws_eks_cluster.trainerstacks.arn
  description = "EKS Cluster ARN"
}

output "cluster_endpoint" {
  value = aws_eks_cluster.trainerstacks.endpoint
  description = "EKS Cluster Endpoint"
}

output "node_group_id" {
  value = aws_eks_node_group.trainerstacks.id
  description = "EKS Node Group ID"
}

output "vpc_id" {
  value = aws_vpc.trainerstacks_vpc.id
  description = "VPC ID"
}

output "subnet_ids" {
  value = aws_subnet.trainerstacks_subnet[*].id
  description = "Subnet IDs"
}

output "security_group_id" {
  value = data.aws_security_group.eks_project_sg.id
  description = "Security Group ID (eks_project_sg)"
}

output "kubectl_config_command" {
  value = "aws eks update-kubeconfig --name ${aws_eks_cluster.trainerstacks.name} --region ap-south-1"
  description = "Command to configure kubectl"
}
