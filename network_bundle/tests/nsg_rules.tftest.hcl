# Offline tests: the azurerm provider is mocked, nothing is created in Azure.
# The mock invents random strings for computed values, but the provider still
# validates ID formats, so subnet and NSG IDs get realistic fake values.
mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-dev/providers/Microsoft.Network/virtualNetworks/vnet-test-dev/subnets/snet-test"
    }
  }

  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-dev/providers/Microsoft.Network/networkSecurityGroups/nsg-test"
    }
  }
}

variables {
  name_suffix         = "test-dev"
  resource_group_name = "rg-test-dev"
  location            = "germanywestcentral"
  address_space       = ["10.99.0.0/16"]
}

# v1.1.0 callers pass no security_rules: must still work, NSG has no rules.
# command = apply: security_rule is Optional+Computed, so with no rules
# configured it's only known after apply. The mock provider "applies"
# offline and returns an empty set for it.
run "subnet_without_rules_is_backwards_compatible" {
  command = apply

  variables {
    subnets = {
      app = { address_prefix = "10.99.1.0/24" }
    }
  }

  assert {
    condition     = length(azurerm_network_security_group.this["app"].security_rule) == 0
    error_message = "A subnet without security_rules must get an NSG without custom rules."
  }
}

# A web subnet with one rule: the rule must reach the NSG with its defaults.
run "rules_are_added_to_the_subnet_nsg" {
  command = plan

  variables {
    subnets = {
      web = {
        address_prefix = "10.99.2.0/24"
        security_rules = [{
          name                    = "allow-http-https"
          priority                = 100
          source_address_prefix   = "Internet"
          destination_port_ranges = ["80", "443"]
        }]
      }
    }
  }

  assert {
    condition     = length(azurerm_network_security_group.this["web"].security_rule) == 1
    error_message = "The web NSG must contain exactly one custom rule."
  }

  assert {
    condition     = one(azurerm_network_security_group.this["web"].security_rule).direction == "Inbound"
    error_message = "direction must default to Inbound."
  }
}

# Two rules with the same priority must be rejected by validation.
run "duplicate_priorities_are_rejected" {
  command = plan

  variables {
    subnets = {
      web = {
        address_prefix = "10.99.2.0/24"
        security_rules = [
          { name = "a", priority = 100, source_address_prefix = "Internet", destination_port_ranges = ["80"] },
          { name = "b", priority = 100, source_address_prefix = "Internet", destination_port_ranges = ["443"] },
        ]
      }
    }
  }

  expect_failures = [var.subnets]
}