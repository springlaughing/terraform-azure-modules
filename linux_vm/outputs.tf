output "vm_id" {
  description = "Azure resource ID of the VM."
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "Name of the VM."
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "Private IP address of the VM's network interface."
  value       = azurerm_network_interface.this.private_ip_address
}

output "nic_id" {
  description = "Azure resource ID of the VM's network interface."
  value       = azurerm_network_interface.this.id
}