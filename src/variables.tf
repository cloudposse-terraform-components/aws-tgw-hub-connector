variable "region" {
  type        = string
  description = "AWS Region"
}

variable "env_naming_convention" {
  type        = string
  description = "The cloudposse/utils naming convention used to translate environment name to AWS region name. Options are `to_short` and `to_fixed`"
  default     = "to_short"

  validation {
    condition     = var.env_naming_convention != "to_short" || var.env_naming_convention != "to_fixed:"
    error_message = "`var.env_naming_convention` must be either `to_short` or `to_fixed`."
  }
}

variable "primary_tgw_hub_tenant" {
  type        = string
  description = "The name of the tenant where the primary Transit Gateway hub is deployed. Only used if tenants are deployed and defaults to `module.this.tenant`"
  default     = ""
}

variable "primary_tgw_hub_stage" {
  type        = string
  description = "The name of the stage where the primary Transit Gateway hub is deployed. Defaults to `module.this.stage`"
  default     = ""
}

variable "primary_tgw_hub_region" {
  type        = string
  description = "The name of the AWS region where the primary Transit Gateway hub is deployed. This value is used with `var.env_naming_convention` to determine the primary Transit Gateway hub's environment name."
}

variable "primary_tgw_hub_component_name" {
  type        = string
  description = "The component name of the primary tgw hub"
  default     = "tgw/hub"
}

variable "this_tgw_hub_component_name" {
  type        = string
  description = "The component name of this tgw hub"
  default     = "tgw/hub"
}

variable "account_map_environment_name" {
  type        = string
  description = "The name of the environment where `account_map` is provisioned"
  default     = "gbl"
}

variable "account_map_stage_name" {
  type        = string
  description = "The name of the stage where `account_map` is provisioned"
  default     = "root"
}

variable "account_map_tenant_name" {
  type        = string
  description = "The name of the tenant where `account_map` is provisioned"
  default     = "core"
}

variable "account_map_component_name" {
  type        = string
  description = "The name of the account-map component"
  default     = "account-map"
}

