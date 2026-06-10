---
name: kno-security-review
description: "Metodología de revisión de seguridad a nivel de cambio de código: clases de vulnerabilidad, rúbrica de severidad, procedimiento de red-team y cuándo recomendar herramientas reales. La usa el code-reviewer en su pasada. No reinventa análisis estático — guía el juicio y recomienda la herramienta del stack."
license: MIT
user-invocable: false
metadata:
  author: agent-architect
  version: "1.0.0"
  category: security
  priority: high
  source: "Inspirado en la capa de seguridad de affaan-m/ECC (security-reviewer + red-team), adaptado al modelo curado del arquitecto"
---

# Security Review — Revisión de seguridad a nivel de cambio

Esta es la metodología que el **code-reviewer** aplica en su pasada de seguridad sobre los cambios de un
PR/feature. Es **a nivel de cambio** ("¿este código introduce una vulnerabilidad?"), complementaria al
checklist a nivel de proyecto de `ski-unknown-unknowns/references/security.md` ("¿qué nos falta en todo el
sistema?"). No las dupliques: si una preocupación es de proyecto, deriva a unknown-unknowns.

**Principio (model-vs-code)**: NO reimplementes un analizador estático. El LLM hace **revisión guiada por
checklist + red-team de juicio**; para lo determinista (CVEs de dependencias, patrones sintácticos),
**recomienda correr la herramienta real** del stack (ver abajo). Es más barato, más fiable y auditable.

---

## Clases de vulnerabilidad (checklist de revisión)

Por cada cambio, revisa estas clases. Marca solo lo que **el diff introduce o toca** (cirugía, no auditoría total).

### 1. Inyección
- SQL/NoSQL injection vía queries construidas con concatenación o interpolación (incluso con ORM, las raw queries se cuelan).
- Command injection (`exec`, `system`, `child_process` con input no saneado).
- Template/SSTI, LDAP, XPath injection.

### 2. AuthN / AuthZ
- Endpoint nuevo **sin check de permisos** en servidor (no basta ocultar en UI).
- **IDOR**: IDs secuenciales/predecibles que exponen datos de otros usuarios; falta de check de ownership.
- JWT en `localStorage` (robable por XSS); tokens sin expiración/rotación.
- Falta de rate-limiting en login / endpoints sensibles.

### 3. Secretos y datos sensibles
- Secretos hardcodeados, API keys en cliente o en el diff/commit.
- Logs con PII, passwords o tokens.
- PII sin cifrar; datos sensibles en cache sin TTL.

### 4. XSS / output
- Contenido de usuario renderizado sin sanitizar (`innerHTML`, `dangerouslySetInnerHTML`, templates sin escape).
- Falta de CSP donde aplique.

### 5. Validación y entrada
- Confiar en validación de cliente (falta validación en servidor).
- Mass assignment (aceptar todos los campos del body).
- Falta de límites de tamaño (request, upload) → DoS por agotamiento.
- Uploads sin validar tipo/tamaño → ficheros maliciosos.

### 6. SSRF / acceso a recursos
- Peticiones a URLs controladas por el usuario sin allow-list.
- Path traversal en acceso a ficheros (`../`).

### 7. Deserialización y config
- Deserialización insegura de input no confiable.
- CORS wildcard, debug/stack traces expuestos, headers de seguridad ausentes (HSTS, X-Frame-Options).

### 8. Dependencias
- Paquete nuevo/actualizado con CVE conocido. → **recomendar `npm audit` / `pip-audit` / `cargo audit`** (no juzgarlo a ojo).
- Falta de verificación de firma en webhooks (Stripe, GitHub…).

---

## Rúbrica de severidad

| Severidad | Criterio | Acción |
|---|---|---|
| **Crítica** | Explotable remotamente, sin auth, con impacto en datos/RCE (SQLi, RCE, auth bypass, secreto expuesto en prod) | **Bloquea el merge.** REQUEST CHANGES. |
| **Alta** | Explotable con condiciones (IDOR, XSS almacenado, falta de authz en endpoint) | Bloquea salvo aceptación explícita del PM con justificación. |
| **Media** | Defensa en profundidad ausente (rate-limit, headers, validación redundante) | Reportar; arreglar pronto. |
| **Baja / Nota** | Buenas prácticas, hardening menor | Mencionar en el reporte. |

Para cada hallazgo: **clase, ubicación (archivo:línea), severidad, por qué es explotable, y el fix concreto.**

---

## Red-team (mentalidad de atacante)

Antes de aprobar, dedica una pasada corta a **intentar romperlo**, no solo a leerlo:
- "Si fuera un usuario malicioso, ¿qué input rompe esto?" (vacío, gigante, con payload, con caracteres de control).
- "¿Puedo acceder a datos de otro usuario cambiando un ID?"
- "¿Qué pasa si me salto el cliente y llamo la API directa con campos extra?"
- "¿Hay algún camino que no pase por el check de auth?"

Aplica el red-team **con prioridad a los hallazgos de severidad Alta/Crítica**. Si un hallazgo no resiste un
intento de explotación plausible, súbele la confianza; si no encuentras cómo explotarlo, dilo (`rul-fail-loud`:
no afirmes "seguro", di "no encontré un vector, pero no lo descarto").

---

## Cuándo recomendar herramientas reales (no reinventar)

El reviewer **recomienda correr**, según el stack, en vez de simular el análisis:
- **Dependencias/CVEs**: `npm audit`, `pnpm audit`, `pip-audit`, `cargo audit`, `govulncheck`.
- **SAST**: `semgrep` (multi-lenguaje), `bandit` (Python), `gosec` (Go), `brakeman` (Rails).
- **Secretos**: `gitleaks` / `trufflehog` sobre el historial.
Si el proyecto no los tiene configurados, propónlo como mejora (no como bloqueo del PR salvo severidad Crítica).

---

## Salida (integración con el code-reviewer)

La pasada de seguridad se integra en el veredicto del code-reviewer:
- **Hallazgos por severidad** (tabla), cada uno con fix.
- Un **bloqueo** (REQUEST CHANGES) si hay Crítica, o Alta no aceptada.
- Recomendaciones de herramientas a correr.
- Si no hay hallazgos: declarar **qué clases se revisaron** (no un "seguro" vacío — `rul-fail-loud`).

## Relación con otras piezas
- `ski-unknown-unknowns/references/security.md` — checklist a nivel de **proyecto** (complementario).
- `rul-fail-loud` — nunca afirmar "seguro"; declarar alcance y vectores no descartados.
- `rul-model-vs-code` — el escaneo determinista es de herramientas, no del LLM.
