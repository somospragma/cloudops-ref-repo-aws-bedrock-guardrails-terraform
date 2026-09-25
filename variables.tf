###########################################
#            Guardrails Module            #
###########################################

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to the resources"
}

variable "guardrails_config" {
  description = "Map of guardrail configurations"
  type = map(object({
    description               = optional(string)
    blocked_input_messaging   = optional(string, "Sorry, the model cannot provide a response to your request.")
    blocked_outputs_messaging = optional(string, "Sorry, the model cannot provide a response to your request.")

    content_policy_config = optional(object({
      filters_config = list(object({
        input_strength  = string
        output_strength = string
        type            = string
      }))
    }))

    sensitive_information_policy_config = optional(object({
      pii_entities_config = list(object({
        type           = string
        action         = string
        input_action   = optional(string)
        output_action  = optional(string)
        input_enabled  = optional(bool, true)
        output_enabled = optional(bool, true)
      }))
      regexes_config = list(object({
        name           = string
        description    = string
        pattern        = string
        action         = string
        input_action   = optional(string)
        output_action  = optional(string)
        input_enabled  = optional(bool, true)
        output_enabled = optional(bool, true)
      }))
    }))

    topic_policy_config = optional(object({
      topics_config = list(object({
        definition = string
        name       = string
        type       = string
        examples   = list(string)
      }))
    }))

    word_policy_config = optional(object({
      managed_word_lists_config = optional(list(object({
        type = string
      })), [])
      words_config = optional(list(object({
        text = string
      })), [])
    }))

    create_version      = optional(bool, false)
    version_description = optional(string)
    skip_destroy        = optional(bool, false)
    additional_tags     = optional(map(string), {})
  }))

  validation {
    condition = alltrue(flatten([
      for g in values(var.guardrails_config) : [
        for f in try(g.content_policy_config.filters_config, []) :
        contains(["NONE", "LOW", "MEDIUM", "HIGH"], f.input_strength) &&
        contains(["NONE", "LOW", "MEDIUM", "HIGH"], f.output_strength)
      ]
    ]))
    error_message = "content_policy_config filter strengths must be NONE, LOW, MEDIUM or HIGH."
  }

  validation {
    condition = alltrue(flatten([
      for g in values(var.guardrails_config) : concat(
        [for p in try(g.sensitive_information_policy_config.pii_entities_config, []) :
        contains(["BLOCK", "ANONYMIZE", "NONE"], p.action)],
        [for r in try(g.sensitive_information_policy_config.regexes_config, []) :
        contains(["BLOCK", "ANONYMIZE", "NONE"], r.action)]
      )
    ]))
    error_message = "pii_entities_config and regexes_config actions must be BLOCK, ANONYMIZE or NONE."
  }

  validation {
    condition = alltrue(flatten([
      for g in values(var.guardrails_config) : [
        for r in try(g.sensitive_information_policy_config.regexes_config, []) :
        length(r.pattern) <= 500
      ]
    ]))
    error_message = "A guardrail regex pattern is at most 500 characters."
  }
}



###########################################
#       Sistema de Etiquetado             #
###########################################

variable "client" {
  description = "Client name for resource naming and tagging"
  type        = string
}

variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name for resource naming and tagging"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "pdn", "prod"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn, prod."
  }
}

variable "aws_role_arn" {
  description = "AWS role ARN for cli execution"
  type        = string
}

variable "aws_region" {
  description = "AWS region for cli execution"
  type        = string
}
