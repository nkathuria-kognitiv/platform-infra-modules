####################################
# Outputs
####################################
output "private_key_name" { 
    value = local.private_key_name
}
output "public_key" { 
    value = tls_private_key.rsa_2048_key.public_key_openssh
}
output "keyvault_id" { 
    value = azurerm_key_vault_secret.keyvault_private_key.id
}
output "keyvault_secret_private_key_version" { 
    value = azurerm_key_vault_secret.keyvault_private_key.version
}
output "keyvault_secret_private_key_id" { 
    value = azurerm_key_vault_secret.keyvault_private_key.versionless_id
}
