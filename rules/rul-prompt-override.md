---
name: rul-prompt-override
description: "Convención universal: cualquier agente, antes de trabajar sobre una HU/EPIC, debe leer el campo `prompt_override` del frontmatter y respetarlo como instrucciones específicas del usuario. Preloaded por todos los agentes."
---

# Regla universal: `prompt_override` en el frontmatter de la tarea

## ¿Qué es?

`prompt_override` es un campo opcional que puede aparecer en el frontmatter YAML
de cualquier HU o EPIC dentro de `docs/<área>/features/<feature>/stories.md`.
Cuando existe, contiene **instrucciones específicas que el usuario ha escrito
para esta tarea en particular**: foco, restricciones, ángulo, detalles que el
agente no tendría forma de inferir solo del título y el research.

Ejemplo de frontmatter con prompt_override:

```yaml
id: HU-038
title: "Sidebar de navegación"
status: research
priority: 4
prompt_override: |
  Enfoca el research en aplicaciones B2B SaaS con dashboards complejos.
  Ignora referencias de e-commerce. Compara especialmente Linear, Notion
  y Height en cómo manejan jerarquías de >3 niveles.
```

## Regla operativa (vale para CUALQUIER agente)

**Antes de empezar a trabajar sobre una HU o EPIC concreta:**

1. Localiza su frontmatter YAML en `docs/<área>/features/<feature>/stories.md`.
2. Lee el campo `prompt_override`. Si está vacío o no existe, procede normal.
3. Si tiene contenido, **trátalo como instrucciones del usuario con prioridad
   alta sobre cualquier inferencia propia o convención por defecto**.
4. Si el `prompt_override` contradice tus heurísticas habituales, gana el
   `prompt_override` salvo que viole reglas de seguridad o calidad
   irrenunciables. En ese caso, escribe en tu output por qué no lo respetaste.
5. Cita explícitamente en tu output que has aplicado `prompt_override` (ej.
   "He seguido el `prompt_override` del usuario que pedía enfocar X").

## Por qué existe esta regla

Sin `prompt_override`, los agentes trabajan solo con el contexto inferible
(título, criticidad, research previo, etc.). Eso es suficiente para tareas
genéricas, pero el usuario a menudo tiene **información tácita** sobre cómo
quiere que se aborde una tarea concreta. `prompt_override` es el canal durable
y versionado para esa información.

Funciona igual:
- **Modo manual**: el dashboard copia al portapapeles el comando + el
  `prompt_override` para que el usuario lo pegue en Claude Code.
- **Modo autónomo** (PM lanza solo): el PM lee `prompt_override` del frontmatter
  y lo inyecta como contexto al sub-agente.

En ambos casos el dato es el mismo y vive en el `.md`.

## Lo que NO es `prompt_override`

- **No es un reemplazo del título o de la descripción** de la HU. El agente
  sigue leyendo todo lo demás del frontmatter y del cuerpo de la HU.
- **No es código ni comandos**. Es lenguaje natural.
- **No es contexto temporal**. Vive en git, persiste entre sesiones.
- **No salta validaciones del agente**. Si pide hacer algo destructivo o
  inseguro, el agente debe pararse y avisar al usuario.

## Cómo encontrar `prompt_override` rápidamente

Si el agente recibe un ID (HU-038, EPIC-002):

```bash
# Localizar el archivo stories.md que contiene la HU
grep -rl "^id: HU-038" docs/*/features/*/stories.md
```

Después lee el bloque YAML correspondiente con Read y busca `prompt_override:`.

Si no aparece el campo, asume vacío y continúa.
