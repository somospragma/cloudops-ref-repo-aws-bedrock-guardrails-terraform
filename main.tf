resource "aws_bedrock_guardrail" "this" {
  provider = aws.project
  for_each = var.guardrails_config

  name                      = "${var.client}-${var.project}-${var.environment}-${each.key}-guardrail"
  description               = each.value.description
  blocked_input_messaging   = each.value.blocked_input_messaging
  blocked_outputs_messaging = each.value.blocked_outputs_messaging

  dynamic "content_policy_config" {
    for_each = each.value.content_policy_config != null ? [each.value.content_policy_config] : []
    content {
      dynamic "filters_config" {
        for_each = content_policy_config.value.filters_config
        content {
          input_strength  = filters_config.value.input_strength
          output_strength = filters_config.value.output_strength
          type            = filters_config.value.type
        }
      }
    }
  }

  dynamic "sensitive_information_policy_config" {
    for_each = each.value.sensitive_information_policy_config != null ? [each.value.sensitive_information_policy_config] : []
    content {
      dynamic "pii_entities_config" {
        for_each = sensitive_information_policy_config.value.pii_entities_config
        content {
          action = pii_entities_config.value.action
          type   = pii_entities_config.value.type
        }
      }

      dynamic "regexes_config" {
        for_each = sensitive_information_policy_config.value.regexes_config
        content {
          action      = regexes_config.value.action
          description = regexes_config.value.description
          name        = regexes_config.value.name
          pattern     = regexes_config.value.pattern
        }
      }
    }
  }

  dynamic "topic_policy_config" {
    for_each = each.value.topic_policy_config != null ? [each.value.topic_policy_config] : []
    content {
      dynamic "topics_config" {
        for_each = topic_policy_config.value.topics_config
        content {
          definition = topics_config.value.definition
          name       = topics_config.value.name
          type       = topics_config.value.type
          examples   = topics_config.value.examples
        }
      }
    }
  }

  dynamic "word_policy_config" {
    for_each = each.value.word_policy_config != null ? [each.value.word_policy_config] : []
    content {
      dynamic "managed_word_lists_config" {
        for_each = word_policy_config.value.managed_word_lists_config
        content {
          type = managed_word_lists_config.value.type
        }
      }

      dynamic "words_config" {
        for_each = word_policy_config.value.words_config
        content {
          text = words_config.value.text
        }
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.client}-${var.project}-${var.environment}-${each.key}-guardrail"
      Environment = var.environment
      Project     = var.project
      Client      = var.client
    },
    each.value.additional_tags
  )
}

resource "aws_bedrock_guardrail_version" "this" {
  provider = aws.project
  for_each = { for k, v in var.guardrails_config : k => v if v.create_version }

  guardrail_arn = aws_bedrock_guardrail.this[each.key].guardrail_arn
  description   = each.value.version_description
}
