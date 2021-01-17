terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.39.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "servers_uscentral" {
  source = "./modules/server"

  bastion                   = true
  bastion_name              = "${var.bastion_name}-uscentral"
  server_rg_name            = "${var.server_rg_name}-uscentral"
  server_rg_location        = "centralus"
  server_vnet_name          = "${var.server_vnet_name}-uscentral"
  server_vnet_address_space = "10.20.0.0/16"
  server_vnet_subnets = {
    server_subnet      = "10.20.10.0/24"
    GatewaySubnet      = "10.20.255.0/24"
    AzureBastionSubnet = "10.20.172.0/24"
  }
  server_name_prefix    = "mc-server"
  server_nsg_allowed_ip = ""
  server_nsg_name       = ""
  server_count          = 1
  server_username       = var.server_username
  tags                  = var.tags
}

module "vpn_uscentral" { 
  source = "./modules/vpn"

  tags = var.tags
  gw_name = "mc-test-vpn-gw"
  gw_local_name = "mc-test-vpn-local-gw"
  vpn_sku = "VpnGw1"
  local_public_ip = "98.144.225.56"
  local_subnet_prefix = "10.10.10.0/24"
}