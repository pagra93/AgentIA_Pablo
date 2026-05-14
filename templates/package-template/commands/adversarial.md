---
description: "Revisión adversarial dentro del paquete. Cynic desafía premisas; Boundary-Walker explora bordes. Read-only. Ejecuta age-sup-cynic + age-sup-boundary-walker (locales del paquete)."
---

# /adversarial — Revisión adversarial del paquete

Invoca a los dos supervisores adversariales del paquete en secuencia para desafiar una decisión, propuesta o estado.

A diferencia de `/arc-adversarial` (que opera a nivel meta-sistema), este comando opera **dentro del paquete**: cuestiona diseños internos del dominio, no decisiones de arquitectura.

**Tipo de operación**: read-only. Genera dos reportes locales. No modifica nada.

## Sintaxis

```
/adversarial                                → diálogo interactivo
/adversarial <objeto>                       → objeto explícito (texto libre)
/adversarial --propuesta="<descripción>"    → desafiar una propuesta concreta
/adversarial --story=<HU-ID>                → desafiar una HU concreta (si el paquete usa stories)
/adversarial --feature=<nombre>             → desafiar el diseño de una feature
```

## Qué hace

### 1. `age-sup-cynic` (primero)

Desafía cínicamente la propuesta. Técnicas: Socratic, Devil's Advocate, Five Whys.

Output: reporte con preguntas incómodas, asunciones no verificadas, posibles fallas de razonamiento.

### 2. `age-sup-boundary-walker` (segundo)

Explora bordes y casos extremos. Técnicas: Pre-Mortem, Inversion, Reverse Assumption.

Output: reporte con casos extremos no considerados, modos de fallo plausibles, asunciones limitantes.

## Output consolidado

Reportes guardados en `docs/general/adversarial/<YYYY-MM-DD>-<objeto-slug>.md`:

```markdown
# Adversarial Review (Local) — <objeto> — <fecha>

## Cynic (premisas desafiadas)
...

## Boundary-Walker (bordes y casos extremos)
...

## Síntesis: temas críticos para el PM
1. ...
2. ...

## Notas
(Ambos reportes son propuestas, no veredictos. El PM decide qué incorporar.)
```

## Cuándo invocar

- Antes de decisiones importantes del dominio (ej. estructura de un artefacto canónico, splitting de una HU compleja)
- Cuando un diseño parece "demasiado fácil"
- Después de un fallo significativo en el dominio del paquete
- Antes de releases o cambios sustanciales

## Diferencia con `/arc-adversarial`

| | `/adversarial` (local) | `/arc-adversarial` (arquitecto) |
|---|---|---|
| **Scope** | Dentro del paquete (este dominio) | Meta-sistema (arquitecto y/o paquetes) |
| **Invocador** | PM trabajando en el paquete | PM trabajando en el arquitecto |
| **Agentes** | `age-sup-cynic` + `age-sup-boundary-walker` (locales) | `age-sup-arc-cynic` + `age-sup-arc-boundary-walker` |
| **Output** | `docs/general/adversarial/` del paquete | `docs/architect/adversarial/` del arquitecto |

## Reglas

- **Adversarial, no destructivo**: estresar el diseño, no desmotivar.
- **No bloqueante**: el PM decide qué incorporar de los reportes.
- **No se invoca en bucle**: una ronda contundente > cinco rondas suaves.

## Limitaciones

- Cynic y boundary-walker comparten el modelo (Claude). Pueden tener puntos ciegos compartidos. Para temas críticos, complementar con revisión humana o invocar primero `/arc-adversarial` (perspectiva meta) y luego este (perspectiva dominio).
- No analizan código: para revisión de código usar `/code-review`.
