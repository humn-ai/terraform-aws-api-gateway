locals {
  address = "${var.sub_domain}.${var.domain_name}"
}


resource "aws_api_gateway_domain_name" "dns" {
  for_each        = local.enabled && var.create_custom_domain && var.endpoint_configuration != "PRIVATE" ? toset([local.address]) : toset([])
  certificate_arn = var.certificate_arn
  domain_name     = each.value
  security_policy = var.security_policy
  endpoint_configuration {
    types = [var.endpoint_configuration]
  }
  tags = module.this.tags
}

resource "aws_route53_record" "dns" {
  for_each = local.enabled && var.create_custom_domain && var.endpoint_configuration != "PRIVATE" ? toset([local.address]) : toset([])
  zone_id  = var.zone_id
  name     = aws_api_gateway_domain_name.dns[each.value].domain_name
  type     = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.dns[each.value].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.dns[each.value].cloudfront_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "dns" {
  count       = local.enabled && var.create_custom_domain && var.endpoint_configuration != "PRIVATE" ? 1 : 0
  api_id      = aws_api_gateway_rest_api.this[0].id
  stage_name  = aws_api_gateway_stage.this[0].stage_name
  domain_name = aws_api_gateway_domain_name.dns[each.value].domain_name
}

variable "create_custom_domain" {
  description = "Conditional trigger represented as a bool to create a custom DNS, default is 'false'."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "The ARN for an AWS-managed certificate. AWS Certificate Manager is the only supported source. Used when an edge-optimized domain name is desired."
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "The ID of the Route 53 Hosted Zone."
  type        = string
  default     = ""
}

variable "sub_domain" {
  description = "The subdomain of the api gateway."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "The fully-qualified domain name to register."
  type        = string
  default     = ""
}
