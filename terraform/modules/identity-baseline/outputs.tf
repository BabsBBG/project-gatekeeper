output "odegaard_object_id" {
  value = azuread_user.martin_odegaard.object_id
}

output "rice_object_id" {
  value = azuread_user.declan_rice.object_id
}

output "saliba_object_id" {
  value = azuread_user.william_saliba.object_id
}

output "break_glass_group_id" {
  value = azuread_group.hlx_break_glass.object_id
}

output "hlx_it_admins_group_id" {
  value = azuread_group.hlx_it_admins.object_id
}

output "pls_legacy_group_id" {
  value = azuread_group.pls_legacy_users.object_id
}