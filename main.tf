
locals  {
    prefix = "${var.organisation}-${var.environment}-${var.application}-${var.tier}"
}
resource "azurerm_resource_group" "rg1" {
  name     = "${local.prefix}-${var.rgname}"
  location =  var.location
  tags = var.tagging
}
resource "azurerm_virtual_network" "vnett1" {
  name                = "${local.prefix}-${var.vnetname}"
  address_space       = var.address_space
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}
resource "azurerm_subnet" "subnet1" {
  name                 = "${local.prefix}-${var.subnetname}"
   address_prefixes     = var.address_prefixes
   resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnett1.name
}
resource "azurerm_network_interface" "nic" {
  name                = "${local.prefix}-${var.nicname}"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pipp.id
  }
    }
resource "azurerm_public_ip" "pipp" {
  name                = "${var.vnetname}-${var.pipname}"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Static"

  tags = var.tagging
  }
resource "azurerm_network_security_group" "nsg" {
  name                = "${local.prefix}-${var.nsg}"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 3389
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_virtual_machine" "main" {
  name                  = "${local.prefix}-${var.VMname}"
  location              = azurerm_resource_group.rg1.location
  resource_group_name   = azurerm_resource_group.rg1.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.vm_size
os_profile_windows_config{}

 delete_os_disk_on_termination = true

   delete_data_disks_on_termination = true
 storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  =  var.computer_name
    admin_username =  var.admin_username
    admin_password =  var.admin_password
  }

  tags = {
    environment = "staging"
  }
}