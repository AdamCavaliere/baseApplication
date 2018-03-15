data "terraform_remote_state" "baseNetwork" {
  backend = "atlas"

  config {
    name = "azc/azure_baseNetwork"
  }
}

resource "azurerm_network_interface" "netint" {
  name                = "networkinterface-${count.index + 1}"
  location            = "${data.terraform_remote_state.baseNetwork.network_location}"
  resource_group_name = "${data.terraform_remote_state.baseNetwork.network_resourcegp}"
  count               = "${var.servercount}"

  ip_configuration {
    name                          = "ipconfig-${var.app_name}-${count.index + 1}"
    subnet_id                     = "${data.terraform_remote_state.baseNetwork.ProdApp_subnet}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "app_vm" {
  name                          = "${var.app_name}-vm-${count.index + 1}"
  location                      = "${data.terraform_remote_state.baseNetwork.network_location}"
  resource_group_name           = "${data.terraform_remote_state.baseNetwork.network_resourcegp}"
  network_interface_ids         = ["${element(azurerm_network_interface.netint.*.id, count.index)}"]
  vm_size                       = "Standard_DS1_v2"
  count                         = "${var.servercount}"
  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.app_name}-${count.index + 1}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "${var.environment}"
  }
}
