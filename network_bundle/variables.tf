variable "name_suffix" {
  description = "Suffix for all names: vnet-<suffix>, snet-<subnet key>-<suffix>, nsg-<subnet key>-<suffix>."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,40}[a-z0-9]$", var.name_suffix))
    error_message = "name_suffix must be 3-42 lowercase letters, digits or hyphens, not starting or ending with a hyphen."
  }
}

variable "resource_group_name" {
  description = "Name of the existing resource group for all network resources."
  type        = string
}

variable "location" {
  description = "Azure region for all network resources."
  type        = string
}

variable "address_space" {
  description = "Address ranges of the virtual network."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0 && alltrue([for cidr in var.address_space : can(cidrhost(cidr, 0))])
    error_message = "address_space must contain at least one valid CIDR range, like 10.10.0.0/16."
  }
}

variable "subnets" {
  description = "Subnets to create, keyed by a short role name (e.g. frontend, backend). The key becomes part of the subnet and NSG names."
  type = map(object({
    address_prefix = string
  }))

  validation {
    condition     = length(var.subnets) > 0
    error_message = "Define at least one subnet."
  }

  validation {
    condition     = alltrue([for key in keys(var.subnets) : can(regex("^[a-z][a-z0-9]{1,15}$", key))])
    error_message = "Subnet keys must be 2-16 lowercase letters or digits, starting with a letter (e.g. frontend)."
  }

  validation {
    condition     = alltrue([for subnet in values(var.subnets) : can(cidrhost(subnet.address_prefix, 0))])
    error_message = "Every subnet needs a valid address_prefix, like 10.10.1.0/24."
  }
}

variable "default_outbound_access_enabled" {
  description = "Whether VMs in these subnets get Azure's implicit default outbound IP. Off by default: Microsoft considers it insecure."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to every taggable resource the module creates."
  type        = map(string)
  default     = {}
}