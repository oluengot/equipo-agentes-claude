# Tabla de costos de modelos Claude

Muestra los precios actuales de los modelos de Claude para referencia del usuario.

## Precios por millón de tokens (API Anthropic, oct 2026)

| Modelo | ID | Entrada | Salida | Caché lectura | Rol en el equipo |
|---|---|---:|---:|---:|---|
| Haiku 5.5 | claude-haiku-5-5 | USD 0.10 | USD 0.50 | — | **Constructor** (ejecutor) |
| Sonnet 5.5 | claude-sonnet-5-5 | USD 2.00 | USD 10.00 | USD 0.20 | **Supervisor** (validador) |
| Opus 5.5 | claude-opus-5-5 | USD 4.00 | USD 20.00 | USD 0.20 | **Jefe** (planificador) |
| Fable 5.1 | claude-fable-5-1 | USD 10.00 | USD 50.00 | USD 0.25 | Solo si el usuario lo pide |

### Comparación de costo por agente típico

| Agente | Modelo | Tokens entrada | Tokens salida | Costo estimado |
|---|---|---:|---:|---:|
| Constructor | Haiku 5.5 | ~50.000 | ~5.000 | **USD 0.0075** |
| Supervisor | Sonnet 5.5 | ~30.000 | ~3.000 | **USD 0.09** |
| Jefe | Opus 5.5 | ~50.000 | ~10.000 | **USD 0.40** |

Un equipo típico (1 jefe + 4 constructores + 1 supervisor) cuesta aproximadamente **USD 0.52**.
El mismo trabajo con un solo agente Opus corriendo todo: **~USD 2.00+**.

### Comparación con Antigravity

| | Antigravity (Flash) | Claude Code (Haiku) | Ahorro |
|---|---|---|---|
| Ejecutor (entrada) | USD 0.75/MTok | USD 0.10/MTok | **87%** |
| Ejecutor (salida) | USD 3.75/MTok | USD 0.50/MTok | **87%** |
| Planificador (entrada) | USD 2.00/MTok (Argon) | USD 4.00/MTok (Opus) | -100% |
| Planificador (salida) | USD 10.00/MTok | USD 20.00/MTok | -100% |

Los constructores en Claude son **7.5× más baratos** que en Antigravity.
El jefe en Claude es 2× más caro, pero solo se usa una vez por tarea.
En total, un equipo grande con muchos constructores sale más barato en Claude.
