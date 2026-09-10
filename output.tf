output "cluster_id" {
  value       = aws_eks_cluster.trainerstacks.id
  description = "EKS Cluster ID"
}

output "cluster_name" {
  value       = aws_eks_cluster.trainerstacks.name
  description = "EKS Cluster Name"
}

output "cluster_arn" {
  value       = aws_eks_cluster.trainerstacks.arn
  description = "EKS Cluster ARN"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.trainerstacks.endpoint
  description = "EKS Cluster Endpoint"
}

output "cluster_version" {
  value       = aws_eks_cluster.trainerstacks.version
  description = "EKS Cluster Version"
}

output "node_group_id" {
  value       = aws_eks_node_group.trainerstacks.id
  description = "EKS Node Group ID"
}

output "node_group_status" {
  value       = aws_eks_node_group.trainerstacks.status
  description = "Status of the EKS Node Group"
}

output "vpc_id" {
  value       = aws_vpc.trainerstacks_vpc.id
  description = "VPC ID"
}

output "subnet_ids" {
  value       = aws_subnet.trainerstacks_subnet[*].id
  description = "List of Subnet IDs"
}

output "cluster_security_group_id" {
  value       = aws_security_group.trainerstacks_cluster_sg.id
  description = "Security Group ID for EKS Cluster"
}

output "node_security_group_id" {
  value       = aws_security_group.trainerstacks_node_sg.id
  description = "Security Group ID for EKS Nodes"
}

output "kubectl_config_command" {
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.trainerstacks.name} --region ap-south-1"
  description = "Command to configure kubectl for the cluster"
}

output "cluster_oidc_issuer_url" {
  value       = try(aws_eks_cluster.trainerstacks.identity[0].oidc[0].issuer, "")
  description = "OIDC Issuer URL for the cluster (for IRSA setup later)"
}
