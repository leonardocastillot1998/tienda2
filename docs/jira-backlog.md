# Backlog Jira (Kanban) — Tienda de Puntos y Recompensas (ClientLoyalty)

Fecha: 2026-04-10

## Alcance y supuestos
- App para **cliente final** (sin rol empleado/administrador en MVP).
- Autenticación mediante **API** con **tokens** (incluye refresh).
- Recompensas mediante **catálogo** (múltiples premios con costos distintos).

## Fuera de alcance (por ahora)
- Inventario, ventas diarias, recibos.
- Panel de administración/empleado.
- Notificaciones push, pagos.

## Definition of Done (DoD) sugerido
- Criterios de aceptación verificados.
- Estados consistentes: loading / error / empty.
- Tokens no se exponen en logs y se eliminan en logout.
- QA manual mínimo: login, ver puntos, ver catálogo, canje.

## Importación a Jira (sin capturar a mano)
- Jira no convierte este Markdown a issues automáticamente.
- Para cargarlo en Jira, usa el CSV en `docs/jira-import.csv`.
- En el asistente de importación, mapea columnas según tu proyecto:
  - Opción 1 (común en company-managed): **Epic Name** + **Epic Link**.
  - Opción 2 (común en team-managed / importador nuevo): **Work item ID** + **Parent**.
- Recomendación: mapea **solo una** de las opciones (Epic Link o Parent) y deja la otra sin mapear.

---

## Épicas e historias

### CL-EP01 — Acceso y sesión segura (tokens)
**Objetivo:** permitir que el cliente se autentique contra la API y mantenga una sesión segura y usable.

#### CL-US-001 — Iniciar sesión (API)
- Historia: Como cliente, quiero iniciar sesión con mis credenciales para acceder a mis puntos y recompensas.
- Criterios de aceptación:
  - Con credenciales válidas, al iniciar sesión entro a la pantalla principal.
  - Con credenciales inválidas, veo un error entendible y permanezco en login.
  - Durante la llamada a la API se muestra loading y se evita el doble envío.
- Etiquetas: MVP, auth, api

#### CL-US-002 — Registro de cuenta (API)
- Historia: Como cliente, quiero crear una cuenta para empezar a acumular y canjear puntos.
- Criterios de aceptación:
  - Si el registro es exitoso, quedo autenticado o soy redirigido a login (definir una sola opción).
  - Si el usuario/email ya existe, veo un mensaje y puedo corregir.
  - Validaciones mínimas de formulario (campos requeridos).
- Etiquetas: MVP, auth, api

#### CL-US-003 — Guardado de sesión
- Historia: Como cliente, quiero que la app recuerde mi sesión para no iniciar sesión cada vez.
- Criterios de aceptación:
  - Si tengo sesión válida, al abrir la app entro directo a la pantalla principal.
  - Si no hay sesión válida, la app me muestra login.
- Etiquetas: MVP, auth

#### CL-US-004 — Cerrar sesión
- Historia: Como cliente, quiero cerrar sesión para proteger mi cuenta en un dispositivo compartido.
- Criterios de aceptación:
  - Al cerrar sesión, se elimina la sesión local y regreso a login.
  - Tras cerrar sesión, no puedo acceder a pantallas protegidas con “back”.
- Etiquetas: MVP, auth, security

#### CL-US-005 — Renovación automática de token (refresh)
- Historia: Como cliente, quiero que mi sesión se mantenga activa sin interrupciones cuando el token expire.
- Criterios de aceptación:
  - Si el access token expira y existe refresh token válido, la app renueva el token y reintenta la operación.
  - Si el refresh token no es válido/expira, la app me redirige a login.
- Etiquetas: MVP, auth, security

#### CL-US-006 — Manejo de token inválido
- Historia: Como cliente, quiero recibir una explicación clara si mi sesión expira o es inválida.
- Criterios de aceptación:
  - Ante un 401/403, la app muestra un mensaje (por ejemplo, “Tu sesión expiró”) y pide reingreso.
  - La app no queda en loop de reintentos.
- Etiquetas: MVP, security, ux


### CL-EP02 — Puntos (saldo e historial)
**Objetivo:** permitir al cliente consultar su saldo y entender cómo se movieron sus puntos.

#### CL-US-020 — Ver saldo de puntos
- Historia: Como cliente, quiero ver mi saldo de puntos actual para saber si puedo canjear recompensas.
- Criterios de aceptación:
  - Al entrar a la pantalla principal, se muestra el saldo vigente obtenido desde la API.
  - Se muestra estado de carga inicial y estado de error si falla.
- Etiquetas: MVP, points, api

#### CL-US-021 — Ver historial de movimientos
- Historia: Como cliente, quiero ver un historial de movimientos (acumulación/canje) para confiar en mi saldo.
- Criterios de aceptación:
  - Se listan movimientos con fecha, concepto y puntos (+/-).
  - Si no hay movimientos, se muestra estado vacío.
- Etiquetas: MVP, points, api

#### CL-US-022 — Actualización manual de datos
- Historia: Como cliente, quiero poder actualizar manualmente mi saldo/historial para ver cambios recientes.
- Criterios de aceptación:
  - Existe una acción de “Actualizar” que vuelve a consultar API.
  - Al finalizar, la UI refleja los nuevos datos.
- Etiquetas: MVP, points, ux

#### CL-US-023 — Último dato conocido (resiliencia)
- Historia: Como cliente, quiero ver el último saldo conocido si no tengo conexión para no quedar bloqueado.
- Criterios de aceptación:
  - Si falla la consulta, se muestra el último dato cacheado (si existe) con indicador “desactualizado”.
  - Si no existe caché, se muestra estado de error con opción de reintentar.
- Etiquetas: Post-MVP, offline, resilience


### CL-EP03 — Catálogo de recompensas y canje
**Objetivo:** permitir explorar recompensas y canjearlas con reglas claras.

#### CL-US-030 — Ver catálogo de recompensas
- Historia: Como cliente, quiero ver el catálogo de recompensas disponibles para elegir en qué gastar mis puntos.
- Criterios de aceptación:
  - Se lista cada recompensa con nombre y costo en puntos.
  - Se maneja estado de carga, vacío y error.
- Etiquetas: MVP, rewards, api

#### CL-US-031 — Ver detalle de recompensa
- Historia: Como cliente, quiero ver el detalle/condiciones de una recompensa para decidir si me conviene.
- Criterios de aceptación:
  - Al seleccionar una recompensa, se muestran detalles y costo.
  - Si la recompensa no está disponible, se informa claramente.
- Etiquetas: MVP, rewards, ux

#### CL-US-032 — Validación de puntos suficientes
- Historia: Como cliente, quiero que la app me indique si tengo puntos suficientes para canjear una recompensa.
- Criterios de aceptación:
  - Si puntos < costo, el canje se muestra deshabilitado y se explica “Te faltan X puntos”.
  - Si puntos >= costo, el canje está habilitado.
- Etiquetas: MVP, rewards, points, ux

#### CL-US-033 — Canjear recompensa (confirmación)
- Historia: Como cliente, quiero canjear una recompensa confirmando la acción para no gastar puntos por error.
- Criterios de aceptación:
  - Antes de canjear, se pide confirmación mostrando costo y saldo resultante.
  - Si la API confirma el canje, se descuenta el saldo y se muestra confirmación.
  - Si falla el canje, se muestra error y no se altera el saldo local.
- Etiquetas: MVP, rewards, api

#### CL-US-034 — Comprobante de canje
- Historia: Como cliente, quiero ver un comprobante (código o folio) del canje para reclamar mi premio en tienda.
- Criterios de aceptación:
  - Tras canjear exitosamente, la app muestra un folio/código asociado.
  - El comprobante queda accesible desde un historial de canjes.
- Etiquetas: Post-MVP, rewards

#### CL-US-035 — Historial de canjes
- Historia: Como cliente, quiero ver mis canjes anteriores para saber qué ya reclamé.
- Criterios de aceptación:
  - Se listan canjes con fecha, recompensa y estado (por ejemplo, “generado”, “entregado”).
  - Estado vacío y errores manejados.
- Etiquetas: Post-MVP, rewards


### CL-EP04 — Visualización de progreso (componentes gráficos)
**Objetivo:** mejorar comprensión del cliente con indicadores visuales de progreso hacia recompensas.

#### CL-US-040 — Progreso hacia la recompensa más cercana
- Historia: Como cliente, quiero ver mi progreso hacia la recompensa que me falta menos para motivarme a seguir acumulando.
- Criterios de aceptación:
  - Se calcula la recompensa “más cercana” (costo mínimo mayor o igual a mi saldo) y se muestra progreso.
  - Si ya puedo canjear alguna recompensa, el progreso refleja “listo para canjear”.
- Etiquetas: MVP, ux, progress

#### CL-US-041 — Componente gráfico reutilizable
- Historia: Como cliente, quiero un indicador visual claro (barra/círculo) para entender rápidamente mi avance.
- Criterios de aceptación:
  - Existe un componente de UI reutilizable para progreso.
  - El componente se ve bien en tamaños de pantalla comunes.
- Etiquetas: MVP, ui

#### CL-US-042 — Mensajes de motivación contextual
- Historia: Como cliente, quiero ver mensajes simples (“Te faltan X puntos”) para saber qué tan cerca estoy.
- Criterios de aceptación:
  - El mensaje se actualiza con el saldo.
  - No muestra valores negativos ni inconsistentes.
- Etiquetas: MVP, ux


### CL-EP05 — Seguridad básica y calidad (técnica)
**Objetivo:** asegurar que el manejo de tokens/datos sea seguro y que la app sea estable.

#### CL-US-050 — Almacenamiento seguro de tokens
- Tipo: Historia técnica
- Historia: Como sistema, quiero guardar tokens de forma segura para reducir riesgo ante accesos al dispositivo.
- Criterios de aceptación:
  - Tokens no se guardan en texto plano en almacenamiento no seguro.
  - En logout, los tokens se eliminan.
- Etiquetas: MVP, security

#### CL-US-051 — Cliente API con manejo centralizado de auth
- Tipo: Historia técnica
- Historia: Como desarrollador, quiero un cliente HTTP con manejo centralizado de headers, errores y refresh para evitar duplicación.
- Criterios de aceptación:
  - Todas las llamadas a API pasan por un punto común que agrega token y maneja 401.
  - Se evitan reintentos infinitos.
- Etiquetas: MVP, api, architecture

#### CL-US-052 — Manejo consistente de estados (loading/error/empty)
- Tipo: Historia técnica
- Historia: Como cliente, quiero que la app sea consistente al cargar datos y ante errores para no confundirme.
- Criterios de aceptación:
  - En pantallas de puntos y recompensas existen estados de carga, error y vacío.
  - Los mensajes de error son entendibles y accionables (reintentar).
- Etiquetas: MVP, ux, quality

#### CL-US-053 — Pruebas mínimas de flujos críticos
- Tipo: Historia técnica
- Historia: Como equipo, quiero pruebas mínimas para evitar regresiones en login, consulta de puntos y canje.
- Criterios de aceptación:
  - Existe al menos 1 prueba por flujo crítico (feliz + error principal).
- Etiquetas: Post-MVP, testing
