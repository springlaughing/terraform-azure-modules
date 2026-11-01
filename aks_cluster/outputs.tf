output "cluster_name" {
  description = "Name of the AKS cluster (for az aks get-credentials)."
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_id" {
  description = "Azure resource ID of the cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

output "node_resource_group" {
  description = "Resource group AKS manages for nodes, disks and load balancers."
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "identity_principal_id" {
  description = "Principal ID of the cluster's user-assigned identity."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet identity (e.g. for AcrPull on a container registry)."
  value       = one(azurerm_kubernetes_cluster.this.kubelet_identity[*].object_id)
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL, for workload identity federation."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}