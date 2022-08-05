# See https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-swagger-extensions.html for additional
# configuration information.

variable "endpoint_type" {
  type        = string
  description = "The type of the endpoint. One of - EDGE, PRIVATE, REGIONAL"
  default     = "REGIONAL"

  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.endpoint_type)
    error_message = "Valid values for var: endpoint_type are (EDGE, REGIONAL, PRIVATE)."
  }
}

variable "logging_level" {
  type        = string
  description = "The logging level of the API. One of f- OFF, INFO, ERROR"
  default     = "INFO"

  validation {
    condition     = contains(["OFF", "INFO", "ERROR"], var.logging_level)
    error_message = "Valid values for var: logging_level are (OFF, INFO, ERROR)."
  }
}

variable "metrics_enabled" {
  description = "A flag to indicate whether to enable metrics collection."
  type        = bool
  default     = false
}

variable "xray_tracing_enabled" {
  description = "A flag to indicate whether to enable X-Ray tracing."
  type        = bool
  default     = false
}

variable "existing_api_gateway_rest_api" {
  description = "A flag to use existing api gateway rest api to apply the aws_api_gateway_rest_api_policy.this resource against."
  type        = string
  default     = ""
}

# See https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html for additional information
# on how to configure logging.
variable "access_log_format" {
  description = "The format of the access log file."
  type        = string
  default     = <<EOF
  {
	"requestTime": "$context.requestTime",
	"requestId": "$context.requestId",
	"httpMethod": "$context.httpMethod",
	"path": "$context.path",
	"resourcePath": "$context.resourcePath",
	"status": $context.status,
	"responseLatency": $context.responseLatency,
  "xrayTraceId": "$context.xrayTraceId",
  "integrationRequestId": "$context.integration.requestId",
	"functionResponseStatus": "$context.integration.status",
  "integrationLatency": "$context.integration.latency",
	"integrationServiceStatus": "$context.integration.integrationStatus",
  "authorizeResultStatus": "$context.authorize.status",
	"authorizerServiceStatus": "$context.authorizer.status",
	"authorizerLatency": "$context.authorizer.latency",
	"authorizerRequestId": "$context.authorizer.requestId",
  "ip": "$context.identity.sourceIp",
	"userAgent": "$context.identity.userAgent",
	"principalId": "$context.authorizer.principalId",
	"cognitoUser": "$context.identity.cognitoIdentityId",
  "user": "$context.identity.user"
}
  EOF
}

variable "path_parts" {
  type        = list(any)
  default     = []
  description = "The last path segment of this API resource."
}

variable "rest_api_policy" {
  description = "The IAM policy document for the API."
  type        = string
  default     = null
}

variable "gateway_responses" {
  description = "(Optional) - A list of objects that contain the API Gateway, Gateway Response for a REST API Gateway."
  type = list(object({
    response_type       = string
    status_code         = string
    response_templates  = list(any)
    response_parameters = list(any)
  }))
}

variable "models" {
  description = "(Optional) - A list of objects that contain the desired Models for a REST API Gateway."
  type = list(object({
    name                = optional(string)
    description         = optional(string)
    content_type        = optional(string)
    response_parameters = optional(string)
  }))
}


variable "private_link_target_arns" {
  type        = list(string)
  description = "A list of target ARNs for VPC Private Link"
  default     = []
}

variable "iam_tags_enabled" {
  type        = string
  description = "Enable/disable tags on IAM roles and policies"
  default     = true
}

variable "permissions_boundary" {
  type        = string
  default     = ""
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
}

variable "stage_name" {
  type        = string
  default     = ""
  description = "The name of the stage"
}

variable "aws_region" {
  description = "The AWS region (e.g. ap-southeast-2). Autoloaded from region.tfvars."
  type        = string
  default     = ""
}

variable "aws_account_id" {
  description = "The AWS account id of the provider being deployed to (e.g. 12345678). Autoloaded from account.tfvars."
  type        = string
  default     = ""
}

variable "aws_assume_role_arn" {
  description = "(Optional) - ARN of the IAM role when optionally connecting to AWS via assumed role. Autoloaded from account.tfvars."
  type        = string
  default     = ""
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

variable "security_policy" {
  default     = "TLS_1_2"
  description = "The Transport Layer Security (TLS) version + cipher suite for this DomainName. The valid values are TLS_1_0 and TLS_1_2. Must be configured to perform drift detection."
  type        = string
}

variable "description" {
  default     = "Managed by Terraform"
  type        = string
  description = "Description of the REST API. If importing an OpenAPI specification via the body argument, this corresponds to the info.description field. If the argument value is provided and is different than the OpenAPI value, the argument value will override the OpenAPI value."
}

variable "vpc_endpoint_ids" {
  default     = []
  description = "Set of VPC Endpoint identifiers. It is only supported for PRIVATE endpoint type."
  type        = list(any)
}
