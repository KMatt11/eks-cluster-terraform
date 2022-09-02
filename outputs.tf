###### root/outputs.tf

output "cluster_name" {
  description = "K8scluster_name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "eks_cluster_endpoint"
  value       = module.eks.cluster_endpoint
}