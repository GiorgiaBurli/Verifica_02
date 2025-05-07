
provider "azurerm" {
  features {}
  subscription_id = "27aeb386-cfc9-4bb6-a602-33e0614dbf5a"  # ID della sottoscrizione Azure
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name                     # Nome del gruppo risorse
  location = var.location                                # Località geografica
}

resource "azurerm_virtual_network" "vnet" {
  name                = "k3s-vnet"                        # Nome della VNet
  address_space       = ["10.0.0.0/16"]                   # Intervallo IP della VNet
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name    # Collegamento al resource group
}

resource "azurerm_subnet" "subnet" {
  name                 = "k3s-subnet"                     # Nome della subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]                  # Intervallo IP della subnet
}

resource "azurerm_network_security_group" "nsg" {
  name                = "k3s-nsg"                         # Nome del NSG
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"               # Regola per SSH
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"              # Regola per porta 3000
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowK3sNodePort"       # Regola per porta 30080 (NodePort)
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id                    # Associazione NSG alla subnet
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "pip" {
  name                = "pip-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"            # IP statico
  sku                 = "Standard"          # SKU richiesto per IP pubblico statico
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-1"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"             # IP interno dinamico
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "k3s-vm"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B2s"                    # Tipo di VM
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)            # Percorso chiave pubblica
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "null_resource" "provision_k3s" {
  depends_on = [azurerm_linux_virtual_machine.vm]         # Esegue solo dopo creazione VM

  provisioner "file" {
    source      = "${path.module}/install_k3s.sh"         # Script locale da inviare
    destination = "/home/${var.admin_username}/install_k3s.sh"
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.pip.ip_address
      user        = var.admin_username
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.admin_username}/install_k3s.sh",        # Rende eseguibile
      "sudo /home/${var.admin_username}/install_k3s.sh"             # Esegue lo script
    ]
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.pip.ip_address
      user        = var.admin_username
      private_key = file(var.ssh_private_key_path)
    }
  }
}
