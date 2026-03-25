---
name: rul-git-branch-management
description: "Flujo completo de Git y GitHub: estructura de ramas, PRs, merge, limpieza y manejo de errores. Preloaded por engineering agents y usado por /save."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: engineering
  loaded-by: [age-spe-frontend-dev, age-spe-backend-arch, age-spe-mobile-builder, age-spe-test-engineer]
---

# Rule: Git Branch Management

Guia de referencia para el flujo completo de trabajo con Git y GitHub.

## Reglas Absolutas

1. **NUNCA** hacer commits directos a `main`
2. **NUNCA** hacer push directo a `main`
3. **NUNCA** hacer merge local a `main`
4. **SIEMPRE** trabajar en ramas (`feat/*`, `fix/*`, etc.)
5. **SIEMPRE** integrar a `main` via Pull Request
6. **SIEMPRE** borrar ramas despues del merge

## Estructura de Ramas

### Main (Produccion)
- Codigo listo para produccion
- No se permite push directo
- Solo entrada via Pull Request con checks verdes

### Ramas de Trabajo (Efimeras)

**Convencion:** `tipo/descripcion-corta-con-guiones`

| Tipo | Uso |
|------|-----|
| `feat/` | Nueva funcionalidad |
| `fix/` | Correccion de bugs |
| `chore/` | Mantenimiento, dependencias |
| `refactor/` | Refactorizacion |
| `docs/` | Documentacion |
| `hotfix/` | Correcciones urgentes |

**Caracteristicas:**
- Vida corta (horas/dias, nunca semanas)
- Se borran despues del merge
- Parten siempre de `main` actualizado

**Ejemplos:**
```
OK:  feat/user-authentication
OK:  fix/webhook-timeout
OK:  chore/update-dependencies
BAD: feature (generico)
BAD: fix-bug (no especifico)
BAD: nueva_funcionalidad (guiones, no underscores)
```

## Flujo Completo (5 Fases)

### Fase 1: Crear Rama
```bash
git checkout main
git pull origin main
git checkout -b feat/nombre-descriptivo
git branch --show-current  # Verificar: NO debe ser "main"
```

### Fase 2: Desarrollo Local
Commits frecuentes con formato:
```bash
git commit -m "tipo: descripcion breve

- Detalle especifico 1
- Detalle especifico 2"
```

Tipos de commit: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`

### Fase 3: Push a GitHub
```bash
git fetch origin
git pull --rebase origin $(git branch --show-current)

# Primera vez:
git push -u origin $(git branch --show-current)

# Subsecuentes:
git push origin $(git branch --show-current)
```

Los cambios van a TU RAMA, NO a main.

### Fase 4: Pull Request

1. Crear PR: base = `main`, compare = tu rama
2. Descripcion completa (que cambia, como probar, riesgos)
3. Esperar checks verdes
4. Merge con **"Squash and merge"** (recomendado)
5. Borrar rama remota

### Fase 5: Limpieza Local
```bash
git checkout main
git pull origin main
git branch -d feat/mi-rama
git fetch --prune
```

## Manejo de Errores

### Bug ANTES del merge
Arreglar en la misma rama, push, PR se actualiza automaticamente.

### Bug DESPUES del merge
Opcion A: `hotfix/fix-critical-bug` (nueva rama + PR urgente)
Opcion B: `git revert -m 1 <hash>` (deshace el merge)

### Conflictos con main
```bash
git checkout feat/mi-rama
git fetch origin
git rebase origin/main
# Resolver conflictos
git add archivo-resuelto
git rebase --continue
git push --force-with-lease origin feat/mi-rama
```

Si te pierdes: `git rebase --abort` y usar merge en vez de rebase.

### "Updates were rejected"
```bash
git pull --rebase origin $(git branch --show-current)
git push origin $(git branch --show-current)
```

## Validaciones de Seguridad

### Archivos NUNCA en Git
```
.env, .env.local, .env*.local
node_modules/, .next/, dist/, build/
*.log, .DS_Store, *.pem, *.key, secrets/
```

### .gitignore Obligatorio
Todo proyecto debe tener .gitignore con las exclusiones anteriores.

## Diagrama de Estados

```
INICIAL:     main: A-B-C
CREAR RAMA:  main: A-B-C  feat/x: (creada)
DESARROLLO:  main: A-B-C  feat/x: D-E-F
PUSH:        GitHub main: A-B-C  GitHub feat/x: D-E-F
PR+MERGE:    GitHub main: A-B-C-G  feat/x: (borrada)
ACTUALIZAR:  Local main: A-B-C-G  feat/x: BORRADA
```
