# newsletter-system — Memory Index

Memoria persistente del paquete. Una entrada por archivo en este directorio, indexada aquí.

Tipos de memoria (heredados del sistema general):

- `user/` — preferencias del PM, modo de trabajo, contexto personal
- `feedback/` — correcciones aceptadas, validaciones de aproximación
- `project/` — decisiones del dominio, motivaciones
- `reference/` — punteros a recursos externos relevantes

**Vacío en estado inicial.** Las entradas se irán creando conforme el paquete se use.

## Notas

- Esta memoria es **del paquete**, no del proyecto cliente donde se despliega. Cada proyecto cliente tiene su propia memoria.
- Las decisiones de diseño del paquete (por qué tal agente hace tal cosa, qué patrón se siguió) van en `project/`.
- Las preferencias del PM aplicables a este paquete (cuando trabaja en este dominio) van en `user/`.
