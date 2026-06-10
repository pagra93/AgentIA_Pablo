# Context Ledger

Log append-only de pasos significativos en este paquete. Cada entrada es un archivo independiente con el formato:

```
<YYYY-MM-DD>-<HHMMSS>-<agente>.md
```

Ejemplo: `2026-05-14-213045-age-spe-news-research.md`

## Qué se registra aquí

- Generación inicial del paquete (primera entrada, escrita por `age-spe-arc-generator` del arquitecto)
- Pasos editoriales/operativos significativos de los agentes del paquete
- Decisiones tomadas durante un comando (cuando el PM elige una opción concreta)
- Bloqueos identificados (cuando un agente se detiene por falta de información)
- Hallazgos críticos de auditorías o adversariales

## Qué NO se registra

- Lecturas de archivos
- Operaciones triviales
- Cada step interno de un agente (sería ruido)
- Información sensible (credenciales, tokens, contenido confidencial)

## Cómo se escribe

Los agentes que escriben en el ledger usan la skill `ski-context-ledger` (precargada en cada agente que la declara en su `agent.yaml`). El formato de cada entrada se define en la skill.

## Cómo se consulta

Para reanudar trabajo en una sesión nueva:

```bash
# Última entrada
cat $(ls -1t context-ledger/*.md | head -1)

# Últimas 5 entradas
ls -1t context-ledger/*.md | head -5
```

O en Claude Code, leer los 3-5 archivos más recientes para tener contexto rápido sin cargar todo el histórico.

## Reglas

1. **Append-only**: nunca se edita ni borra una entrada. Si una entrada se reveló incorrecta, se añade una NUEVA entrada que la corrige.
2. **Una entrada por paso significativo**, no por cada operación.
3. **Resúmenes, no transcripciones**.
4. **No info sensible**.
5. **Idioma**: español con ortografía correcta (`rul-spanish-orthography`).

## Vacío al inicio

La primera entrada la escribe el generator del arquitecto al crear este paquete. Después, los agentes del paquete añaden entradas conforme trabajan. Si esta carpeta sigue vacía después de varias sesiones de uso, es señal de que los agentes no están aprovechando la skill `ski-context-ledger`.
