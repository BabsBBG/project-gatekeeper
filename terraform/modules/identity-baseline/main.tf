# ── SECURITY GROUPS ──────────────────────────────────────

resource "azuread_group" "hlx_it_admins" {
  display_name            = "HLX-IT-Admins"
  security_enabled        = true
  assignable_to_role      = true
  description             = "Helix IT administrators — PIM eligible"
}

resource "azuread_group" "hlx_noc_engineers" {
  display_name     = "HLX-NOC-Engineers"
  security_enabled = true
  description      = "Helix NOC floor engineers"
}

resource "azuread_group" "hlx_corporate_staff" {
  display_name     = "HLX-Corporate-Staff"
  security_enabled = true
  description      = "Helix corporate workforce"
}

resource "azuread_group" "hlx_field_ops" {
  display_name     = "HLX-Field-Ops"
  security_enabled = true
  description      = "Helix field operations engineers"
}

resource "azuread_group" "hlx_break_glass" {
  display_name     = "HLX-Break-Glass"
  security_enabled = true
  description      = "Emergency access accounts — monitored"
}

resource "azuread_group" "hlx_pim_approvers" {
  display_name     = "HLX-PIM-Approvers"
  security_enabled = true
  description      = "PIM role activation approvers"
}

resource "azuread_group" "pls_legacy_users" {
  display_name     = "PLS-Legacy-Users"
  security_enabled = true
  description      = "Pulse Networks legacy users — migration group"
}

resource "azuread_group" "hlx_offboarding" {
  display_name     = "HLX-Offboarding"
  security_enabled = true
  description      = "Offboarding trigger group — leaver workflow"
}

resource "azuread_group" "hlx_new_joiners" {
  display_name     = "HLX-New-Joiners"
  security_enabled = true
  description      = "Joiner workflow trigger group"
}

# ── HELIX IT ADMINS ──────────────────────────────────────

resource "azuread_user" "martin_odegaard" {
  user_principal_name = "martin.odegaard@bbgseclab.onmicrosoft.com"
  display_name        = "Martin Odegaard (HLX)"
  mail_nickname       = "martin-odegaard"
  job_title           = "IT Administrator"
  department          = "IT Administration"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

resource "azuread_user" "declan_rice" {
  user_principal_name = "declan.rice@bbgseclab.onmicrosoft.com"
  display_name        = "Declan Rice (HLX)"
  mail_nickname       = "declan-rice"
  job_title           = "IT Administrator"
  department          = "IT Administration"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

resource "azuread_user" "william_saliba" {
  user_principal_name = "william.saliba@bbgseclab.onmicrosoft.com"
  display_name        = "William Saliba (HLX)"
  mail_nickname       = "william-saliba"
  job_title           = "IT Administrator"
  department          = "IT Administration"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

# ── HELIX NOC ENGINEERS ──────────────────────────────────

resource "azuread_user" "bukayo_saka" {
  user_principal_name = "bukayo.saka@bbgseclab.onmicrosoft.com"
  display_name        = "Bukayo Saka (HLX)"
  mail_nickname       = "bukayo-saka"
  job_title           = "NOC Engineer"
  department          = "Network Operations"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

resource "azuread_user" "gabriel_magalhaes" {
  user_principal_name = "gabriel.magalhaes@bbgseclab.onmicrosoft.com"
  display_name        = "Gabriel Magalhaes (HLX)"
  mail_nickname       = "gabriel-magalhaes"
  job_title           = "NOC Engineer"
  department          = "Network Operations"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

resource "azuread_user" "david_raya" {
  user_principal_name = "david.raya@bbgseclab.onmicrosoft.com"
  display_name        = "David Raya (HLX)"
  mail_nickname       = "david-raya"
  job_title           = "NOC Engineer"
  department          = "Network Operations"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

# ── HELIX CORPORATE STAFF ────────────────────────────────

resource "azuread_user" "jurrien_timber" {
  user_principal_name = "jurrien.timber@bbgseclab.onmicrosoft.com"
  display_name        = "Jurrien Timber (HLX)"
  mail_nickname       = "jurrien-timber"
  job_title           = "Business Analyst"
  department          = "Corporate"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

resource "azuread_user" "kai_havertz" {
  user_principal_name = "kai.havertz@bbgseclab.onmicrosoft.com"
  display_name        = "Kai Havertz (HLX)"
  mail_nickname       = "kai-havertz"
  job_title           = "Project Manager"
  department          = "Corporate"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

resource "azuread_user" "leandro_trossard" {
  user_principal_name = "leandro.trossard@bbgseclab.onmicrosoft.com"
  display_name        = "Leandro Trossard (HLX)"
  mail_nickname       = "leandro-trossard"
  job_title           = "Finance Analyst"
  department          = "Corporate"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

resource "azuread_user" "viktor_gyokeres" {
  user_principal_name = "viktor.gyokeres@bbgseclab.onmicrosoft.com"
  display_name        = "Viktor Gyokeres (HLX)"
  mail_nickname       = "viktor-gyokeres"
  job_title           = "Operations Manager"
  department          = "Corporate"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

# ── HELIX FIELD OPS ──────────────────────────────────────

resource "azuread_user" "gabriel_martinelli" {
  user_principal_name = "gabriel.martinelli@bbgseclab.onmicrosoft.com"
  display_name        = "Gabriel Martinelli (HLX)"
  mail_nickname       = "gabriel-martinelli"
  job_title           = "Field Operations Engineer"
  department          = "Field Operations"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

resource "azuread_user" "gabriel_jesus" {
  user_principal_name = "gabriel.jesus@bbgseclab.onmicrosoft.com"
  display_name        = "Gabriel Jesus (HLX)"
  mail_nickname       = "gabriel-jesus"
  job_title           = "Field Operations Engineer"
  department          = "Field Operations"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

# ── PULSE LEGACY USERS ───────────────────────────────────

resource "azuread_user" "pls_zinchenko" {
  user_principal_name = "pls-oleksandr.zinchenko@bbgseclab.onmicrosoft.com"
  display_name        = "Oleksandr Zinchenko (PLS)"
  mail_nickname       = "pls-oleksandr-zinchenko"
  job_title           = "Network Engineer"
  department          = "Pulse Networks [Legacy]"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = true
}

resource "azuread_user" "pls_kiwior" {
  user_principal_name = "pls-jakub.kiwior@bbgseclab.onmicrosoft.com"
  display_name        = "Jakub Kiwior (PLS)"
  mail_nickname       = "pls-jakub-kiwior"
  job_title           = "Network Engineer"
  department          = "Pulse Networks [Legacy]"
  usage_location      = "NG"
  account_enabled     = false
  password            = var.initial_password
  force_password_change = true
}

resource "azuread_user" "pls_nelson" {
  user_principal_name = "pls-reiss.nelson@bbgseclab.onmicrosoft.com"
  display_name        = "Reiss Nelson (PLS)"
  mail_nickname       = "pls-reiss-nelson"
  job_title           = "Systems Administrator"
  department          = "Pulse Networks [Legacy]"
  usage_location      = "NG"
  account_enabled     = false
  password            = var.initial_password
  force_password_change = true
}

resource "azuread_user" "pls_lokonga" {
  user_principal_name = "pls-albert.lokonga@bbgseclab.onmicrosoft.com"
  display_name        = "Albert Lokonga (PLS)"
  mail_nickname       = "pls-albert-lokonga"
  job_title           = "IT Support"
  department          = "Pulse Networks [Legacy]"
  usage_location      = "NG"
  account_enabled     = false
  password            = var.initial_password
  force_password_change = true
}

# ── BREAK-GLASS ACCOUNTS ─────────────────────────────────

resource "azuread_user" "bg_admin_01" {
  user_principal_name = "bg-01@bbgseclab.onmicrosoft.com"
  display_name        = "BG-Admin-01"
  mail_nickname       = "bg-01"
  job_title           = "Emergency Access Account"
  department          = "Security"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = false
}

resource "azuread_user" "bg_admin_02" {
  user_principal_name = "bg-02@bbgseclab.onmicrosoft.com"
  display_name        = "BG-Admin-02"
  mail_nickname       = "bg-02"
  job_title           = "Emergency Access Account"
  department          = "Security"
  usage_location      = "NG"
  account_enabled     = true
  password            = var.initial_password
  force_password_change = false
}

# ── GROUP MEMBERSHIPS ─────────────────────────────────────

resource "azuread_group_member" "odegaard_it_admins" {
  group_object_id  = azuread_group.hlx_it_admins.object_id
  member_object_id = azuread_user.martin_odegaard.object_id
}

resource "azuread_group_member" "rice_it_admins" {
  group_object_id  = azuread_group.hlx_it_admins.object_id
  member_object_id = azuread_user.declan_rice.object_id
}

resource "azuread_group_member" "saliba_it_admins" {
  group_object_id  = azuread_group.hlx_it_admins.object_id
  member_object_id = azuread_user.william_saliba.object_id
}

resource "azuread_group_member" "saka_noc" {
  group_object_id  = azuread_group.hlx_noc_engineers.object_id
  member_object_id = azuread_user.bukayo_saka.object_id
}

resource "azuread_group_member" "magalhaes_noc" {
  group_object_id  = azuread_group.hlx_noc_engineers.object_id
  member_object_id = azuread_user.gabriel_magalhaes.object_id
}

resource "azuread_group_member" "raya_noc" {
  group_object_id  = azuread_group.hlx_noc_engineers.object_id
  member_object_id = azuread_user.david_raya.object_id
}

resource "azuread_group_member" "timber_corporate" {
  group_object_id  = azuread_group.hlx_corporate_staff.object_id
  member_object_id = azuread_user.jurrien_timber.object_id
}

resource "azuread_group_member" "havertz_corporate" {
  group_object_id  = azuread_group.hlx_corporate_staff.object_id
  member_object_id = azuread_user.kai_havertz.object_id
}

resource "azuread_group_member" "trossard_corporate" {
  group_object_id  = azuread_group.hlx_corporate_staff.object_id
  member_object_id = azuread_user.leandro_trossard.object_id
}

resource "azuread_group_member" "gyokeres_corporate" {
  group_object_id  = azuread_group.hlx_corporate_staff.object_id
  member_object_id = azuread_user.viktor_gyokeres.object_id
}

resource "azuread_group_member" "martinelli_field" {
  group_object_id  = azuread_group.hlx_field_ops.object_id
  member_object_id = azuread_user.gabriel_martinelli.object_id
}

resource "azuread_group_member" "jesus_field" {
  group_object_id  = azuread_group.hlx_field_ops.object_id
  member_object_id = azuread_user.gabriel_jesus.object_id
}

resource "azuread_group_member" "zinchenko_pls" {
  group_object_id  = azuread_group.pls_legacy_users.object_id
  member_object_id = azuread_user.pls_zinchenko.object_id
}

resource "azuread_group_member" "kiwior_pls" {
  group_object_id  = azuread_group.pls_legacy_users.object_id
  member_object_id = azuread_user.pls_kiwior.object_id
}

resource "azuread_group_member" "nelson_pls" {
  group_object_id  = azuread_group.pls_legacy_users.object_id
  member_object_id = azuread_user.pls_nelson.object_id
}

resource "azuread_group_member" "lokonga_pls" {
  group_object_id  = azuread_group.pls_legacy_users.object_id
  member_object_id = azuread_user.pls_lokonga.object_id
}

resource "azuread_group_member" "bg01_breakglass" {
  group_object_id  = azuread_group.hlx_break_glass.object_id
  member_object_id = azuread_user.bg_admin_01.object_id
}

resource "azuread_group_member" "bg02_breakglass" {
  group_object_id  = azuread_group.hlx_break_glass.object_id
  member_object_id = azuread_user.bg_admin_02.object_id
}

resource "azuread_group_member" "timber_pim_approvers" {
  group_object_id  = azuread_group.hlx_pim_approvers.object_id
  member_object_id = azuread_user.jurrien_timber.object_id
}

resource "azuread_group_member" "havertz_pim_approvers" {
  group_object_id  = azuread_group.hlx_pim_approvers.object_id
  member_object_id = azuread_user.kai_havertz.object_id
}