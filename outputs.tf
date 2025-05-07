
output "public_ip_address" {
  description = "Indirizzo IP pubblico della VM"            # Descrizione dell'output
  value       = azurerm_public_ip.pip.ip_address            # IP ottenuto dalla risorsa pip
}

output "vm_name" {
  description = "Nome della macchina virtuale creata"       # Nome leggibile della VM
  value       = azurerm_linux_virtual_machine.vm.name       # Valore dalla risorsa VM
}
