# terraform-azure-modules

Reusable Terraform modules for Azure, used in my Ironhack DevOps labs.

## linux_vm

Creates one Ubuntu 24.04 Linux VM with its own network interface in an existing subnet.
SSH-key login only, Standard SSD OS disk by default, validated inputs.

```hcl
module "vm" {
  source = "git::https://github.com/springlaughing/terraform-azure-modules.git//linux_vm?ref=v1.0.0"

  vm_name              = "vm-example-dev"
  resource_group_name  = "rg-example-dev"
  location             = "germanywestcentral"
  subnet_id            = azurerm_subnet.example.id
  admin_ssh_public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}
```

Outputs: `vm_id`, `vm_name`, `private_ip_address`, `nic_id`.

## network_bundle

Creates one virtual network with any number of subnets (`for_each` over a map).
Every subnet gets its own network security group. Default outbound access is off by default.

```hcl
module "network" {
  source = "git::https://github.com/springlaughing/terraform-azure-modules.git//network_bundle?ref=v1.1.0"

  name_suffix         = "example-dev"
  resource_group_name = "rg-example-dev"
  location            = "germanywestcentral"
  address_space       = ["10.10.0.0/16"]
  subnets = {
    frontend = { address_prefix = "10.10.1.0/24" }
    backend  = { address_prefix = "10.10.2.0/24" }
  }
}
```

Outputs: `vnet_id`, `vnet_name`, `subnet_ids` (map by key), `nsg_ids` (map by key).
`subnet_ids` is available only after each subnet's NSG is attached.

### Security rules (since v1.2.0)

Each subnet can get extra rules in its NSG. Without `security_rules`, only Azure's
default rules apply (VNet and Azure Load Balancer allowed, internet denied).

```hcl
subnets = {
  aks = {
    address_prefix = "10.30.1.0/24"
    security_rules = [{
      name                    = "allow-http-https-from-internet"
      priority                = 100
      source_address_prefix   = "Internet"
      destination_port_ranges = ["80", "443"]
      # optional: direction = "Inbound", access = "Allow", protocol = "Tcp"
    }]
  }
}
```

Rules are authoritative: rules added to the NSG outside Terraform are removed on the next apply.

### Tests

```bash
cd network_bundle && terraform init && terraform test
```

Offline: the azurerm provider is mocked, nothing is created in Azure.