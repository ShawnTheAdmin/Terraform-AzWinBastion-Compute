// Define variables

/* Bool value that specifies whether or not to use a Bastion host. 
If this is True, Bastion host gets created along with 1 public IP.
If this is False, Bastion host does not get created. Servers are each created with a public IP and NSGs allowing 3389.*/

variable "bastion" {
  type        = bool
  default     = true
  description = "Defines whether or not a Bastion host is used."
  validation {
    condition     = can(regex("(true|false)", var.bastion))
    error_message = "The variable bastion must be true or false."
  }
}

variable "bastion_name" {
  type        = string
  description = "Name for the Bastion host."
}

variable "server_rg_name" {
  type        = string
  description = "Name for resource group."
}

variable "server_vnet_name" {
  type        = string
  description = "Name for virtual network."
}

// BEGIN COMMENT: NSG is only used if bastion is set to FALSE
variable "server_nsg_name" {
  type        = string
  description = "NSG associated with the created VNET"
}

variable "server_nsg_allowed_ip" {
  type        = string
  description = "IP the NSG will allow TCP 3389 to connect on"
  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\/([1-9]|1[0-9]|2[0-9]|3[1-2]{1,2})$", var.server_nsg_allowed_ip))
    error_message = "Value must be a valid IP address and mask. Example: 98.104.211.11/32."
  }
}
// END COMMENT

variable "server_name_prefix" {
  type        = string
  description = "Name for virtual network."
}

variable "server_count" {
  type = number
}

variable "server_username" {
  type = string
}
variable "tags" {
  type = map
}
