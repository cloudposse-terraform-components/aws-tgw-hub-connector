locals {
  enabled = module.this.enabled

  primary_tgw_hub_tenant      = length(var.primary_tgw_hub_tenant) > 0 ? var.primary_tgw_hub_tenant : module.this.tenant
  primary_tgw_hub_environment = length(var.primary_tgw_hub_environment) > 0 ? var.primary_tgw_hub_environment : module.this.environment
  primary_tgw_hub_stage       = length(var.primary_tgw_hub_stage) > 0 ? var.primary_tgw_hub_stage : module.this.stage
  # Try tenant-environment-stage format first (for test cases), then fall back to tenant-stage (for production)
  # full_account_map may be keyed by either format depending on configuration
  primary_tgw_hub_account_with_env    = local.enabled ? "${local.primary_tgw_hub_tenant}-${local.primary_tgw_hub_environment}-${local.primary_tgw_hub_stage}" : null
  primary_tgw_hub_account_without_env = local.enabled ? "${local.primary_tgw_hub_tenant}-${local.primary_tgw_hub_stage}" : null
  primary_tgw_hub_account_id = local.enabled ? try(
    module.account_map.outputs.full_account_map[local.primary_tgw_hub_account_with_env],
    module.account_map.outputs.full_account_map[local.primary_tgw_hub_account_without_env],
    null
  ) : null
}

# Connect two Transit Gateway Hubs across regions
resource "aws_ec2_transit_gateway_peering_attachment" "this" {
  count = local.enabled ? 1 : 0

  peer_account_id         = local.primary_tgw_hub_account_id
  peer_region             = var.primary_tgw_hub_region
  peer_transit_gateway_id = module.tgw_hub_primary_region.outputs.transit_gateway_id
  transit_gateway_id      = module.tgw_hub_this_region.outputs.transit_gateway_id

  tags = module.this.tags
}

# Accept the peering attachment in the primary region
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "primary_region" {
  count = local.enabled ? 1 : 0

  provider = aws.primary_tgw_hub_region

  transit_gateway_attachment_id = join("", aws_ec2_transit_gateway_peering_attachment.this[*].id)
  tags                          = module.this.tags
}

resource "aws_ec2_transit_gateway_route_table_association" "this_region" {
  count = local.enabled ? 1 : 0

  transit_gateway_attachment_id  = join("", aws_ec2_transit_gateway_peering_attachment.this[*].id)
  transit_gateway_route_table_id = module.tgw_hub_this_region.outputs.transit_gateway_route_table_id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.primary_region]
}

resource "aws_ec2_transit_gateway_route_table_association" "primary_region" {
  count = local.enabled ? 1 : 0

  provider = aws.primary_tgw_hub_region

  transit_gateway_attachment_id  = join("", aws_ec2_transit_gateway_peering_attachment.this[*].id)
  transit_gateway_route_table_id = module.tgw_hub_primary_region.outputs.transit_gateway_route_table_id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.primary_region]
}
