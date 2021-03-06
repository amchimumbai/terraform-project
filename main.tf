

provider "azurerm" {
  features {}
}


# refer to a resource group
data "azurerm_resource_group" "test" {
  name = "SAN-SAP-CRM"
}

#refer to a subnet
data "azurerm_subnet" "test" {
  name                 = "subn-SAPSCS-NonProd-App"
  virtual_network_name = "VNet-SAN-SAPSCS-NonProd"
  resource_group_name  = "SAN-SAPSCS-NonProd-Net"
}

# Create public IPs






# create a network interface
resource "azurerm_network_interface" "test" {
  name                = "nic-test"
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = data.azurerm_subnet.test.id
    private_ip_address_allocation = "dynamic"

  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "test" {
  name                  = "myVM-test"
  location              = azurerm_network_interface.test.location
  resource_group_name   = data.azurerm_resource_group.test.name
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

}

