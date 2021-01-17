# Define variables
variable "tags" {
  type = object({
    Company     = string
    Environment = string
  })
  description = "Azure tags to apply to resources during creation."
}

variable "gw_name" {
  type        = string
  description = "Name for the virtual network gateway."
}

variable "gw_local_name" {
  type        = string
  description = "Name for the home and/or local network gateway."
}

variable "vpn_sku" {
  type        = string
  description = "Specify SKU to use for the VPN tunnel."
  default     = "VpnGw1"
}

variable "local_public_ip" {
  type        = string
  description = "Public IP address for home and/or local site."
}

variable "local_subnet_prefix" {
  type        = string
  description = "Local subnet prefix for home and/or local site."
}
