output "guardrail_info" {
  description = "Information about the created guardrails"
  value       = module.bedrock_guardrails.guardrails
}