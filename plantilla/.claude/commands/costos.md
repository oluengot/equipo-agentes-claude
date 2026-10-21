# Tabla de costos de modelos Claude

Muestra los precios actuales de los modelos de Claude para referencia del usuario.

## Precios por millón de tokens (API Anthropic, oct 2026)

| Modelo | ID | Entrada | Salida | Caché lectura | Rol en el equipo |
|---|---|---:|---:|---:|---|
| Haiku 5.5 | claude-haiku-5-5 | $0.10 | $0.50 | — | **Constructor** (ejecutor) |
| Sonnet 5.5 | claude-sonnet-5-5 | $2.00 | $10.00 | $0.20 | **Supervisor** (validador) |
| Opus 5.5 | claude-opus-5-5 | $4.00 | $20.00 | $0.20 | **Jefe** (planificador) |
| Fable 5.1 | claude-fable-5-1 | $10.00 | $50.00 | $0.25 | Solo si el usuario lo pide |

### Comparación de costo por agente típico

| Agente | Modelo | Tokens entrada | Tokens salida | Costo estimado |
|---|---|---:|---:|---:|
| Constructor | Haiku 5.5 | ~50.000 | ~5.000 | **$0.0075** |
| Supervisor | Sonnet 5.5 | ~30.000 | ~3.000 | **$0.09** |
| Jefe | Opus 5.5 | ~50.000 | ~10.000 | **$0.40** |

Un equipo típico (1 jefe + 4 constructores + 1 supervisor) cuesta aproximadamente **$0.52**.
El mismo trabajo con un solo agente Opus corriendo todo: **~$2.00+**.

### Comparación con Antigravity

| | Antigravity (Flash) | Claude Code (Haiku) | Ahorro |
|---|---|---|---|
| Ejecutor (entrada) | $0.75/MTok | $0.10/MTok | **87%** |
| Ejecutor (salida) | $3.75/MTok | $0.50/MTok | **87%** |
| Planificador (entrada) | $2.00/MTok (Argon) | $4.00/MTok (Opus) | -100% |
| Planificador (salida) | $10.00/MTok | $20.00/MTok | -100% |

Los constructores en Claude son **7.5× más baratos** que en Antigravity.
El jefe en Claude es 2× más caro, pero solo se usa una vez por tarea.
En total, un equipo grande con muchos constructores sale más barato en Claude.
