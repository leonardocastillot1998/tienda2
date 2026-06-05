# tienda / Client Loyalty

Aplicacion Flutter de fidelizacion de clientes conectada a Supabase. La app permite iniciar sesion, registrarse, ver puntos, consultar recompensas, canjear productos, editar el perfil, revisar el historial y administrar productos locales.

## Resumen

El proyecto esta organizado en estas capas principales:

1. `lib/main.dart` inicializa Flutter y Supabase, aplica el tema y abre la pantalla de login.
2. `lib/services/auth_service.dart` centraliza autenticacion, sesion, persistencia local y acceso a datos remotos.
3. `lib/screens/` contiene las pantallas que forman la experiencia de usuario.
4. `lib/theme/prestige_theme.dart` define colores, tipografias y estilos comunes.

## Estructura del proyecto

- [`lib/main.dart`](lib/main.dart)
- [`lib/theme/prestige_theme.dart`](lib/theme/prestige_theme.dart)
- [`lib/services/auth_service.dart`](lib/services/auth_service.dart)
- [`lib/screens/login_page.dart`](lib/screens/login_page.dart)
- [`lib/screens/register_page.dart`](lib/screens/register_page.dart)
- [`lib/screens/home_page.dart`](lib/screens/home_page.dart)
- [`lib/screens/profile_page.dart`](lib/screens/profile_page.dart)
- [`lib/screens/history_page.dart`](lib/screens/history_page.dart)
- [`lib/screens/reward_details_page.dart`](lib/screens/reward_details_page.dart)
- [`lib/screens/purchases_page.dart`](lib/screens/purchases_page.dart)
- [`lib/screens/add_product_page.dart`](lib/screens/add_product_page.dart)

## Punto de entrada

### [`lib/main.dart`](lib/main.dart)

Este archivo:

- inicializa `WidgetsFlutterBinding`;
- configura Supabase con `Supabase.initialize(...)`;
- crea `MyApp`;
- aplica `buildPrestigeTheme()`;
- arranca la app en `LoginPage`.

## Tema visual

### [`lib/theme/prestige_theme.dart`](lib/theme/prestige_theme.dart)

Define la identidad visual de la app:

- paleta clara con acentos negro, azul oscuro y dorado;
- tipografias `Inter` y `Manrope` con `GoogleFonts`;
- estilos globales para `TextField` y `ElevatedButton`;
- `ColorScheme` consistente para Material 3.

## Logica principal

### [`lib/services/auth_service.dart`](lib/services/auth_service.dart)

Este servicio concentra la mayor parte de la logica de negocio.

#### Autenticacion

- `login(...)`: valida usuario y contrasena contra la tabla `usuarios`.
- `register(...)`: crea un usuario nuevo con 20 puntos iniciales.
- `signInWithGitHub()`: inicia OAuth con GitHub.
- `syncOAuthUser()`: sincroniza el usuario OAuth con la tabla `usuarios`.
- `checkSavedSession()`: recupera la sesion guardada en `SharedPreferences`.
- `logout()`: cierra la sesion remota y limpia la sesion local.

#### Perfil

- `getUserProfile(username)`: obtiene nombre, correo, telefono, fecha de nacimiento, direccion y puntos.
- `updateUserProfile(...)`: actualiza los campos editables del perfil.

#### Puntos

- `savePoints(...)`: persiste el nuevo saldo en Supabase.
- `getClosestRewardProgress(currentPoints)`: calcula la recompensa mas cercana disponible.
- `calculateClosestRewardProgress(...)`: version estatica del calculo anterior.
- `calculateRewardProgress(...)`: calcula progreso para una recompensa puntual.

#### Historial local

- `addHistoryEntry(...)`: guarda un movimiento en `SharedPreferences`.
- `getHistory(username)`: lee el historial de un usuario.
- `clearHistory(username)`: borra el historial del usuario.

#### Productos locales

- `addCustomProduct(...)`: agrega un producto creado localmente.
- `getCustomProducts(username)`: lee productos locales.
- `updateCustomProduct(...)`: edita un producto local.
- `deleteCustomProduct(...)`: elimina un producto local.

## Pantallas

### Login

#### [`lib/screens/login_page.dart`](lib/screens/login_page.dart)

Pantalla de acceso principal.

- muestra formulario de usuario y contrasena;
- permite recordar credenciales con `SharedPreferences`;
- verifica si existe una sesion guardada y redirige automaticamente;
- soporta login con GitHub;
- adapta el layout para escritorio y movil.

### Registro

#### [`lib/screens/register_page.dart`](lib/screens/register_page.dart)

- crea una cuenta nueva;
- valida usuario y contrasena;
- redirige al `HomePage` despues del registro exitoso;
- asigna 20 puntos iniciales.

### Home

#### [`lib/screens/home_page.dart`](lib/screens/home_page.dart)

Es la pantalla principal de la experiencia.

- muestra saldo actual de puntos;
- permite un canje rapido fijo desde el panel principal;
- carga el catalogo de productos desde Supabase;
- calcula la recompensa mas cercana con base en los puntos actuales;
- ofrece navegacion inferior entre dashboard, catalogo, historial y perfil;
- abre una vista de compras desde el boton flotante.

### Perfil

#### [`lib/screens/profile_page.dart`](lib/screens/profile_page.dart)

- carga y muestra datos del usuario;
- permite editar nombre, correo, telefono, fecha de nacimiento y direccion;
- guarda cambios en Supabase;
- usa layout responsivo para escritorio y movil.

### Historial

#### [`lib/screens/history_page.dart`](lib/screens/history_page.dart)

- lee el historial local del usuario actual;
- renderiza cada movimiento con imagen, estado, fecha y puntos;
- permite borrar el historial completo con confirmacion;
- acepta imagenes desde URL, Base64 o datos ya normalizados.

### Detalle de recompensa

#### [`lib/screens/reward_details_page.dart`](lib/screens/reward_details_page.dart)

- muestra detalle visual de una recompensa;
- valida si el usuario tiene puntos suficientes;
- confirma el canje antes de ejecutarlo;
- descuenta puntos en Supabase;
- registra el movimiento en el historial local;
- retorna el nuevo saldo al cerrar la pantalla.

### Mis productos

#### [`lib/screens/purchases_page.dart`](lib/screens/purchases_page.dart)

- lista productos personalizados guardados localmente;
- permite editar nombre, precio y puntos por compra;
- permite eliminar productos locales;
- simula una compra y suma puntos al usuario;
- agrega el movimiento al historial local.

### Agregar producto

#### [`lib/screens/add_product_page.dart`](lib/screens/add_product_page.dart)

- crea productos locales nuevos;
- permite seleccionar una imagen desde el equipo con `file_picker`;
- convierte la imagen a Base64 para guardarla en memoria local;
- guarda titulo, precio, puntos e imagen en `SharedPreferences`.

## Flujo de la aplicacion

1. La app arranca en `LoginPage`.
2. Se valida si existe una sesion guardada.
3. Si hay sesion activa, se redirige al `HomePage`.
4. El usuario puede:
   - iniciar sesion con usuario y contrasena;
   - registrarse;
   - autenticar con GitHub;
   - revisar el catalogo de recompensas;
   - abrir el detalle de una recompensa;
   - canjear puntos;
   - consultar el historial;
   - editar su perfil;
   - crear y administrar productos locales.

## Datos y almacenamiento

### Supabase

El proyecto usa la tabla `usuarios` para autenticacion y perfil, y la tabla `productos` para el catalogo de recompensas.

#### `usuarios`

- `username`
- `password`
- `points`
- `email`
- `nombre_completo`
- `numero_de_telefono`
- `fecha_de_nacimiento`
- `address`

#### `productos`

- `title`
- `points`
- `image_url`
- `tag`
- `description`

### Almacenamiento local

Se usa `SharedPreferences` para:

- recordar sesion del usuario;
- guardar credenciales si se activa "remember me";
- almacenar historial por usuario;
- guardar productos personalizados por usuario.

## Lógica importante

### Calculo de recompensas

La app calcula progreso y elegibilidad de canje con dos funciones:

- `calculateClosestRewardProgress(currentPoints, products)`
- `calculateRewardProgress(currentPoints, rewardPoints)`

Estas funciones se usan para:

- mostrar barras de progreso;
- indicar cuanta diferencia falta para canjear;
- resaltar cuando ya existe una recompensa canjeable.

### Historial

Cada canje o compra simulada agrega una entrada con:

- fecha;
- titulo;
- descripcion;
- puntos gastados o ganados;
- imagen;
- estado.

## Dependencias

Definidas en [`pubspec.yaml`](pubspec.yaml):

- `flutter`
- `cupertino_icons`
- `google_fonts`
- `shared_preferences`
- `supabase_flutter`
- `file_picker`

Tambien existe un override local para `app_links` en `packages/app_links`.

## Requisitos

- Flutter instalado.
- Un proyecto Supabase activo.
- Tablas `usuarios` y `productos` creadas en Supabase.

## Instalacion

```bash
flutter pub get
```

## Ejecucion

```bash
flutter run
```

## Pruebas

```bash
flutter test
```

## Pruebas incluidas

- [`test/widget_test.dart`](test/widget_test.dart)
  - valida que la pantalla base se renderice.

- [`test/closest_reward_progress_test.dart`](test/closest_reward_progress_test.dart)
  - valida la logica de calculo de progreso hacia recompensas.

## Recursos

La carpeta `resources/` contiene pantallas de referencia, imagenes y archivos HTML que documentan el diseno y comportamiento esperado de diferentes vistas.

## Observaciones tecnicas

- La URL y la `anon key` de Supabase estan definidas en [`lib/main.dart`](lib/main.dart).
- Las contrasenas se guardan en texto plano dentro de la tabla `usuarios`.
- La opcion "remember me" guarda credenciales locales sin cifrado adicional.
- Hay textos mezclados en ingles y espanol en algunas pantallas.
- El proyecto es multiplataforma, pero conviene validar responsive en pantallas pequenas y escritorio.

## Resumen final

La aplicacion ya tiene una base modular clara:

- autenticacion y persistencia en `AuthService`;
- UI separada por pantallas;
- tema visual global;
- calculo reutilizable para puntos y recompensas;
- historial y productos locales guardados en el dispositivo.

Eso la deja lista para seguir creciendo con mejoras de seguridad, validacion y sincronizacion de datos.

## Evaluación Técnica y de Calidad (QA)

### Compatibilidad y fragmentación

- La app está construida con Flutter, así que la base del proyecto es compatible con Android, iOS, web, Windows, macOS y Linux.
- En el código hay ajustes responsivos en algunas pantallas:
  - `login_page.dart` adapta el layout con un panel lateral en escritorio.
  - `profile_page.dart` usa `LayoutBuilder` para cambiar entre vista en columna y en filas.
  - `history_page.dart` adapta la tarjeta de historial a móvil o escritorio.
- Aun así, no todas las vistas tienen el mismo nivel de adaptación:
  - `home_page.dart` mezcla paneles fijos, grids y navegación inferior, por lo que conviene validar tablets y pantallas pequeñas.
  - `reward_details_page.dart` y `add_product_page.dart` usan layouts más lineales, útiles en móvil, pero necesitan revisión visual en tamaños grandes.
- Recomendación QA:
  - probar Android e iOS en al menos tres tamaños de pantalla,
  - validar orientación vertical y horizontal,
  - revisar cortes de texto, overflow y espacios en tablets.

### Rendimiento y estrés

- La app depende de varias cargas remotas desde Supabase:
  - catálogo de productos,
  - perfil del usuario,
  - progreso de recompensas,
  - historial guardado localmente.
- Hay varios `FutureBuilder` y llamadas de red que se ejecutan al entrar a pantallas clave, por lo que el tiempo de carga depende de la conexión y de la latencia del backend.
- Las imágenes del catálogo y de las recompensas se cargan desde red con `Image.network`, lo que puede afectar la experiencia si el ancho de banda es bajo.
- No hay mediciones automáticas de:
  - tiempo de arranque,
  - FPS,
  - uso de memoria,
  - consumo de batería.
- Recomendación QA:
  - perfilar con Flutter DevTools,
  - medir tiempos de carga en 3G/4G y Wi-Fi,
  - observar memoria al navegar repetidamente entre catálogo, detalle e historial.

### Comportamiento de red

- La lógica de autenticación y datos usa bloques `try/catch`, así que la app intenta evitar cierres inesperados ante errores de red.
- En varios métodos, cuando falla una consulta, el código devuelve `null`, una lista vacía o ignora el error para mantener la UI viva.
- Esto hace que la app sea tolerante a fallos, pero también puede ocultar el problema real si la red está inestable.
- No existe un modo offline completo:
  - el catálogo depende de Supabase,
  - el perfil depende de Supabase,
  - el canje de puntos depende de Supabase,
  - el historial y productos locales sí se leen desde `SharedPreferences`.
- Recomendación QA:
  - probar pérdida total de conexión,
  - probar latencia alta y reconexión,
  - mostrar mensajes de error más explícitos cuando una carga remota falle,
  - considerar caché local para catálogo y perfil si se quiere soporte offline parcial.

### Seguridad

- La comunicación con Supabase se realiza sobre HTTPS, lo cual es correcto para transporte seguro.
- Sin embargo, hay puntos importantes a mejorar:
  - las contraseñas se almacenan en texto plano en la tabla `usuarios`,
  - la opción `remember me` guarda credenciales en `SharedPreferences` sin cifrado adicional,
  - la `anon key` está embebida en el cliente, lo cual es normal en Supabase, pero no debe tratarse como un secreto de backend,
  - no se ve un cifrado local explícito para datos sensibles.
- Los datos que maneja la app incluyen:
  - usuario,
  - email,
  - teléfono,
  - fecha de nacimiento,
  - dirección,
  - puntos,
  - historial de canjes.
- No aparecen datos bancarios en el código, pero sí hay información personal que debe tratarse con cuidado.
- Recomendación QA:
  - reemplazar contraseñas planas por autenticación real de Supabase Auth o un esquema con hash seguro en backend,
  - evitar guardar contraseñas en preferencias locales,
  - evaluar almacenamiento cifrado para datos sensibles,
  - revisar políticas RLS en Supabase para limitar accesos por usuario,
  - asegurar que todas las consultas dependan de la sesión correcta del usuario.

### Conclusión QA

- La base técnica es sólida para una app Flutter multiplataforma.
- La mayor fortaleza actual es la estructura modular y el uso de Supabase.
- Los principales riesgos están en:
  - seguridad de credenciales,
  - ausencia de modo offline,
  - falta de métricas de rendimiento,
  - cobertura responsiva desigual entre pantallas.
- Para un siguiente paso de calidad, conviene priorizar seguridad y manejo de red antes de escalar funcionalidades nuevas.
