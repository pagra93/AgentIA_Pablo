---
description: "Desplegar un paquete del arquitecto en un proyecto cliente (cwd actual o ruta explicita). Ejecuta el deploy.sh del paquete con detección automática del proyecto."
---

# /arc-deploy — Desplegar un paquete en un proyecto cliente

Atajo corto para desplegar cualquier paquete de `exports/<paquete>/` en un proyecto cliente, sin tener que escribir rutas absolutas largas. Equivalente al comando `arc deploy` del wrapper CLI.

**Sin argumentos**: lista paquetes disponibles y pide elegir uno + ruta destino (o cwd).
**Con `<paquete>`**: despliega ese paquete en `cwd` (la carpeta donde abriste Claude Code).
**Con `<paquete> <ruta>`**: despliega ese paquete en la ruta dada.

## Sintaxis

```
/arc-deploy                               → muestra ayuda + lista paquetes
/arc-deploy <paquete>                     → despliega en cwd actual
/arc-deploy <paquete> <ruta>              → despliega en ruta explícita
/arc-deploy <paquete> . --dry-run         → simulacion sin escribir
/arc-deploy <paquete> . --force-update    → refresca aunque ya este desplegado
```

## Ejemplos

```
/arc-deploy pmx-product
/arc-deploy newsletter-system
/arc-deploy pmx-product /Users/yo/Desktop/MiClienteNuevo
/arc-deploy newsletter-system . --dry-run
```

## Qué hace este comando

1. **Determina el paquete**: lee el primer argumento. Si no lo hay, listar paquetes disponibles en `exports/` y abortar.

2. **Determina la ruta destino**:
   - Si hay segundo argumento → usar esa ruta (relativa o absoluta).
   - Si no hay → usar el `cwd` (la carpeta donde Claude Code está abierto).

3. **Resuelve rutas a absolutas**:
   - Ruta del paquete: `<repo-arquitecto>/exports/<paquete>/`
   - Ruta del proyecto: convertir a absoluta. Si no existe, `mkdir -p`.

4. **Sanity checks**:
   - Existe `exports/<paquete>/deploy.sh` y es ejecutable.
   - La ruta del proyecto NO es `/`, NO es `$HOME`, NO contiene `..`.

5. **Ejecuta**: `bash <repo-arquitecto>/exports/<paquete>/deploy.sh <ruta-proyecto-absoluta> [flags...]`

6. **Reporta el resultado**: salida del deploy.sh + verificación post (`pm/config.json` actualizado, sección del dashboard creada).

## Cómo Claude resuelve el repo del arquitecto

Tres formas, en orden:

1. **`$HOME/.claude/packages-registry.txt`**: la primera línea es `agent-architect|arc|<ruta>|<timestamp>`. Esa `<ruta>` es el repo del arquitecto.
2. **`$HOME/.claude/arc`**: el wrapper tiene la línea `SYSTEM_REPO="<ruta>"`.
3. **Variable `SYSTEM_REPO`**: si Claude la conoce por contexto, úsala.

Si ninguna fuente está disponible, pedir al usuario la ruta del arquitecto y proceder.

## Flujo paso a paso (lo que el agente ejecuta)

```bash
# 1. Resolver repo del arquitecto
ARCHITECT_REPO=$(grep "^agent-architect|" ~/.claude/packages-registry.txt | awk -F'|' '{print $3}')

# 2. Validar paquete
PACKAGE="$1"
[ -d "$ARCHITECT_REPO/exports/$PACKAGE" ] || abortar

# 3. Resolver ruta del proyecto
PROJECT="${2:-.}"
[ -d "$PROJECT" ] || mkdir -p "$PROJECT"
PROJECT_ABS=$(cd "$PROJECT" && pwd)

# 4. Ejecutar
bash "$ARCHITECT_REPO/exports/$PACKAGE/deploy.sh" "$PROJECT_ABS" "${@:3}"

# 5. Verificar
cat "$PROJECT_ABS/pm/config.json" | grep "$PACKAGE"
ls "$PROJECT_ABS/dashboard/sections/"
```

## Diferencia con `/new-project` (comando legacy de PM x10)

- `/new-project`: legacy, solo PM x10, dashboard PROPIO de PM x10 (no multi-paquete).
- `/arc-deploy <paquete>`: nuevo, cualquier paquete del arquitecto, modelo multi-paquete (varios paquetes conviven con pestañas).

Usa `/arc-deploy` si vas a desplegar VARIOS paquetes en un proyecto, o si quieres el dashboard multi-paquete. Usa `/new-project` si solo quieres PM x10 con su dashboard original (experiencia legacy).

## Casos especiales

- **Proyecto vacío (desde 0)**: el deploy.sh del primer paquete detecta que el proyecto NO tiene estructura y la materializa desde `templates/project-template/` del arquitecto.
- **Proyecto ya con un paquete**: el deploy.sh detecta estructura existente y solo añade la pestaña de su dominio.
- **Re-desplegar el mismo paquete**: por defecto no hace nada (idempotente). Con `--force-update` refresca su sección del dashboard.

## Errores comunes

| Error | Causa | Solución |
|---|---|---|
| `paquete '<x>' no encontrado` | Typo o paquete no existe en `exports/` | Verificar con `arc list` |
| `deploy.sh no encontrado` | Paquete sin script (stub no terminado) | Reportar al PM |
| `ruta no permitida` | Pasaste `/` o `$HOME` | Usar una ruta específica del proyecto |
| `proyecto ya tiene paquete instalado` | El paquete ya está en `deployed_packages` | Usar `--force-update` si quieres refrescar |

## Después del despliegue

1. **Arrancar dashboard del proyecto** (si tiene varios paquetes):
   ```bash
   cd <ruta-proyecto>
   python3 dashboard/bridge.py
   ```

2. **Empezar a trabajar** con los comandos del paquete:
   - `/pm sync` (si desplegaste pmx-product)
   - `/news-*` (si desplegaste newsletter-system)
   - etc.

3. **Revisar registro**:
   ```bash
   cat ~/.claude/projects-registry.txt
   ```
