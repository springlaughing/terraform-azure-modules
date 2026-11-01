variable "vm_name" {
  description = "Name of the VM. The NIC and OS disk are named after it (nic-<vm_name>, osdisk-<vm_name>)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,62}[a-z0-9]$", var.vm_name))
    error_message = "vm_name must be 3-64 characters: lowercase letters, digits and hyphens, not ending with a hyphen."
  }
}

variable "resource_group_name" {
  description = "Name of the existing resource group to create the VM in."
  type        = string
}

variable "location" {
  description = "Azure region for the VM and its NIC."
  type        = string
}

variable "subnet_id" {
  description = "ID of the existing subnet the VM's network interface is placed in."
  type        = string
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Linux admin user created on the VM."
  type        = string
  default     = "azureuser"

  validation {
    condition     = !contains(["admin", "administrator", "root", "user", "guest", "test"], lower(var.admin_username))
    error_message = "admin_username is a name Azure reserves and rejects. Choose another, e.g. azureuser."
  }
}

variable "admin_ssh_public_key" {
  description = "SSH public key (OpenSSH format) allowed to log in as admin_username."
  type        = string

  validation {
    condition     = can(regex("^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp256) ", var.admin_ssh_public_key))
    error_message = "admin_ssh_public_key must be an OpenSSH public key, starting with ssh-ed25519, ssh-rsa or ecdsa-sha2-nistp256."
  }
}

variable "os_disk_type" {
  description = "Storage type of the OS disk."
  type        = string
  default     = "StandardSSD_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_type)
    error_message = "os_disk_type must be Standard_LRS, StandardSSD_LRS or Premium_LRS."
  }
}

variable "tags" {
  description = "Tags applied to every resource the module creates."
  type        = map(string)
  default     = {}
}