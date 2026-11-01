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
# Rules come from var.subnets[*].security_rules; without them, only
# Azure's default rules apply (VNet and load balancer allowed, internet denied).
resource "azurerm_network_security_group" "this" {
  for_each = var.subnets

  name                = "nsg-${each.key}-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = each.value.security_rules

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_port_ranges    = security_rule.value.destination_port_ranges
      destination_address_prefix = "*"
    }
  }
}

# Attach each NSG to its subnet, matched by the same key.
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}