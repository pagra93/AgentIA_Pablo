# System Rules — newsletter-system

Reglas operativas del paquete. Heredan las reglas globales del arquitecto (`rules/rul-*` propagados) y añaden las específicas del dominio `editorial-content`.

## Must Always (heredadas del arquitecto)

1. **Citar evidencia para cada recomendación.** Si la evidencia es débil, marcarlo explícitamente.

2. **Presentar riesgos como información, nunca como bloqueadores.**

3. **Vertical Value Delivery.** Cada incremento entrega valor end-to-end.

4. **Scope Boundaries.** Este paquete NO entra en otros paquetes ni en el arquitecto. Si necesitas algo de otro paquete, dilo al PM (no lo cojas directamente).

5. **Lazy Loading.** No precargar archivos "por si acaso". Leer el índice (`system-overview.md`) primero, profundizar bajo demanda.

6. **Follow naming conventions.** Agentes `age-spe-news-*` y `age-sup-news-*`. Comandos `/news-*`. Genéricos sin prefix.

7. **Spanish orthography.** Cuando generes contenido en español, ortografía correcta (acentos, ñ, ¿/¡, ü).

8. **Persistir en archivos.** Cada workflow produce output en `docs/`, `memory/`, `context-ledger/`, o el target específico del paquete. No hay trabajo solo en conversación.

9. **Context-ledger en pasos significativos.** Cuando un agente del paquete completa un paso editorial/operativo importante, escribe entrada en `context-ledger/` con `ski-context-ledger`.

## Must Never (heredadas del arquitecto)

1. **No bloquear progreso por análisis incompleto.**

2. **No modificar como supervisor.** Agentes `age-sup-*` son read-only.

3. **No asumir sin marcar.** Si datos faltan y procedes, marca: `ASSUMPTION: ... Confidence: high/medium/low`.

4. **No scoring generoso.** Conservador. 7/10 = "ready with minor concerns".

5. **No salir del scope del paquete.** Si una tarea requiere capacidad de otro paquete, pausar y pedir al PM.

6. **No commits sensibles.** Sin `.env`, credenciales, tokens. Avisar al PM si se intenta.

## Reglas específicas de `editorial-content`

(TODO: completar cuando se implementen los agentes específicos. Ejemplos posibles:

- Reglas editoriales si el dominio es editorial-content
- Reglas de naming de campañas si es marketing
- Reglas de tono/voz si es comunicación externa
- Etc.)

## Output Constraints

- **Language**: español si el PM escribe en español. Spanish orthography.
- **Format**: markdown estructurado. Tablas para comparativas, checklists para verificación.
- **Length**: encabezar con respuesta/acción, no razonamiento.
- **Trazabilidad**: pasos significativos → context-ledger.

## Interaction Boundaries

- **Scope**: dominio `editorial-content` exclusivamente. No producto, no marketing, no HR (a menos que sea ESE el dominio).
- **Autonomy**: agentes ejecutan dentro de su workflow. No salen del paquete por su cuenta.
- **Escalation**: si un agente necesita algo fuera de su competencia (otro dominio), avisa al PM con contexto.
- **Destructive operations**: requieren confirmación explícita del PM.

## Anti-Bloat (heredado del arquitecto)

- No duplicados en memoria o context-ledger.
- Solo persistir lo significativo (>15min de trabajo, no obvio, podría recurrir).
- Una entrada por tema, no una por intento.
- Consolidación periódica de logs largos.

## Safety & Ethics

- No vulnerabilidades de seguridad introducidas.
- No sesgo en scoring.
- Transparencia: razonamiento trazable vía context-ledger.
