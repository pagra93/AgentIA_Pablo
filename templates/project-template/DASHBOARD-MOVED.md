# Dashboard: NO vive aquí

Esta carpeta `templates/project-template/` solía contener un `dashboard/` genérico para proyectos clientes multi-paquete. **Eliminado** el 2026-05-25.

## Razón

El dashboard del arquitecto es **el de PM x10** (`exports/pmx-product/dashboard-template/`). Es el único dashboard oficial del ecosistema. No hay variante "genérica" paralela.

- Cuando se ejecuta `arc deploy pmx-product .`, ese deploy copia el dashboard de PM x10 al proyecto.
- Cuando se ejecuta cualquier otro paquete (`arc deploy newsletter-system .`, `arc deploy marketing-system .`), el deploy NO copia ningún dashboard — solo **añade su área** a `pm/config.json > areas`. El dashboard de PM x10 ya instalado renderiza la nueva área automáticamente en el sidebar.

## Implicación: pmx-product debe desplegarse PRIMERO

Si despliegas `newsletter-system` (o cualquier paquete no-pmx) en un proyecto vacío, su `deploy.sh` aborta con error claro pidiendo que despliegues primero `pmx-product`.

## Qué queda en este project-template

- `.claude/` — placeholder mínimo (settings, etc.)
- `memory/` — placeholder
- `pm/` — placeholder
- `README.md.tmpl` — template del README del proyecto

Estos placeholders solo se usan cuando un paquete necesita inicializar archivos genéricos que NO aporta directamente. En la práctica, `pmx-product/deploy.sh` materializa todo lo necesario sin depender de esta carpeta.

## Historia

- **Antes (2026-05-15 a 2026-05-25)**: el arquitecto tenía un dashboard genérico aquí, pensado para un modelo "multi-paquete con dashboard común no específico". El PM (Pablo) determinó que ese diseño no estaba aprobado y que el dashboard oficial debe ser el de PM x10.
- **Ahora**: dashboard único = PM x10, extensible vía `pm/config.json > areas`. Un solo dashboard, una sola UX, una sola implementación que mantener.
