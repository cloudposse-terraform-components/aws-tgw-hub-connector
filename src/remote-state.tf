locals {
  primary_tgw_hub_environment = module.utils.region_az_alt_code_maps[var.env_naming_convention][var.primary_tgw_hub_region]
}

# Used to translate region to environment
module "utils" {
  source  = "cloudposse/utils/aws"
  version = "1.4.0"
  enabled = local.enabled
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.8.0"

  component   = var.account_map_component_name
  environment = var.account_map_environment_name
  stage       = var.account_map_stage_name
  tenant      = var.account_map_tenant_name

  context = module.this.context
}

module "tgw_hub_this_region" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.8.0"

  component = var.this_tgw_hub_component_name

  context = module.this.context
}

module "tgw_hub_primary_region" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.8.0"

  component   = var.primary_tgw_hub_component_name
  stage       = local.primary_tgw_hub_stage
  environment = local.primary_tgw_hub_environment
  tenant      = local.primary_tgw_hub_tenant

  context = module.this.context
}
