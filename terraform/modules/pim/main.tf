# Get role templates
data "azuread_directory_role_template" "global_admin" {
  display_name = "Global Administrator"
}
data "azuread_directory_role_template" "security_admin" {
  display_name = "Security Administrator"
}
data "azuread_directory_role_template" "privileged_role_admin" {
  display_name = "Privileged Role Administrator"
}

# Activate directory roles
resource "azuread_directory_role" "global_admin" {
  template_id = data.azuread_directory_role_template.global_admin.object_id
}
resource "azuread_directory_role" "security_admin" {
  template_id = data.azuread_directory_role_template.security_admin.object_id
}
resource "azuread_directory_role" "privileged_role_admin" {
  template_id = data.azuread_directory_role_template.privileged_role_admin.object_id
}

# Eligible assignments
resource "azuread_directory_role_eligibility_schedule_request" "odegaard_ga" {
  role_definition_id = azuread_directory_role.global_admin.template_id
  principal_id       = var.odegaard_object_id
  directory_scope_id = "/"
  justification      = "Post-acquisition tenant management – Phase 3 PIM"
}

resource "azuread_directory_role_eligibility_schedule_request" "rice_sa" {
  role_definition_id = azuread_directory_role.security_admin.template_id
  principal_id       = var.rice_object_id
  directory_scope_id = "/"
  justification      = "Security operations – Phase 3 PIM"
}

resource "azuread_directory_role_eligibility_schedule_request" "saliba_pra" {
  role_definition_id = azuread_directory_role.privileged_role_admin.template_id
  principal_id       = var.saliba_object_id
  directory_scope_id = "/"
  justification      = "PIM governance – Phase 3 PIM"
}