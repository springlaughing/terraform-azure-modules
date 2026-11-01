# The cluster's own identity, created BEFORE the cluster, so its role on the
# subnet exists before AKS starts using the subnet.
resource "azurerm_user_assigned_identity" "this" {
  name                = "id-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Only with a custom subnet: AKS must be allowed to place nodes and
# load balancers in a subnet it didn't create.
resource "azurerm_role_assignment" "subnet_network_contributor" {
  count = var.custom_subnet == null ? 0 : 1

  scope                            = var.custom_subnet.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.name
  node_resource_group = "${var.resource_group_name}-nodes"
  tags                = var.tags

  kubernetes_version        = var.kubernetes_version
  automatic_upgrade_channel = var.automatic_upgrade_channel
  sku_tier                  = var.sku_tier

  # Needed later for workload identity (pods using Azure identities without secrets).
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name                        = "system"
    vm_size                     = var.node_vm_size
    node_count                  = var.node_count
    zones                       = var.zones
    os_disk_size_gb             = var.os_disk_size_gb
    vnet_subnet_id              = var.custom_subnet == null ? null : var.custom_subnet.id
    temporary_name_for_rotation = "systemtmp"

    upgrade_settings {
      max_surge = "1"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  # The role must exist before AKS touches the subnet.
  depends_on = [azurerm_role_assignment.subnet_network_contributor]
}