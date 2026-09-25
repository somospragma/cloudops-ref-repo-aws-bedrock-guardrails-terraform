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
          # Simple form: `action` applies to both input and output.
          {
            action = "BLOCK"
            type   = "EMAIL"
          },
          # Per-side form (AWS provider >= 6.x): mask on output only, let it reach the model
          # on input. If input_action/output_action are omitted they fall back to `action`.
          {
            type          = "CREDIT_DEBIT_CARD_NUMBER"
            action        = "ANONYMIZE"
            input_action  = "NONE"
            output_action = "ANONYMIZE"
          }
        ]
        regexes_config = [
          {
            name          = "ACCOUNT_ID"
            description   = "Internal account identifier"
            pattern       = "ACC-[0-9]{6}"
            action        = "ANONYMIZE"
            input_action  = "NONE"
            output_action = "ANONYMIZE"
          }
        ]
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
      # Republish a new version on any policy change and keep older versions.
      skip_destroy = true

      additional_tags = {
        Purpose = "content-moderation"
      }
    }
  }
}
