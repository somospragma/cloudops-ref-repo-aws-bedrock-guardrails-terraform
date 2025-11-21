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
        action = string
        type   = string
      }))
      regexes_config = list(object({
        action      = string
        description = string
        name        = string
        pattern     = string
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
    additional_tags     = optional(map(string), {})
  }))
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
