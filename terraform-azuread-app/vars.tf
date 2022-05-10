variable "vault_ui_redirect_address" {
  type        = string
  default     = "http://localhost:8200"
  description = "DNS hostname or IP address of Vault's UI."
}

variable "vault_cli_redirect_address" {
  type        = string
  default     = "http://localhost:8250"
  description = "DNS hostname or IP address of Vault's CLI."
}
