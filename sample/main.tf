############################################
#             Guardrails Resources         #
# Module development supported by Amazon Q #
############################################

module "bedrock_guardrails" {
  source = "../"

  providers = {
    aws.project = aws
  }

  client       = "pragma"
  project      = "jarvis"
  environment  = "dev"
  aws_role_arn = "arn:aws:iam::123456789012:role/deployment-role"
  aws_region   = "us-east-1"

  common_tags = {
    Environment = "dev"
    Project     = "jarvis"
    Client      = "pragma"
    ManagedBy   = "terraform"
  }

  guardrails_config = {
    "content-guardrail" = {
      description = "Guardrail for content moderation"

      content_policy_config = {
        filters_config = [
          {
            input_strength  = "HIGH"
            output_strength = "HIGH"
            type            = "SEXUAL"
          },
          {
            input_strength  = "HIGH"
            output_strength = "HIGH"
            type            = "VIOLENCE"
          }
        ]
      }

      sensitive_information_policy_config = {
        pii_entities_config = [
          {
            action = "BLOCK"
            type   = "EMAIL"
          }
        ]
        regexes_config = []
      }

      topic_policy_config = {
        topics_config = [
          {
            definition = "Investment advice"
            name       = "Investment Advice"
            type       = "DENY"
            examples   = ["What stocks should I buy?", "Give me investment tips"]
          }
        ]
      }

      word_policy_config = {
        managed_word_lists_config = [
          {
            type = "PROFANITY"
          }
        ]
        words_config = [
          {
            text = "badword"
          }
        ]
      }

      create_version      = true
      version_description = "Initial version"

      additional_tags = {
        Purpose = "content-moderation"
      }
    }
  }
}
