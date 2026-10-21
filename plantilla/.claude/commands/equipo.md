# Equipo de agentes costo-eficiente

Protocolo de orquestación para dividir trabajo en subagentes con control de costos.
Tú eres el **orquestador**: coordinas al equipo y no tocas código directamente.

## Equipo

| Rol | model (Agent tool) | Qué hace | Cuándo |
|---|---|---|---|
| **Jefe** | `opus` | Planifica: analiza el pedido, genera un plan con tareas independientes | Una vez al inicio |
| **Constructores** | `haiku` | Ejecutan una tarea cada uno, en paralelo si no comparten archivos | Tantos como tareas independientes |
| **Supervisor** | `sonnet` | Valida que cada constructor siguió las instrucciones al pie de la letra | Después de cada ola de constructores |

## Protocolo

### 0. Triage

Lee el pedido del usuario (está en `$ARGUMENTS`).

- **Trivial** (una pregunta, un cambio de una línea, algo que se resuelve en 2-3 tool calls): hazlo tú directamente, sin lanzar agentes. Salta al paso 6.
- **Ambiguo**: pregunta lo mínimo necesario para continuar.
- **Normal**: sigue al paso 1.

### 1. Preparar

Crea la carpeta `.equipo/$SLUG/` (slug = nombre corto del pedido en kebab-case).
Escribe `.equipo/$SLUG/PEDIDO.md` con el pedido original del usuario.

### 2. Jefe (planificación)

Lanza un agente con:
```
Agent({
  name: "jefe",
  model: "opus",
  description: "Planifica la tarea",
  prompt: "<briefing completo: pedido, estructura del proyecto, stack, convenciones, archivos relevantes>"
})
```

El **briefing del jefe** debe incluir:
- El pedido completo del usuario
- La estructura del proyecto (resultado de `ls` o `tree`)
- El stack y las convenciones del proyecto (de CLAUDE.md si existe)
- Archivos clave ya leídos que el jefe necesita para planificar

El jefe debe responder con un plan estructurado:
- Objetivo general y criterios de éxito
- Lista de tareas con: ID (T01, T02…), título, enfoque/especialidad, archivos permitidos, dependencias, ola (las tareas de la misma ola pueden correr en paralelo)
- Comandos de verificación (tests, lint, build)
- Decisiones de arquitectura tomadas

Guarda la respuesta del jefe en `.equipo/$SLUG/PLAN.md`.

### 3. Constructores (ejecución)

Por cada **ola** del plan (tareas sin dependencias entre sí), lanza los constructores **en paralelo en un solo mensaje** (múltiples Agent calls):

```
Agent({
  name: "constructor-t01",
  model: "haiku",
  description: "Ejecuta T01: <título>",
  prompt: "<instrucciones autocontenidas de la tarea>"
})
```

Reglas de cada constructor:
- **model siempre `haiku`** (el más barato: USD 0.10/USD 0.50 por millón de tokens)
- El **prompt debe ser autocontenido**: objetivo, archivos permitidos, pasos concretos, qué no hacer, cómo verificar. El constructor no ve esta conversación.
- Dos constructores de la misma ola **nunca tocan el mismo archivo**. Archivos compartidos (índices, config, rutas) van a una tarea de integración al final.
- Si una tarea depende de otra, va en una ola posterior.

### 4. Supervisor (validación)

Después de cada ola, lanza el supervisor:

```
Agent({
  name: "supervisor",
  model: "sonnet",
  description: "Valida ola N",
  prompt: "Revisa que los cambios cumplan el plan. Plan: <contenido de PLAN.md>. Tareas de esta ola: <lista>. Verifica: 1) Solo se tocaron los archivos permitidos. 2) Se cumplieron los criterios de aceptación. 3) Los tests/lint/build pasan. Responde APROBADO o RECHAZADO con evidencia."
})
```

- **APROBADO**: sigue con la siguiente ola o al cierre.
- **RECHAZADO**: el supervisor indica qué falló. Relanza **el mismo constructor** (model haiku) con las correcciones. Máximo 2 intentos de corrección por tarea.

### 5. Escalar

Si después de 2 correcciones sigue fallando, lanza al jefe (model opus) para re-planificar **solo esa tarea**.

### 6. Cierre

- Si hubo plan formal, lanza al supervisor para una revisión final contra el plan completo.
- Presenta al usuario un resumen de lo que se hizo, qué archivos se cambiaron y qué verificaciones pasaron.
- Informa el costo aproximado del equipo (ver sección de costos).

## Estimación de costos

Al terminar, calcula una estimación basada en el número de agentes lanzados:

| Agente | Modelo | Entrada $/1M | Salida $/1M | Costo típico por llamada |
|---|---|---|---|---|
| Jefe | Opus 5.5 | USD 4.00 | USD 20.00 | ~USD 0.10-0.50 |
| Constructor | Haiku 5.5 | USD 0.10 | USD 0.50 | ~USD 0.001-0.01 |
| Supervisor | Sonnet 5.5 | USD 2.00 | USD 10.00 | ~USD 0.02-0.10 |
| Orquestador | (tu modelo) | — | — | (ya incluido en tu plan) |

Presenta una tabla resumen:
```
## Costo estimado del equipo
| Rol | Modelo | Agentes lanzados | Costo estimado |
|---|---|---|---|
| Jefe | opus | 1 | ~USD 0.XX |
| Constructores | haiku | N | ~USD 0.XX |
| Supervisor | sonnet | M | ~USD 0.XX |
| **Total estimado** | | | **~USD 0.XX** |
```

Nota: es una estimación basada en el uso típico por agente. El costo real depende del largo de los prompts y las respuestas.

## Reglas de costo (obligatorias)

1. **Constructores siempre en `haiku`**: nunca uses `sonnet`, `opus` o `fable` para un constructor.
2. **No uses `subagent_type: "fork"` para constructores**: un fork hereda todo el contexto (caro). Usa agentes frescos con prompts autocontenidos.
3. **El jefe no ejecuta**: solo planifica. Una llamada, lectura solamente.
4. **Prompts con rutas, no contenidos**: en vez de pegar archivos enteros en el prompt del constructor, dale la ruta y dile que lo lea.
5. **Supervisor solo cuando es necesario**: para tareas triviales o de una sola tarea, sáltalo.
6. **Mata el trabajo temprano**: si el triage dice trivial, hazlo tú. No armes un equipo para cambiar una línea.

## Formato del pedido del usuario

El usuario escribe: `/equipo <descripción de lo que quiere>`

Todo lo que viene después de `/equipo` es `$ARGUMENTS`.
