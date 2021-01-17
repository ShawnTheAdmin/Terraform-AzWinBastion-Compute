resource "azurerm_resource_group" "server_rg" {
  name     = "${var.server_rg_name}-rg"
  location = var.server_rg_location
}

resource "azurerm_virtual_network" "server_vnet" {
  name                = "${var.server_vnet_name}-vnet"
  address_space       = [var.server_vnet_address_space]
  location            = azurerm_resource_group.server_rg.location
  resource_group_name = azurerm_resource_group.server_rg.name
}

resource "azurerm_network_security_group" "nsgrdp" {
  name                = "${var.server_nsg_name}-nsg"
  location            = azurerm_resource_group.server_rg.location
  resource_group_name = azurerm_resource_group.server_rg.name
  tags                = var.tags
  count               = var.bastion == true ? 0 : 1

  security_rule {
    name                       = "AllowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.server_nsg_allowed_ip
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "subnet" {
  for_each = var.server_vnet_subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.server_rg.name
  virtual_network_name = azurerm_virtual_network.server_vnet.name
  address_prefixes     = [each.value]
}

resource "azurerm_subnet_network_security_group_association" "nsg2subnet" {
  subnet_id                 = azurerm_subnet.subnet["server_subnet"].id
  network_security_group_id = azurerm_network_security_group.nsgrdp[count.index].id
  count                     = var.bastion == true ? 0 : 1
}

resource "azurerm_public_ip" "public_ip" {
  name                = var.bastion == true ? "bastion-pip" : "${var.server_name_prefix}-${format("%02d", count.index)}-nic"
  resource_group_name = azurerm_resource_group.server_rg.name
  location            = azurerm_resource_group.server_rg.location
  tags                = var.tags
  count               = var.bastion == true ? 1 : 2
  sku                 = var.bastion == true ? "standard" : "basic"
  allocation_method   = var.bastion == true ? "Static" : "Dynamic"
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = var.bastion_name
  location            = azurerm_resource_group.server_rg.location
  resource_group_name = azurerm_resource_group.server_rg.name
  count               = var.bastion == true ? 1 : 0

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.public_ip[count.index].id
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.server_name_prefix}-${format("%02d", count.index)}-nic"
  location            = azurerm_resource_group.server_rg.location
  resource_group_name = azurerm_resource_group.server_rg.name
  count               = var.server_count

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet["server_subnet"].id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "${var.server_name_prefix}-${format("%02d", count.index)}"
  resource_group_name   = azurerm_resource_group.server_rg.name
  location              = azurerm_resource_group.server_rg.location
  size                  = "Standard_D2as_v4"
  count                 = var.server_count
  admin_username        = var.server_username
  admin_password        = data.azurerm_key_vault_secret.admin_password.value
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
