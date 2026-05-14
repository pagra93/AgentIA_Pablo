---
description: "Regenerar exports/README.md (catálogo de paquetes) escaneando exports/*/. Muestra paquete, dominio, versión, último commit, salud. Ejecuta age-spe-arc-cataloger."
---

# /arc-catalog — Refrescar catálogo de paquetes

Mantiene `exports/README.md` como índice del estado del ecosistema. Tabla con todos los paquetes desplegables, su dominio, versión, último commit y salud.

**Auto-invocado** tras `/arc-new-package` y `/arc-propagate`. **Invocable manualmente** cuando quieras forzar refresh.

**Tipo de operación**: write (modifica `exports/README.md`). Read-only sobre el contenido de paquetes (solo lee `agent.yaml` y metadatos git).

## Sintaxis

```
/arc-catalog                      → escanea todos los paquetes y regenera exports/README.md
/arc-catalog --dry-run            → muestra la tabla regenerada sin escribir
/arc-catalog --check              → solo reporta inconsistencias, no regenera
```

## Qué hace

1. Lee `exports/README.md` actual (preserva header y secciones no auto-generadas)
2. Escanea `exports/*/` (cada subcarpeta es un paquete)
3. Para cada paquete, lee:
   - `agent.yaml` → name, version, description, domain
   - `git log -1 --format=%cs %h` → fecha y hash del último commit
   - `system-overview.md` (si existe) → cuenta agentes/skills/commands declarados
   - `context-ledger/` → última entrada (timestamp) para indicar uso reciente
4. Detecta señales de salud:
   - 🟢 Vivo: último commit < 14 días + ledger con entradas recientes
   - 🟡 Latente: commit > 14 días pero < 90 días
   - 🔴 Inactivo: commit > 90 días o sin commits desde creación
   - ⚪ Recién creado: < 7 días desde primer commit
5. Construye la tabla:

```markdown
| Paquete | Prefix | Dominio | Versión | Último commit | Salud | Notas |
|---------|--------|---------|---------|---------------|-------|-------|
| newsletter-system | news | editorial-content | 0.1.0 | 2026-05-14 (`4c6c12b`) | ⚪ Recién creado | 6 stubs sin implementar |
| pmx-product | pm | product-management | 2.2.0 | 2026-05-14 (`9bed57e`) | 🟢 Vivo | (ver nota PM x10 abajo) |
| marketing-system | mkt | marketing | — | — | — | _placeholder_ |
```

6. Escribe el README con la tabla actualizada, conservando:
   - Header (título, descripción, link al arquitecto)
   - Notas operativas (ej. "PM x10 no migrado todavía a exports/")
   - Footer (timestamp de última regeneración)

## Estructura de `exports/README.md`

```markdown
# Exports — Catálogo de paquetes desplegables

(Mantenido por `age-spe-arc-cataloger`. Última regeneración: <fecha>.)

## Tabla de paquetes

<tabla auto-generada>

## Estado de salud

🟢 Vivo  | 🟡 Latente  | 🔴 Inactivo  | ⚪ Recién creado

## Notas operativas

(Sección manual. El cataloger NO la sobrescribe.)

- PM x10 (`Proyectos/Agente IA/`) NO está migrado a `exports/pmx-product/` todavía. Decisión opcional, futura.
- ...

## Auto-regeneración

Auto-invocado tras `/arc-new-package` y `/arc-propagate`. Refresco manual: `/arc-catalog`.
```

## Reglas

- **NO escribe en archivos de paquetes**. Solo lee. Su única escritura es `exports/README.md`.
- **Preserva contenido manual**: el README puede tener secciones que el PM ha escrito a mano (ej. "Notas operativas"). El cataloger respeta lo que no es tabla auto-generada.
- **Salud es heurística**: si parece inconsistente (paquete con commit reciente pero sin uso), se marca con notas y el PM decide.

## Cuándo invocar manualmente

- Después de migrar PM x10 a `exports/pmx-product/` (Fase 14 opcional) para que aparezca en el catálogo
- Después de cambiar la versión en `agent.yaml` de un paquete
- Cuando quieras un snapshot del estado del ecosistema

## Limitaciones

- **No detecta paquetes externos** al `exports/` del arquitecto. Si tienes un paquete que vive en otra ruta, no aparece.
- **No verifica si los paquetes están instalados** en `~/.claude/`. Eso lo hace `install.sh` de cada paquete (o un comando dedicado futuro).
- **No verifica deployments**. Para ver dónde está desplegado cada paquete, leer `~/.claude/projects-registry.txt` (mantenido por `deploy.sh` de cada paquete).
