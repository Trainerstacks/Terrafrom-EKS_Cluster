output "cluster_id" {
  value = aws_eks_cluster.trainerstacks.id
}

output "cluster_name" {
  value = aws_eks_cluster.trainerstacks.name
}

output "cluster_arn" {
  value = aws_eks_cluster.trainerstacks.arn
}

output "node_group_id" {
  value = aws_eks_node_group.trainerstacks.id
}

output "vpc_id" {
  value = aws_vpc.trainerstacks_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.trainerstacks_subnet[*].id
}

output "cluster_security_group_id" {
  value = aws_security_group.trainerstacks_cluster_sg.id
}

output "node_security_group_id" {
  value = aws_security_group.trainerstacks_node_sg.id
}
