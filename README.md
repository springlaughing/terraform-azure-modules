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