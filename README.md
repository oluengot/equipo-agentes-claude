# Equipo de agentes para Claude Code

Plantilla reutilizable para cualquier tipo de desarrollo en Claude Code que reparte el
trabajo por costo: el modelo caro **solo planifica**, el barato **ejecuta** y uno medio
**valida**. Usa la herramienta `Agent` nativa de Claude Code con el parámetro `model`
para fijar el modelo de cada subagente.

## Estructura del equipo

```
Usuario
  └─ ORQUESTADOR  (conversación principal · modelo que elijas)
       ├─ JEFE         model: opus    → planifica: plan + tareas autocontenidas
       ├─ CONSTRUCTOR  model: haiku   → ejecuta 1 tarea (varios en paralelo si no comparten archivos)
       └─ SUPERVISOR   model: sonnet  → valida cada tarea contra el plan (APROBADO / RECHAZADO)
```

Flujo: triage → jefe planifica → constructores ejecutan → supervisor revisa →
si rechaza, el mismo constructor corrige (máx. 2 veces) → si sigue fallando, el jefe
re-planifica solo esa tarea → revisión final del supervisor.

## Precios (API Anthropic, oct 2026)

| Modelo | ID | Entrada $/1M | Salida $/1M | Rol |
|---|---|---:|---:|---|
| **Haiku 5.5** | claude-haiku-5-5 | **$0.10** | **$0.50** | Constructor (el más barato) |
| Sonnet 5.5 | claude-sonnet-5-5 | $2.00 | $10.00 | Supervisor |
| Opus 5.5 | claude-opus-5-5 | $4.00 | $20.00 | Jefe (una vez) |
| Fable 5.1 | claude-fable-5-1 | $10.00 | $50.00 | Solo si el usuario lo pide |

Un equipo típico (1 jefe + 4 constructores + 1 supervisor) cuesta ~**$0.52**.
El mismo trabajo con un solo agente Opus: ~$2.00+.

> **Ojo al editar los comandos (`plantilla/.claude/commands/*.md`):** escribir precios como
> `USD 0.10`, nunca `$0.10`. Claude Code reemplaza `$0`, `$1`… por las palabras del pedido
> (`/equipo que puedo hacer` → `$0.10` se vuelve `que.10`). Este README no se ve afectado.

### Comparación con Antigravity

| Ejecutor | Antigravity (Flash) | Claude Code (Haiku) |
|---|---|---|
| Entrada | $0.75/MTok | **$0.10/MTok** (7.5× más barato) |
| Salida | $3.75/MTok | **$0.50/MTok** (7.5× más barato) |

Los constructores en Claude son **7.5 veces más baratos** que en Antigravity.

## Constructores con enfoque dinámico

Los constructores no son genéricos. Cada uno recibe un enfoque/especialidad en su prompt:

- `/equipo`: el jefe decide el enfoque de cada tarea en el plan.
- `/dividir`: el orquestador decide el enfoque según el pedido del usuario.

Ejemplos de enfoque: "Especialista en tests pytest", "Frontend React + accesibilidad",
"Migración SQL", "Documentación técnica".

El modelo sigue siendo Haiku en todos los casos — el enfoque guía el trabajo, no cambia el costo.

## Comandos

| Comando | Qué hace |
|---|---|
| `/equipo <pedido>` | Equipo completo: jefe planifica, constructores ejecutan, supervisor valida |
| `/equipo-max <pedido>` | Máxima calidad sin importar costo: todo Opus, pruebas obligatorias, revisor independiente y revisión cruzada |
| `/dividir <pedido>` | Solo constructores en paralelo (sin jefe ni supervisor formal) |
| `/costos` | Muestra la tabla de precios de los modelos |

## Cómo se asigna cada modelo

En Claude Code, la herramienta `Agent` acepta un parámetro `model` con estos valores:

| Valor | Modelo real | Cuándo se usa |
|---|---|---|
| `"haiku"` | Haiku 5.5 ($0.10/$0.50) | Constructores — siempre |
| `"sonnet"` | Sonnet 5.5 ($2/$10) | Supervisor — validación |
| `"opus"` | Opus 5.5 ($4/$20) | Jefe — planificación, una vez |
| `"fable"` | Fable 5.1 ($10/$50) | Solo si el usuario lo pide |

El orquestador corre con el modelo de tu conversación (el que elegiste al abrirla o con `/model`).
Recomendación: usa **Sonnet** para el orquestador como buen balance costo/calidad.

## Archivos de intercambio

Todo el intercambio queda en `.equipo/<slug>/`:
`PEDIDO.md`, `PLAN.md` (del jefe), y los resultados de cada constructor y supervisor.
Los agentes se pasan **rutas** de archivos, no contenidos — eso mantiene bajo el gasto.

## Archivos

| Archivo | Qué es |
|---|---|
| `plantilla/.claude/commands/equipo.md` | Comando `/equipo`: equipo completo con protocolo de orquestación |
| `plantilla/.claude/commands/equipo-max.md` | Comando `/equipo-max`: variante de máxima calidad (todo Opus) |
| `plantilla/.claude/commands/dividir.md` | Comando `/dividir`: constructores en paralelo sin plan formal |
| `plantilla/.claude/commands/costos.md` | Comando `/costos`: tabla de precios para referencia |
| `plantilla/CLAUDE.md.equipo` | Reglas de economía para agregar al CLAUDE.md del proyecto |
| `instalar.ps1` | Copia los comandos a la config global o a un proyecto |

## Instalación

Global (queda disponible en todos tus proyectos):

```bash
powershell -ExecutionPolicy Bypass -File "C:/Users/oluengo/Desarrollos Cloude/Equipo Agentes Claude/instalar.ps1"
```

Solo en un proyecto (y agrega las reglas al CLAUDE.md):

```bash
powershell -ExecutionPolicy Bypass -File "C:/Users/oluengo/Desarrollos Cloude/Equipo Agentes Claude/instalar.ps1" -Proyecto "C:/ruta/al/proyecto"
```

## Uso

1. Abre el proyecto en Claude Code.
2. Escribe: `/equipo <lo que quieres construir>`
   — o `/dividir <tarea>` para paralelizar sin plan formal.
3. Sigue el avance en `.equipo/<slug>/`.

## Consejos para que salga barato

- Pedidos chicos: el triage detecta lo trivial y lo resuelve sin lanzar agentes.
- Da contexto en el pedido (stack, tests, convenciones): ahorra exploración del jefe.
- Usa `/dividir` en vez de `/equipo` cuando no necesitas un plan formal.
- Las reglas en CLAUDE.md.equipo aplican **siempre** (no solo con `/equipo`): cualquier
  división en subagentes usará Haiku automáticamente.

## Diferencias con el equipo de Antigravity

| Aspecto | Antigravity | Claude Code |
|---|---|---|
| Definición de agentes | `.agents/agents/*.md` con frontmatter | Herramienta `Agent` con parámetro `model` |
| Skill | `.agents/skills/equipo/SKILL.md` | `.claude/commands/equipo.md` |
| Reglas | `.agents/rules/*.md` con trigger | Sección en CLAUDE.md |
| Modelo ejecutor | Flash ($0.75/$3.75) | **Haiku ($0.10/$0.50)** — 7.5× más barato |
| Modelo planificador | Pro/Argon ($2/$10) | Opus ($4/$20) — 2× más caro pero solo 1 vez |
| Medición de consumo | `consumo.py` lee transcripts | No hay transcripts accesibles; estimación por agente |
| Paralelismo | `invoke_subagent` con array de Subagents | Múltiples `Agent()` en un solo mensaje |
