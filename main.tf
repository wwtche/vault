module "application" {
  source                     = "./terraform-azuread-app"
  vault_ui_redirect_address  = "http://localhost:8200"
  vault_cli_redirect_address = "http://localhost:8250"
}

module "vault_config" {
  source          = "./terraform-vault-configuration"
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = module.application.application_id
  client_secret   = module.application.client_secret
}

output "display_name" {
  value = module.application.application_name
}

output "password" {
  value     = module.application.client_secret
  sensitive = true
}
