terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

module "phase1_identity" {
  source           = "./modules/phase1-identity"
  tenant_domain    = var.tenant_domain
  initial_password = var.initial_password
}

module "phase2_ca" {
  source                 = "./modules/phase2-ca"
  tenant_domain          = var.tenant_domain
  break_glass_group_id   = module.phase1_identity.break_glass_group_id
  hlx_it_admins_group_id = module.phase1_identity.hlx_it_admins_group_id
}

module "phase3_pim" {
  source = "./modules/phase3-pim"

  odegaard_object_id = module.phase1_identity.odegaard_object_id
  rice_object_id     = module.phase1_identity.rice_object_id
  saliba_object_id   = module.phase1_identity.saliba_object_id
}

module "phase5_sentinel" {
  source          = "./modules/phase5-sentinel"
  subscription_id = var.subscription_id
  location        = var.location
  resource_group  = var.resource_group
}