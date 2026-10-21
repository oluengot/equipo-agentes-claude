# Dividir tarea en subagentes constructores

Cuando el usuario pide "divide la tarea en tantos subagentes como estimes necesario"
(o variantes: "usa varios agentes", "paraleliza esto", "divide esto en partes"), sigue
este protocolo:

## Análisis

1. Lee el pedido del usuario (`$ARGUMENTS`) y analiza el proyecto.
2. Identifica las **partes independientes** del trabajo: partes que no comparten archivos
   y que pueden ejecutarse en paralelo.
3. Decide el **enfoque/especialidad** de cada parte (ej. "Frontend React", "Tests pytest",
   "Migración SQL", "Documentación").

## Ejecución

Lanza todos los constructores **en paralelo en un solo mensaje**, cada uno con:

```
Agent({
  name: "constructor-<parte>",
  model: "haiku",
  description: "<especialidad>: <qué hace>",
  prompt: "<instrucciones autocontenidas>"
})
```

### Reglas

- **Siempre `model: "haiku"`** — el más barato ($0.10/$0.50 por MTok).
- **Nunca `subagent_type: "fork"`** — un fork hereda todo el contexto y es caro. Usa agentes frescos.
- **Prompt autocontenido**: el constructor no ve esta conversación. Dale todo lo que necesita:
  objetivo, archivos a tocar, archivos a leer, pasos, restricciones, verificación.
- **Sin cruces**: dos constructores nunca tocan el mismo archivo en la misma tanda.
  Archivos compartidos van a una tarea de integración que corre al final.
- **Cantidad**: tantos como partes independientes, o el tope que dé el usuario.
- Si el usuario pidió un número específico, respétalo.

## Revisión

Cuando todos terminen:
1. Revisa brevemente los resultados.
2. Si el trabajo es delicado o grande, lanza un supervisor (`model: "sonnet"`) para validar.
3. Si hay archivos compartidos pendientes, haz la integración tú o con un último constructor.
4. Presenta el resumen al usuario.

## Formato

El usuario escribe: `/dividir <descripción de la tarea>`
