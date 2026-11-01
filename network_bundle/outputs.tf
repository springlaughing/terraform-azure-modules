output "vnet_id" {
  description = "Azure resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Subnet IDs, keyed like var.subnets (e.g. subnet_ids[\"backend\"]). Available only once the subnet's NSG is attached."
  value       = { for key, subnet in azurerm_subnet.this : key => subnet.id }

  # A subnet only counts as ready once its NSG is attached.
  depends_on = [azurerm_subnet_network_security_group_association.this]
}

output "nsg_ids" {
  description = "Network security group IDs, keyed like var.subnets."
  value       = { for key, nsg in azurerm_network_security_group.this : key => nsg.id }
}