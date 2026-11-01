# The virtual network: one per module call.
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# One subnet per entry in var.subnets.
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                            = "snet-${each.key}-${var.name_suffix}"
  resource_group_name             = var.resource_group_name
  virtual_network_name            = azurerm_virtual_network.this.name
  address_prefixes                = [each.value.address_prefix]
  default_outbound_access_enabled = var.default_outbound_access_enabled
}

# One network security group per subnet: no subnet without a firewall.
resource "azurerm_network_security_group" "this" {
  for_each = var.subnets

  name                = "nsg-${each.key}-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Attach each NSG to its subnet, matched by the same key.
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}