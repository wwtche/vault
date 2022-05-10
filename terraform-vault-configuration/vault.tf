# Auth Engines# ####################################################################################
####################################################################################################

resource "vault_jwt_auth_backend" "azure_oidc" {
  description        = "OIDC backend"
  oidc_discovery_url = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
  path               = "oidc"
  type               = "oidc"
  oidc_client_id     = var.client_id
  oidc_client_secret = var.client_secret
  default_role       = "azure"
}

resource "vault_jwt_auth_backend_role" "developers" {
  role_name              = "developer"
  backend                = vault_jwt_auth_backend.azure_oidc.path
  user_claim             = "email"
  groups_claim           = "groups"
  role_type              = "oidc"
  token_explicit_max_ttl = 3600
  oidc_scopes            = var.oidc_scopes
  allowed_redirect_uris  = var.allowed_redirect_uris
  token_policies = [
    "default",
    "developers",
  ]
}

resource "vault_jwt_auth_backend_role" "admins" {
  role_name              = "admin"
  backend                = vault_jwt_auth_backend.azure_oidc.path
  user_claim             = "email"
  groups_claim           = "groups"
  role_type              = "oidc"
  token_ttl              = 3600
  token_max_ttl          = 3600
  token_explicit_max_ttl = 3600
  oidc_scopes            = var.oidc_scopes
  allowed_redirect_uris  = var.allowed_redirect_uris
  token_policies = [
    "default",
    "admins",
  ]
}


# Policies #########################################################################################
####################################################################################################

resource "vault_policy" "admin_policy" {
  name   = "admins"
  policy = file("policies/admin_policy.hcl")
}

resource "vault_policy" "developer_policy" {
  name   = "developers"
  policy = file("policies/developer_policy.hcl")
}

resource "vault_policy" "operations_policy" {
  name   = "operations"
  policy = file("policies/operation_policy.hcl")
}


# Secret Engines# ####################################################################################
####################################################################################################

resource "vault_azure_secret_backend" "azure" {
  use_microsoft_graph_api = true
  subscription_id         = var.subscription_id
  tenant_id               = var.tenant_id
  client_id               = var.client_id
  client_secret           = var.client_secret
  environment             = "AzurePublicCloud"
}

resource "vault_azure_secret_backend_role" "generated_role" {
  backend = vault_azure_secret_backend.azure.path
  role    = "generated_role"
  ttl     = 3600
  max_ttl = 3600

  azure_roles {
    role_name = "Reader"
    scope     = "/subscriptions/${var.subscription_id}/resourceGroups/vault"
  }
}


# Mounts #########################################################################################
####################################################################################################

resource "vault_mount" "developers" {
  path        = "developers"
  type        = "kv-v2"
  description = "KV2 Secrets Engine for Developers."
}

resource "vault_mount" "operations" {
  path        = "operations"
  type        = "kv-v2"
  description = "KV2 Secrets Engine for Operations."
}


# Secrets ##########################################################################################
####################################################################################################

resource "vault_generic_secret" "developer_sample_data" {
  path = "${vault_mount.developers.path}/test_account"

  data_json = <<EOT
{
  "username": "foo",
  "password": "bar"
}
EOT
}
