variable "name" {
  description = "Cluster name, e.g. aks-evgenia-k8s-dev. Also used for the DNS prefix, the identity and the node resource group."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,40}[a-z0-9]$", var.name))
    error_message = "name must be 3-42 lowercase letters, digits or hyphens, starting with a letter."
  }
}

variable "resource_group_name" {
  description = "Existing resource group for the cluster and its identity."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version (e.g. 1.36). AKS picks the newest patch; automatic_upgrade_channel keeps it patched."
  type        = string

  validation {
    condition     = can(regex("^1\\.[0-9]{2}$", var.kubernetes_version))
    error_message = "kubernetes_version must be a minor version like 1.36 (no patch number)."
  }
}

variable "automatic_upgrade_channel" {
  description = "How AKS upgrades the cluster by itself. 'patch' = newest patch of the chosen minor version."
  type        = string
  default     = "patch"

  validation {
    condition     = contains(["none", "patch", "stable", "rapid", "node-image"], var.automatic_upgrade_channel)
    error_message = "automatic_upgrade_channel must be none, patch, stable, rapid or node-image."
  }
}

variable "sku_tier" {
  description = "AKS tier: Free (no SLA), Standard (uptime SLA), Premium."
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Free, Standard or Premium."
  }
}

variable "node_count" {
  description = "Number of nodes in the system node pool."
  type        = number
  default     = 3

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "node_count must be between 1 and 10."
  }
}

variable "node_vm_size" {
  description = "VM size of the nodes."
  type        = string
  default     = "Standard_B2s"
}

variable "zones" {
  description = "Availability zones for the nodes. Empty list = no zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "os_disk_size_gb" {
  description = "OS disk size per node in GB."
  type        = number
  default     = 64
}

variable "custom_subnet" {
  description = "Existing subnet for the nodes ({ id = ... }). null = AKS creates its own VNet. With a subnet, the cluster identity gets Network Contributor on it."
  type = object({
    id = string
  })
  default = null
}

variable "pod_cidr" {
  description = "Overlay range for pod IPs. Must not overlap the VNet or service_cidr."
  type        = string
  default     = "192.168.0.0/16"
}

variable "service_cidr" {
  description = "Range for Kubernetes Service IPs. Must not overlap the VNet or pod_cidr."
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "IP of the cluster DNS service. Must be inside service_cidr."
  type        = string
  default     = "172.16.0.10"
}

variable "tags" {
  description = "Tags for the cluster and its identity."
  type        = map(string)
  default     = {}
}