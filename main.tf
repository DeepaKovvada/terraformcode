provider "azurerm" {
  features {}

  subscription_id = "9e04de8c-d344-4b9d-9da1-606e614944df"
  client_id       = "35b0341a-cbf8-4e79-ad34-e9b98bc2d7db"
  client_secret   = "LHM8Q~ipunK2HaBWgbBwTVAd-wwOAWhjCCsg6b5T"
  tenant_id       = "b4edbf0a-eecd-4b80-8486-28231a271593"
}

resource "azurerm_resource_group" "rg"{
    name = "diskrg"
    location = "west US"
    tags = {
        env = "test"
  }
}
resource "azurerm_managed_disk" "rg"{
    name = "disk1"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
     storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    environment = "staging"
  }
}