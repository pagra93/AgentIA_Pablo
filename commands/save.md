---
description: "Commit y push a GitHub de forma segura. Valida rama, detecta archivos sensibles, crea commit formateado, sincroniza con remoto."
---

# /save — Commit y Push a GitHub

Ejecuta el proceso completo: validar rama, detectar archivos sensibles, crear commit, push a GitHub.

## Cuando Usar

- Completaste una feature o fase de trabajo
- Terminaste una sesion de desarrollo
- Quieres guardar antes de cambiar de tarea

## Cuando NO Usar

- Trabajo incompleto (usa `git stash`)
- Estas en rama `main` (crea rama primero)
- No has probado que funciona
- Hay archivos sensibles sin .gitignore

## Proceso

### Paso 0: Pre-Validacion Critica

Verificar rama actual. Si es `main`, ABORTAR:

```
ERROR: Estas en rama 'main'. NUNCA commits directos a main.
Opciones:
1. git checkout -b feat/nombre-descriptivo
2. git stash && git checkout feat/mi-rama && git stash pop
```

### Paso 1: Verificar Cambios

Mostrar `git status --short` y `git diff --stat`.
Preguntar: "Estos son los cambios que quieres guardar?"

### Paso 2: Validar Archivos Sensibles

Buscar `.env`, `.env.local`, `secrets/`, `*.pem`, `*.key` en los cambios.
Si se detectan: advertir y pedir confirmacion explicita.

### Paso 3: Anadir Cambios

```bash
git add .
git status --short  # Mostrar staging
```

### Paso 4: Crear Commit

1. Detectar tipo sugerido desde el nombre de rama:
   - `feat/*` -> `feat:`
   - `fix/*` -> `fix:`
   - `chore/*` -> `chore:`
   - `hotfix/*` -> `hotfix:`

2. Pedir descripcion breve
3. Opcionalmente pedir detalles (bullet points)
4. Crear commit formateado: `tipo: descripcion`

### Paso 5: Sincronizar con GitHub

```bash
git fetch origin

# Si rama existe en remoto:
git pull --rebase origin $BRANCH
git push origin $BRANCH

# Si rama es nueva:
git push -u origin $BRANCH
```

### Paso 6: Confirmacion Final

Mostrar resumen:
```
Rama:    feat/user-profile
Commit:  feat: add user profile page
Remoto:  origin/feat/user-profile

Proximos pasos:
1. /review — si no lo has hecho aun (tests, QA, docs)
2. Crear PR en GitHub
3. Esperar checks verdes
4. Mergear con "Squash and merge"
5. git checkout main && git pull && git branch -d rama
```

### Recordatorio de /review

Despues del resumen, SIEMPRE preguntar:

"¿Has ejecutado /review para esta feature? Si no:
- No hay tests verificados
- No hay code review
- No hay QA audit
- No se actualiza PROJECT_KNOWLEDGE.md
- No se genera documentacion de la feature

¿Quieres ejecutar /review ahora antes de crear el PR?"

## Manejo de Errores

| Error | Accion |
|-------|--------|
| En main | ABORTAR. Crear rama primero. |
| Sin cambios | Informar y salir. |
| Archivos sensibles | Advertir, pedir confirmacion. |
| Conflictos | Abortar con instrucciones para resolver. |
| Push rechazado | Intentar `git pull --rebase`. |
| Mensaje vacio | Solicitar de nuevo. |

## Importante

Este command NO hace:
- Crear Pull Request (se hace en GitHub o con `gh pr create`)
- Mergear a main (se hace via PR)
- Actualizar main local (despues del merge)
- Borrar ramas (despues del merge)

Este command SI hace:
- Validar que NO estas en main
- Detectar archivos sensibles
- Crear commit con formato correcto
- Sincronizar con GitHub
- Dar el siguiente paso claro
