locals {
  address = "${var.sub_domain}.${var.domain_name}"
}


resource "aws_api_gateway_domain_name" "dns" {
  for_each        = local.enabled && var.create_custom_domain && var.endpoint_type != "PRIVATE" ? toset([local.address]) : toset([])
  certificate_arn = var.certificate_arn
  domain_name     = each.value
  security_policy = var.security_policy
  endpoint_configuration {
    types = [var.endpoint_type]
  }
  tags = module.this.tags
}

resource "aws_route53_record" "dns" {
  for_each = local.enabled && var.create_custom_domain && var.endpoint_type != "PRIVATE" ? toset([local.address]) : toset([])
  zone_id  = var.zone_id
  name     = aws_api_gateway_domain_name.dns[each.value].domain_name
  type     = "A"

  alias {
    evaluate_target_health = true
    name                   = var.endpoint_type == "EDGE" ? aws_api_gateway_domain_name.dns[each.value].cloudfront_domain_name : aws_api_gateway_domain_name.dns[each.value].regional_domain_name
    zone_id                = var.endpoint_type == "EDGE" ? aws_api_gateway_domain_name.dns[each.value].cloudfront_zone_id : aws_api_gateway_domain_name.dns[each.value].regional_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "dns" {
  for_each    = local.enabled && var.create_custom_domain && var.endpoint_type != "PRIVATE" ? toset([local.address]) : toset([])
  api_id      = aws_api_gateway_rest_api.this[0].id
  stage_name  = aws_api_gateway_stage.this[0].stage_name
  domain_name = aws_api_gateway_domain_name.dns[each.value].domain_name
}
