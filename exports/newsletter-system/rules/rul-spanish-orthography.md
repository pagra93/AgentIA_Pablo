---
name: rul-spanish-orthography
description: When generating content in Spanish (markdown files, stories, PRDs, JTBDs, documentation, commit messages, user-facing text). Enforces proper Spanish orthography with accents, ñ, and punctuation marks.
---

# Spanish Orthography Rule

When writing any content in Spanish — responses, markdown files, stories, PRDs, JTBDs, commit messages, documentation — ALWAYS use proper Spanish characters:

- **Accented vowels**: á, é, í, ó, ú (and their capitals: Á, É, Í, Ó, Ú)
- **Ñ**: ñ, Ñ
- **Question/exclamation marks**: ¿...?, ¡...!
- **Diaeresis**: ü, Ü (for words like pingüino)

## Rationale

UTF-8 is universal. All modern editors, terminals, git, and markdown renderers handle Spanish characters correctly. There is NO reason to strip accents for "safety" or "compatibility." Stripping accents makes text harder to read, less professional, and grammatically incorrect.

## Examples

| Wrong (no accents) | Correct (proper Spanish) |
|--------------------|---------------------------|
| analisis           | análisis                  |
| energia            | energía                   |
| Espana             | España                    |
| como?              | ¿cómo?                    |
| tecnologia         | tecnología                |
| dispositivos       | dispositivos (no change)  |
| usuario            | usuario (no change)       |
| informacion        | información               |
| configuracion      | configuración             |
| autenticacion      | autenticación             |
| creacion           | creación                  |
| decision           | decisión                  |
| funcion            | función                   |
| version            | versión                   |
| seccion            | sección                   |
| categorias         | categorías                |
| deberia            | debería                   |
| tambien            | también                   |
| asi                | así                       |
| aqui               | aquí                      |
| mas                | más                       |
| despues            | después                   |
| segun              | según                     |
| ademas             | además                    |
| diseno             | diseño                    |
| ano                | año                       |
| pequena            | pequeña                   |

## Scope

Applies to:
- All markdown files (stories, PRDs, JTBDs, architecture docs)
- CLAUDE.md, PROJECT_KNOWLEDGE.md, project-registry.md content
- Commit messages (when in Spanish)
- User-facing text in chat responses
- Comments in code (when in Spanish)

Does NOT apply to:
- Variable names, function names, class names, file names (always in English)
- Technical terms with English convention (e.g., "frontend", "endpoint")
- Code identifiers
