# ── NAMED LOCATIONS ──────────────────────────────────────

resource "azuread_named_location" "helix_hq_london" {
  display_name = "Helix-HQ-London"
  country {
    countries_and_regions                 = ["GB"]
    include_unknown_countries_and_regions = false
  }
}

resource "azuread_named_location" "helix_noc_floor" {
  display_name = "Helix-NOC-Floor"
  ip {
    ip_ranges = ["10.10.1.0/24"]
    trusted   = true
  }
}

resource "azuread_named_location" "helix_field_ops" {
  display_name = "Helix-Field-Ops"
  country {
    countries_and_regions                 = ["GB", "NG"]
    include_unknown_countries_and_regions = false
  }
}

resource "azuread_named_location" "pulse_legacy_office" {
  display_name = "Pulse-Legacy-Office"
  country {
    countries_and_regions                 = ["GB"]
    include_unknown_countries_and_regions = false
  }
}

resource "azuread_named_location" "pulse_partner_network" {
  display_name = "Pulse-Partner-Network"
  ip {
    ip_ranges = ["10.20.1.0/24"]
    trusted   = false
  }
}

# ── CONDITIONAL ACCESS POLICIES ──────────────────────────

# CA001 — Require MFA: All Users (exclude break‑glass)
resource "azuread_conditional_access_policy" "ca001_require_mfa_all" {
  display_name = "CA001-RequireMFA-AllUsers"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]
      excluded_groups = [var.break_glass_group_id]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

# CA002 — Block Legacy Authentication
resource "azuread_conditional_access_policy" "ca002_block_legacy_auth" {
  display_name = "CA002-BlockLegacyAuth"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["exchangeActiveSync", "other"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

# CA003 — Sign-in Risk: High/Medium → MFA
resource "azuread_conditional_access_policy" "ca003_signin_risk" {
  display_name = "CA003-SignInRisk-RequireMFA"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
    sign_in_risk_levels = ["high", "medium"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }

  session_controls {
    sign_in_frequency        = 1
    sign_in_frequency_period = "hours"
  }
}

# CA004 — User Risk: High → Password Change
resource "azuread_conditional_access_policy" "ca004_user_risk" {
  display_name = "CA004-UserRisk-PasswordChange"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
    user_risk_levels = ["high"]
  }

  grant_controls {
    operator          = "AND"
    built_in_controls = ["mfa", "passwordChange"]
  }
}

# CA005 — Admin MFA + Restricted Session (targets HLX-IT-Admins)
resource "azuread_conditional_access_policy" "ca005_admin_mfa" {
  display_name = "CA005-RequireMFA-Admins"
  state        = "enabled"

  conditions {
    users {
      included_groups = [var.hlx_it_admins_group_id]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }

  session_controls {
    sign_in_frequency               = 4
    sign_in_frequency_period        = "hours"
    persistent_browser_session_mode = "never"
  }
}

# CA006 — Guest/Contractor Controls
resource "azuread_conditional_access_policy" "ca006_guest_controls" {
  display_name = "CA006-GuestContractor-Controls"
  state        = "enabled"

  conditions {
    users {
      included_guest_or_external_users {
        guest_or_external_user_types = ["b2bCollaborationGuest"]
        external_tenants {
          membership_kind = "all"
        }
      }
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }

  session_controls {
    sign_in_frequency               = 1
    sign_in_frequency_period        = "hours"
    persistent_browser_session_mode = "never"
  }
}

# CA007 — Pulse Partner Network
resource "azuread_conditional_access_policy" "ca007_pulse_partner" {
  display_name = "CA007-PulsePartner-MonitoredAccess"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
    locations {
      included_locations = [azuread_named_location.pulse_partner_network.id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }

  session_controls {
    sign_in_frequency               = 2
    sign_in_frequency_period        = "hours"
    persistent_browser_session_mode = "never"
  }
}