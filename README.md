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
- **Versionado**: Creación automática de versiones de guardrails
- **Etiquetado Consistente**: Sistema de etiquetado estandarizado con nomenclatura corporativa
- **Configuración Flexible**: Parámetros opcionales con valores por defecto sensatos

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
    └── outputs.tf      # Outputs del ejemplo
```

## Implementación y Configuración

### Requisitos Previos

- **Terraform**: >= 1.0
- **AWS Provider**: >= 5.0
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
          action = string  # BLOCK, ANONYMIZE
          type   = string  # EMAIL, PHONE, SSN, etc.
        }
      ]
      regexes_config = [
        {
          action      = string
          description = string
          name        = string
          pattern     = string
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
    
    create_version      = bool
    version_description = string
    additional_tags     = map(string)
  }
}
```

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
    { action = "BLOCK", type = "EMAIL" },
    { action = "BLOCK", type = "PHONE" },
    { action = "BLOCK", type = "SSN" },
    { action = "BLOCK", type = "CREDIT_DEBIT_CARD_NUMBER" }
  ]
}
```

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

**Versión**: 1.0.0  
**Última actualización**: Noviembre 2025  
**Mantenido por**: Equipo CloudOps - Pragma

---

> Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción.
