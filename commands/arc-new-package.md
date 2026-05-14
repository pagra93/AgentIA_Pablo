---
description: "Crear paquete desplegable nuevo desde el template canónico. Mini-discovery de 5 preguntas + generación de stubs de agentes previstos. Ejecuta age-spe-arc-generator."
---

# /arc-new-package — Crear paquete desplegable

Genera un nuevo paquete en `exports/<nombre>/` partiendo de `templates/package-template/`. Incluye **mini-discovery** (5 preguntas guiadas) para que el paquete nazca con stubs útiles de los agentes previstos, no como esqueleto vacío.

**Tipo de operación**: write (crea archivos, ejecuta `git init` dentro del paquete).

## Sintaxis

```
/arc-new-package                              → mini-discovery completo (interactivo)
/arc-new-package <nombre>                     → pre-rellena el nombre, sigue con preguntas 2-5
/arc-new-package <nombre> --skip-discovery    → sólo copia template sin stubs (no recomendado)
```

## Mini-discovery (5 preguntas)

El generator invoca este flujo. El PM responde una por una; el generator NO continúa si falta info crítica.

1. **¿Nombre del paquete?** (ej. `newsletter-system`, `marketing-system`) — kebab-case, único en `exports/`.
2. **¿Dominio y propósito en una frase?** Define qué hace el paquete a alto nivel. Se usa en `CLAUDE.md`, `SOUL.md`, `agent.yaml`, `README.md`.
3. **¿Etapas principales del flujo?** (ej. `research → outline → draft → edit → publish`). Define el pipeline editorial/operativo. Se refleja en `system-overview.md` y guía la generación de stubs.
4. **¿Agentes principales previstos?** Lista informal: nombre + responsabilidad de una línea. El generator creará un stub por cada uno con `DUTIES.md` que dice `TODO: implementar`.
5. **¿Outputs / artefactos principales que produce?** (ej. número de newsletter `.md` + `.html`, métricas de envío). Define qué artefactos canónicos genera el paquete.

Bonus implícito: **prefix de 3-4 letras** (deducido del nombre: `newsletter-system` → `news`, `marketing-system` → `mkt`). El generator lo propone; el PM lo confirma o ajusta.

## Qué hace después del mini-discovery

1. Copia `templates/package-template/` → `exports/<nombre>/`
2. Sustituye placeholders en `.tmpl` con valores reales (`{{PACKAGE_NAME}}`, `{{DOMAIN}}`, `{{DOMAIN_FOLDER}}`, `{{PURPOSE}}`, `{{PREFIX}}`, `{{STAGES}}`, `{{EXPECTED_AGENTS}}`, `{{AUTHOR}}`, `{{DATE}}`)
3. Genera stubs de los agentes previstos en `exports/<nombre>/agents/age-spe-<prefix>-<n>/` con `DUTIES.md`/`SOUL.md`/`agent.yaml` vacíos pero estructurados
4. Registra los agentes-stub en el `agent.yaml` del paquete con descripción provisional
5. Genera `install.sh` parametrizado con `{{PREFIX}}` para compilar a `~/.claude/`
6. Genera `deploy.sh` parametrizado con `{{DOMAIN_FOLDER}}` para desplegar en proyectos clientes
7. Genera `dashboard-section.yaml` con `tab_id` y `tab_label` configurados
8. `git init` dentro de `exports/<nombre>/`
9. Invoca al cataloger (`/arc-catalog`) para actualizar `exports/README.md`
10. Primera entrada en `exports/<nombre>/context-ledger/` documentando la creación
11. Reporta al PM: estructura creada, agentes-stub pendientes de implementar, próximos pasos

## Reglas

- **NO crea paquetes con nombres ya existentes** en `exports/`. Si `<nombre>` ya está, el generator aborta con error y sugiere otro.
- **NO sobrescribe** archivos existentes (paranoia ante typos).
- **Mini-discovery NO es saltable por defecto.** El flag `--skip-discovery` existe para casos de scripting batch (raros), pero el resultado es un paquete que necesita relleno manual.

## Después de ejecutar

Próximos pasos típicos (que el generator sugiere al PM):

1. **Implementar la lógica de cada stub** — sesión aparte, dentro de `exports/<nombre>/`. El PM define `DUTIES.md`, `SOUL.md`, `agent.yaml` real de cada agente.
2. **Ejecutar `install.sh`** para compilar los agentes a `~/.claude/`: `bash exports/<nombre>/install.sh`
3. **Probar despliegue** en un proyecto cliente vacío: `bash exports/<nombre>/deploy.sh /tmp/test-<nombre>`
4. **Auditar** desde el arquitecto: `/arc-audit` (verifica que el paquete recién creado cumple la convención)

## Limitaciones

- **No regenera paquetes existentes**: si quieres reset, hay que borrar `exports/<nombre>/` manualmente antes (ver consecuencias del git anidado).
- **Stubs no son funcionales**: hasta que se implementen, los agentes del paquete no hacen nada útil. El paquete es desplegable pero no operativo.
