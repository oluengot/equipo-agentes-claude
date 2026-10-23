# Equipo de agentes de máxima calidad (sin importar el costo)

Protocolo de orquestación donde la calidad manda sobre el costo: todos los agentes usan el mejor
modelo disponible (`opus`). Tú eres el **orquestador**: coordinas y no tocas código directamente.

## Equipo

| Rol | model (Agent tool) | Qué hace |
|---|---|---|
| **Jefe** | `opus` | Investiga a fondo, compara alternativas y planifica (plan + plan de pruebas) |
| **Constructores** | `opus` | Implementan una tarea con casos borde, tests y autoverificación; en paralelo si no comparten archivos |
| **Revisor** | `opus` | Revisión independiente: cumplimiento + calidad + seguridad + intento adversarial |

`fable` solo si el usuario lo pide explícitamente.

## Protocolo

### 0. Triage
Pedido en `$ARGUMENTS`. Ambiguo → pregunta lo mínimo antes de planificar. Trivial → igual pasa por un
constructor y un revisor (omite al jefe). Normal → flujo completo.

### 1. Preparar
Carpeta `.equipo/$SLUG/` (kebab-case) con `PEDIDO.md` textual (más stack y restricciones relevantes).

### 2. Jefe
`Agent({ name: "jefe", model: "opus", description: "Investiga y planifica", prompt: <briefing> })`.
Briefing: pedido completo, estructura del repo, convenciones (CLAUDE.md), cómo se compila y se prueba.
Pídele: investigar el código vecino y correr la línea base (build/tests), comparar al menos 2 opciones
en cada decisión de diseño no trivial, y entregar: objetivo y criterios globales, línea base, decisiones
y alternativas descartadas, riesgos y casos borde, **plan de pruebas**, comandos de verificación, y tareas
(ID, título, enfoque, archivos permitidos, dependencias, ola). Siempre incluye una tarea de pruebas.
Guarda su respuesta en `.equipo/$SLUG/PLAN.md`.

### 3. Constructores (por olas, en paralelo en un solo mensaje)
`Agent({ name: "constructor-t01", model: "opus", description: "T01: <título>", prompt: <tarea autocontenida> })`.
El prompt trae: contexto de por qué existe la tarea, objetivo, archivos permitidos, pasos, casos borde a
cubrir, qué no hacer, criterios y comandos de verificación. Deben agregar o ajustar tests, correr
build/tests/lint y revisar su propio diff antes de reportar; lo que vean fuera de alcance lo anotan sin
tocarlo. Dos constructores de la misma ola nunca tocan el mismo archivo; los archivos compartidos van a una
tarea de integración final.

### 4. Revisor (cada tarea o cada ola)
`Agent({ name: "revisor", model: "opus", ... })` con el plan y la tarea. Debe: comparar archivos tocados
contra los permitidos, comprobar pasos y criterios con evidencia, **re-ejecutar** build/tests/lint (no confiar
en el reporte), leer el diff completo buscando errores de lógica, casos borde, vulnerabilidades, tests
vacíos e incoherencias, e intentar romper el cambio. Responde APROBADO o RECHAZADO con desviaciones
bloqueantes y sugerencias aparte.
- RECHAZADO → relanza al constructor con las correcciones. Máximo **3** intentos por tarea.

### 5. Escalar
Tras 3 rechazos: el jefe re-planifica solo esa tarea. Si vuelve a fallar, detente y pregunta al usuario.

### 6. Cierre (obligatorio)
1. Revisión final contra `PLAN.md` con build/tests/lint de todo el proyecto.
2. En cambios delicados o grandes, **revisión cruzada**: dos revisores con enfoque distinto
   ("seguridad y casos borde" / "mantenibilidad y pruebas") sobre el diff completo.
3. Resume qué se hizo, archivos cambiados, qué se verificó y qué no, y riesgos que quedan.
4. Estimación de costo (Opus 5.5: USD 4/20 por millón de tokens de entrada/salida): tabla con agentes
   lanzados y costo aproximado; es solo una estimación.

## Reglas
- **Siempre `model: "opus"`** en cada subagente; nunca `haiku` para trabajo que importe.
- Usa agentes frescos con prompts autocontenidos; un fork solo si el trabajo depende de toda esta conversación.
- Mensajes entre agentes: rutas y una línea; el detalle va en `.equipo/$SLUG/`.
- Nunca des por cerrada una tarea sin revisión aprobada y verificación corrida de verdad.

Uso: `/equipo-max <descripción de lo que quieres>` (todo lo que sigue es `$ARGUMENTS`).
