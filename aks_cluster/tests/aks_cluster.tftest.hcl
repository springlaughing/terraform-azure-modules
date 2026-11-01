# Offline tests: azurerm is mocked, nothing is created in Azure.
mock_provider "azurerm" {
  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-dev/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-aks-test-dev"
      principal_id = "11111111-1111-1111-1111-111111111111"
    }
  }

  # Real AKS clusters always have exactly one kubelet identity; the mock
  # would return an empty list, so it gets one realistic entry.
  mock_resource "azurerm_kubernetes_cluster" {
    override_during = plan

    defaults = {
      kubelet_identity = [{
        client_id                 = "22222222-2222-2222-2222-222222222222"
        object_id                 = "33333333-3333-3333-3333-333333333333"
        user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-dev-nodes/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aks-test-dev-agentpool"
      }]
    }
  }
}

variables {
  name                = "aks-test-dev"
  resource_group_name = "rg-test-dev"
  location            = "germanywestcentral"
  kubernetes_version  = "1.36"
}

# Without a custom subnet: AKS creates its own VNet, no role assignment.
run "managed_vnet_has_no_role_assignment" {
  command = plan

  assert {
    condition     = length(azurerm_role_assignment.subnet_network_contributor) == 0
    error_message = "Without custom_subnet there must be no role assignment."
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].vnet_subnet_id == null
    error_message = "Without custom_subnet the node pool must not reference a subnet."
  }
}

# With a custom subnet: exactly one Network Contributor role on that subnet.
run "custom_subnet_gets_network_contributor" {
  command = plan

  variables {
    custom_subnet = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-dev/providers/Microsoft.Network/virtualNetworks/vnet-test-dev/subnets/snet-aks-test-dev"
    }
  }

  assert {
    condition     = length(azurerm_role_assignment.subnet_network_contributor) == 1
    error_message = "With custom_subnet there must be exactly one role assignment."
  }

  assert {
    condition     = azurerm_role_assignment.subnet_network_contributor[0].role_definition_name == "Network Contributor"
    error_message = "The role must be Network Contributor."
  }
}

# A full version number is rejected: only minor versions are allowed.
run "patch_version_is_rejected" {
  command = plan

  variables {
    kubernetes_version = "1.36.5"
  }

  expect_failures = [var.kubernetes_version]
}