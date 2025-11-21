output "guardrails" {
  description = "Map of guardrail information"
  value = {
    for k, v in aws_bedrock_guardrail.this : k => {
      guardrail_arn        = v.guardrail_arn
      guardrail_id         = v.guardrail_id
      guardrail_version    = v.version
      version_arn          = try(aws_bedrock_guardrail_version.this[k].version_arn, null)
      version_number       = try(aws_bedrock_guardrail_version.this[k].version, null)
      guardrail_identifier = "${v.guardrail_id}:${try(aws_bedrock_guardrail_version.this[k].version, "DRAFT")}"
    }
  }
}
