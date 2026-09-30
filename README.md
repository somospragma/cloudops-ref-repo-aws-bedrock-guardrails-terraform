# Documentación del Módulo AWS Bedrock Guardrails Terraform

## Descripción

Este módulo de Terraform permite crear y gestionar **AWS Bedrock Guardrails** de manera escalable y configurable. Los Guardrails de Amazon Bedrock proporcionan controles de seguridad y moderación de contenido para aplicaciones de IA generativa, permitiendo filtrar contenido inapropiado, proteger información sensible, restringir temas específicos y aplicar filtros de palabras.

El módulo está diseñado para soportar múltiples guardrails simultáneamente mediante una configuración basada en mapas, facilitando la gestión de diferentes políticas de moderación según los requisitos específicos de cada aplicación.

## Características Principales

- **Gestión Multi-Guardrail**: Soporte para crear múltiples guardrails con configuraciones independientes
- **Políticas de Contenido**: Filtrado de contenido sexual, violento, odio y acoso
- **Protección de Información Sensible**: Detección y bloqueo de PII (información personal identificable)
- **Control de Temas**: Restricción de temas específicos mediante definiciones personalizadas
- **Filtrado de Palabras**: Listas de palabras gestionadas y personalizadas
- **Acciones PII/Regex por lado**: Control independiente de entrada y salida (`input_action`, `output_action`, `input_enabled`, `output_enabled`), permitiendo, por ejemplo, que un dato llegue al modelo en la entrada y se enmascare solo en la salida
- **Republicación Automática de Versiones**: Al cambiar cualquier política se publica una nueva versión; las anteriores se conservan mediante `skip_destroy`
- **Etiquetado Consistente**: Sistema de etiquetado estandarizado con nomenclatura corporativa
- **Configuración Flexible**: Parámetros opcionales con valores por defecto sensatos y retrocompatibles

## Estructura del Módulo

```
cloudops-ref-repo-aws-bedrock-guardrails-terraform/
├── main.tf              # Recursos principales del módulo
├── variables.tf         # Definición de variables de entrada
├── outputs.tf           # Valores de salida del módulo
├── providers.tf         # Configuración de providers requeridos
├── README.md           # Documentación básica
├── DOCUMENTATION.md    # Documentación completa (este archivo)
├── .gitignore          # Archivos excluidos del control de versiones
└── sample/             # Ejemplos de implementación
    ├── main.tf         # Ejemplo de uso del módulo
    ├── providers.tf    # Provider AWS y required_providers del ejemplo
    └── outputs.tf      # Outputs del ejemplo
```

## Implementación y Configuración

### Requisitos Previos

- **Terraform**: >= 1.0
- **AWS Provider**: >= 6.24 (los atributos por lado `input_action`/`output_action`/`input_enabled`/`output_enabled` requieren el provider AWS 6.x)
- **Permisos AWS**: Acceso a Amazon Bedrock y capacidad de crear guardrails
- **Región AWS**: Región que soporte Amazon Bedrock

### Configuración Básica

```hcl
module "bedrock_guardrails" {
  source = "path/to/module"

  providers = {
    aws.project = aws
  }

  client       = "mi-empresa"
  project      = "mi-proyecto"
  environment  = "dev"
  aws_role_arn = "arn:aws:iam::123456789012:role/deployment-role"
  aws_region   = "us-east-1"

  common_tags = {
    Environment = "dev"
    Project     = "mi-proyecto"
    Client      = "mi-empresa"
    ManagedBy   = "terraform"
  }

  guardrails_config = {
    "content-filter" = {
      description = "Filtro de contenido básico"
      
      content_policy_config = {
        filters_config = [
          {
            input_strength  = "HIGH"
            output_strength = "HIGH"
            type            = "SEXUAL"
          }
        ]
      }
      
      create_version = true
      version_description = "Versión inicial"
    }
  }
}
```

## Tabla de Parámetros

### Variables de Entrada

| Parámetro | Tipo | Descripción | Requerido | Valor por Defecto |
|-----------|------|-------------|-----------|-------------------|
| `client` | `string` | Nombre del cliente para nomenclatura y etiquetado | ✅ | - |
| `project` | `string` | Nombre del proyecto para nomenclatura y etiquetado | ✅ | - |
| `environment` | `string` | Entorno de despliegue (dev, qa, pdn, prod) | ✅ | - |
| `aws_role_arn` | `string` | ARN del rol AWS para ejecución | ✅ | - |
| `aws_region` | `string` | Región AWS para ejecución | ✅ | - |
| `common_tags` | `map(string)` | Etiquetas comunes aplicadas a todos los recursos | ✅ | - |
| `guardrails_config` | `map(object)` | Configuración de guardrails (ver estructura detallada) | ✅ | - |

### Estructura de `guardrails_config`

```hcl
guardrails_config = {
  "nombre-guardrail" = {
    description               = string           # Descripción del guardrail
    blocked_input_messaging   = string           # Mensaje para entradas bloqueadas
    blocked_outputs_messaging = string           # Mensaje para salidas bloqueadas
    kms_key_arn               = optional(string)  # ARN de llave KMS custom (CMK). Si se omite, usa la llave gestionada por AWS
    
    content_policy_config = {
      filters_config = [
        {
          input_strength  = string  # LOW, MEDIUM, HIGH
          output_strength = string  # LOW, MEDIUM, HIGH
          type           = string   # SEXUAL, VIOLENCE, HATE, INSULTS, MISCONDUCT
        }
      ]
    }
    
    sensitive_information_policy_config = {
      pii_entities_config = [
        {
          type           = string           # EMAIL, PHONE, SSN, etc.
          action         = string           # BLOCK, ANONYMIZE, NONE
          input_action   = optional(string) # Opcional; por defecto toma `action`
          output_action  = optional(string) # Opcional; por defecto toma `action`
          input_enabled  = optional(bool)   # Opcional; por defecto true
          output_enabled = optional(bool)   # Opcional; por defecto true
        }
      ]
      regexes_config = [
        {
          name           = string
          description    = string
          pattern        = string           # Máximo 500 caracteres
          action         = string           # BLOCK, ANONYMIZE, NONE
          input_action   = optional(string) # Opcional; por defecto toma `action`
          output_action  = optional(string) # Opcional; por defecto toma `action`
          input_enabled  = optional(bool)   # Opcional; por defecto true
          output_enabled = optional(bool)   # Opcional; por defecto true
        }
      ]
    }
    
    topic_policy_config = {
      topics_config = [
        {
          definition = string
          name       = string
          type       = string      # DENY
          examples   = list(string)
        }
      ]
    }
    
    word_policy_config = {
      managed_word_lists_config = [
        {
          type = string  # PROFANITY
        }
      ]
      words_config = [
        {
          text = string
        }
      ]
    }
    
    create_version      = bool           # Publica una versión del guardrail
    version_description = string
    skip_destroy        = bool           # Conserva versiones anteriores al republicar (por defecto false)
    additional_tags     = map(string)
  }
}
```

> **Nota sobre acciones por lado**: `input_action`/`output_action` permiten aplicar acciones distintas a la entrada y a la salida. Si se omiten, ambas heredan el valor de `action` (comportamiento retrocompatible). Un caso típico: `input_action = "NONE"` y `output_action = "ANONYMIZE"` deja que el dato llegue al modelo pero lo enmascara en la respuesta.

> **Nota sobre versionado**: cuando `create_version = true`, cualquier cambio en la política del guardrail publica una nueva versión (vía `replace_triggered_by`). Con `skip_destroy = true`, las versiones anteriores se conservan en AWS aunque Terraform deje de gestionarlas.

### Variables de Salida

| Output | Descripción |
|--------|-------------|
| `guardrails` | Mapa con información completa de todos los guardrails creados |
| `guardrails[key].guardrail_arn` | ARN del guardrail |
| `guardrails[key].guardrail_id` | ID único del guardrail |
| `guardrails[key].guardrail_version` | Versión del guardrail |
| `guardrails[key].version_arn` | ARN de la versión específica |
| `guardrails[key].version_number` | Número de versión |
| `guardrails[key].guardrail_identifier` | Identificador completo (ID:VERSION) |

## Ejemplos de Uso

### Ejemplo 1: Guardrail Básico de Contenido

```hcl
guardrails_config = {
  "basic-content" = {
    description = "Filtro básico de contenido inapropiado"
    
    content_policy_config = {
      filters_config = [
        {
          input_strength  = "MEDIUM"
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
    
    create_version = true
    version_description = "Filtro básico v1.0"
  }
}
```

### Ejemplo 2: Guardrail Completo con Múltiples Políticas

```hcl
guardrails_config = {
  "comprehensive-filter" = {
    description = "Guardrail completo con todas las políticas"
    
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
        },
        {
          input_strength  = "MEDIUM"
          output_strength = "HIGH"
          type            = "HATE"
        }
      ]
    }
    
    sensitive_information_policy_config = {
      pii_entities_config = [
        {
          action = "BLOCK"
          type   = "EMAIL"
        },
        {
          action = "ANONYMIZE"
          type   = "PHONE"
        }
      ]
      regexes_config = [
        {
          action      = "BLOCK"
          description = "Números de tarjeta de crédito"
          name        = "credit-card"
          pattern     = "\\b\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}\\b"
        }
      ]
    }
    
    topic_policy_config = {
      topics_config = [
        {
          definition = "Consejos de inversión financiera"
          name       = "Investment Advice"
          type       = "DENY"
          examples   = [
            "¿Qué acciones debería comprar?",
            "Dame consejos de inversión"
          ]
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
          text = "palabra-prohibida"
        }
      ]
    }
    
    create_version = true
    version_description = "Guardrail completo v1.0"
    
    additional_tags = {
      Purpose = "comprehensive-filtering"
      Level   = "enterprise"
    }
  }
}
```

### Ejemplo 3: Múltiples Guardrails para Diferentes Casos de Uso

```hcl
guardrails_config = {
  "customer-service" = {
    description = "Guardrail para servicio al cliente"
    
    content_policy_config = {
      filters_config = [
        {
          input_strength  = "MEDIUM"
          output_strength = "HIGH"
          type            = "HATE"
        }
      ]
    }
    
    sensitive_information_policy_config = {
      pii_entities_config = [
        {
          action = "ANONYMIZE"
          type   = "EMAIL"
        }
      ]
      regexes_config = []
    }
    
    create_version = true
    version_description = "Versión para atención al cliente"
  },
  
  "content-creation" = {
    description = "Guardrail para creación de contenido"
    
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
    
    word_policy_config = {
      managed_word_lists_config = [
        {
          type = "PROFANITY"
        }
      ]
      words_config = []
    }
    
    create_version = false
  }
}
```

## Escenarios de Uso Comunes

### 1. Aplicaciones de Atención al Cliente
- **Filtrado de contenido ofensivo**: Prevenir respuestas inapropiadas
- **Protección de PII**: Anonimizar información personal en conversaciones
- **Control de temas**: Evitar consejos legales o médicos no autorizados

### 2. Plataformas de Creación de Contenido
- **Moderación automática**: Filtrar contenido sexual o violento
- **Cumplimiento normativo**: Adherirse a políticas de contenido
- **Protección de marca**: Evitar asociaciones negativas

### 3. Aplicaciones Educativas
- **Contenido apropiado para la edad**: Filtros específicos por grupo etario
- **Prevención de acoso**: Detección de lenguaje intimidatorio
- **Protección de menores**: Bloqueo de contenido inapropiado

### 4. Aplicaciones Empresariales
- **Cumplimiento corporativo**: Adherencia a políticas internas
- **Protección de datos**: Prevención de filtración de información sensible
- **Comunicación profesional**: Mantenimiento de estándares corporativos

### 5. Aplicaciones de Salud
- **Prevención de consejos médicos**: Evitar diagnósticos no autorizados
- **Protección de información médica**: Cumplimiento con HIPAA
- **Contenido verificado**: Solo información de fuentes confiables

## Seguridad y Cumplimiento

### Mejores Prácticas de Seguridad

1. **Principio de Menor Privilegio**
   - Configurar roles IAM con permisos mínimos necesarios
   - Usar roles específicos para cada entorno

2. **Gestión de Versiones**
   - Crear versiones para cambios en producción
   - Mantener historial de configuraciones

3. **Monitoreo y Auditoría**
   - Implementar logging de actividades de guardrails
   - Revisar regularmente la efectividad de las políticas

4. **Configuración Gradual**
   - Comenzar con configuraciones permisivas
   - Ajustar gradualmente basado en resultados

### Cumplimiento Normativo

- **GDPR**: Protección de datos personales mediante PII filtering
- **COPPA**: Protección de menores con filtros de contenido
- **HIPAA**: Protección de información médica (aplicaciones de salud)
- **SOX**: Cumplimiento corporativo en aplicaciones financieras

### Configuraciones de Seguridad Recomendadas

```hcl
# Configuración de alta seguridad
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
    },
    {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "HATE"
    }
  ]
}

# Protección completa de PII
sensitive_information_policy_config = {
  pii_entities_config = [
    { type = "EMAIL", action = "BLOCK" },
    { type = "PHONE", action = "BLOCK" },
    { type = "US_SOCIAL_SECURITY_NUMBER", action = "BLOCK" },
    # Enmascarar solo en la salida, dejar pasar en la entrada
    { type = "CREDIT_DEBIT_CARD_NUMBER", action = "ANONYMIZE", input_action = "NONE", output_action = "ANONYMIZE" }
  ]
}
```

### Validaciones Incorporadas

El módulo valida la configuración en tiempo de `plan`:

- **Fuerza de filtros de contenido**: `input_strength`/`output_strength` deben ser `NONE`, `LOW`, `MEDIUM` o `HIGH`.
- **Acciones**: `action` de `pii_entities_config` y `regexes_config` debe ser `BLOCK`, `ANONYMIZE` o `NONE`.
- **Longitud de patrones**: cada `pattern` de regex admite un máximo de 500 caracteres.

## Observaciones y Consideraciones

### Limitaciones Técnicas

1. **Disponibilidad Regional**: Amazon Bedrock no está disponible en todas las regiones AWS
2. **Límites de Servicio**: Verificar cuotas de guardrails por cuenta
3. **Latencia**: Los guardrails añaden latencia a las respuestas del modelo
4. **Costo**: Cada evaluación de guardrail tiene un costo asociado

### Consideraciones de Rendimiento

- **Optimización de Políticas**: Configurar solo las políticas necesarias
- **Caching**: Implementar cache para consultas repetitivas
- **Monitoreo**: Supervisar métricas de latencia y throughput

### Mantenimiento y Evolución

1. **Revisión Periódica**: Evaluar efectividad de las políticas mensualmente
2. **Actualización de Patrones**: Mantener expresiones regulares actualizadas
3. **Feedback Loop**: Incorporar feedback de usuarios para mejoras
4. **Testing**: Probar cambios en entornos de desarrollo antes de producción

### Troubleshooting Común

- **Falsos Positivos**: Ajustar niveles de sensibilidad
- **Falsos Negativos**: Añadir patrones específicos o palabras clave
- **Rendimiento**: Optimizar configuraciones para balance entre seguridad y velocidad

### Roadmap y Futuras Mejoras

- Integración con AWS CloudWatch para métricas avanzadas
- Soporte para configuraciones dinámicas basadas en contexto
- Implementación de políticas adaptativas basadas en ML
- Integración con sistemas de feedback automatizado

---

**Versión**: 1.1.0  
**Última actualización**: Septiembre 2026  
**Mantenido por**: Equipo CloudOps - Pragma

### Cambios en 1.1.0

- Provider AWS actualizado a `>= 6.24`.
- Acciones por lado en PII y regex (`input_action`, `output_action`, `input_enabled`, `output_enabled`), opcionales y retrocompatibles.
- Republicación automática de versión al cambiar la política (`replace_triggered_by`) y retención de versiones anteriores (`skip_destroy`).
- Validaciones de fuerzas de filtros, acciones y longitud de patrones regex.
- `sample/` con `providers.tf` propio y ejemplos de los campos nuevos.

---

> Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción.
