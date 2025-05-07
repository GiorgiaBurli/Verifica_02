
variable "resource_group_name" {
  description = "Nome del resource group Azure"             # Nome logico del gruppo risorse su Azure
  default     = "k3s-rg"                                    # Valore predefinito
}

variable "location" {
  description = "Regione Azure dove creare le risorse"      # Località geografica per le risorse
  default     = "East US"
}

variable "admin_username" {
  description = "Username dell'utente amministratore per SSH" # Nome utente usato nella VM
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_ed25519.pub"                         # Percorso della chiave pubblica per accesso SSH
}

variable "ssh_private_key_path" {
  default = "~/.ssh/id_ed25519"                             # Percorso della chiave privata (usata per autenticazione)
}
