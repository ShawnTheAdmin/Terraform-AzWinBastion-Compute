locals { 
  resource_group = data.terraform_remote_state.web.outputs.server_info.resource_group_info.name
  resource_group_loc = data.terraform_remote_state.web.outputs.server_info.resource_group_info.location
}

resource "azurerm_public_ip" "pip" {
  name                = "mc-vpn-pip"
  location            = local.resource_group_loc
  resource_group_name = local.resource_group
  allocation_method   = var.tags["Environment"] == "Production" ? "Static" : "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vngw" {
  name                = var.gw_name
  location            = local.resource_group_loc
  resource_group_name = local.resource_group

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = var.vpn_sku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.pip.id
    private_ip_address_allocation = azurerm_public_ip.pip.allocation_method
    subnet_id                     = data.terraform_remote_state.web.outputs.server_info.virtual_network_subnet_info.GatewaySubnet.id
  }
}

# Local network gateway configuration
resource "azurerm_local_network_gateway" "localvngw" {
  name                = var.gw_local_name
  resource_group_name = local.resource_group
  location            = local.resource_group_loc
  gateway_address     = var.local_public_ip
  address_space       = [var.local_subnet_prefix]
}

# Virtual network gateway connection
resource "azurerm_virtual_network_gateway_connection" "onpremise" {
  name                = "onpremise"
  location            = local.resource_group_loc
  resource_group_name = local.resource_group

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.localvngw.id

  shared_key = data.azurerm_key_vault_secret.shared_secret.value
}
