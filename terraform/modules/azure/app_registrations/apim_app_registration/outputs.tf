output "pmp_clientId" {
  value = azuread_application.pmp_app_registration.application_id
  sensitive = true
}
output "pmp_secret" {
  value = azuread_application_password.pmp_secret.value
  sensitive = true
}

output "afmall_clientId" {
  value = azuread_application.afmall_app_registration.application_id
  sensitive = true
}
output "afmall_secret" {
  value = azuread_application_password.afmall_secret.value
  sensitive = true
}

output "sqa_clientId" {
  value = azuread_application.sqa_app_registration.application_id
  sensitive = true
}
output "sqa_secret" {
  value = azuread_application_password.sqa_secret.value
  sensitive = true
}

output "apim_clientId" {
  value = azuread_application.apim_app_registration.application_id
}