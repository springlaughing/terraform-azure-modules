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
  description = "Subnets to create, keyed by a short role name (e.g. frontend, backend). The key becomes part of the subnet and NSG names. Optional security_rules are added to that subnet's NSG."
  type = map(object({
    address_prefix = string
    security_rules = optional(list(object({
      name                    = string
      priority                = number
      source_address_prefix   = string
      destination_port_ranges = list(string)
      direction               = optional(string, "Inbound")
      access                  = optional(string, "Allow")
      protocol                = optional(string, "Tcp")
    })), [])
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

  validation {
    condition = alltrue(flatten([
      for subnet in values(var.subnets) : [
        for rule in subnet.security_rules : rule.priority >= 100 && rule.priority <= 4096
      ]
    ]))
    error_message = "Security rule priorities must be between 100 and 4096."
  }

  validation {
    condition = alltrue(flatten([
      for subnet in values(var.subnets) : [
        for rule in subnet.security_rules :
        contains(["Inbound", "Outbound"], rule.direction) &&
        contains(["Allow", "Deny"], rule.access) &&
        contains(["Tcp", "Udp", "Icmp", "*"], rule.protocol)
      ]
    ]))
    error_message = "direction must be Inbound/Outbound, access Allow/Deny, protocol Tcp/Udp/Icmp/*."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) :
      length(distinct([for rule in subnet.security_rules : rule.priority])) == length(subnet.security_rules)
    ])
    error_message = "Within one subnet, every security rule needs a different priority."
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