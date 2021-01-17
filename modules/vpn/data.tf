data "azurerm_key_vault" "key_vault" {
  name                = "sharedsecretvault001"
  resource_group_name = "key-vault-rg"
}

data "azurerm_key_vault_secret" "shared_secret" {
  name         = "vpnSharedSecret"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "terraform_remote_state" "web" {
  backend = "azurerm"
  config = {
    resource_group_name  = "remote-state-rg"
    storage_account_name = "remotestatestor001"
    container_name       = "remotestate"
    key                  = "web.tfstate"
  }
}
