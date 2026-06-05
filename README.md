# tienda / Client Loyalty

Aplicación Flutter de fidelización de clientes conectada a Supabase. La app permite iniciar sesión, registrarse, ver el saldo de puntos, consultar recompensas, canjear productos, editar el perfil y revisar el historial de movimientos.

## Resumen del proyecto

Este proyecto está organizado alrededor de tres capas principales:

1. `lib/main.dart` inicializa Flutter, configura Supabase y abre la pantalla de login.
2. `lib/services/auth_service.dart` concentra la lógica de autenticación, sesión, persistencia local y acceso a datos remotos.
3. `lib/screens/` contiene las pantallas principales de la experiencia de usuario.

## Tecnologías usadas

- Flutter
- Dart 3.11+
- Supabase Flutter
- Shared Preferences
- Google Fonts
- File Picker

## Estructura principal

### Punto de entrada

- [`lib/main.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/lib/main.dart)
  - Inicializa Supabase con `Supabase.initialize(...)`.
  - Crea `MyApp`.
  - Aplica el tema visual `buildPrestigeTheme()`.
  - Arranca en `LoginPage`.

### Tema visual

- [`lib/theme/prestige_theme.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/lib/theme/prestige_theme.dart)
  - Define la paleta de colores principal.
  - Configura tipografías con `GoogleFonts`.
  - Personaliza campos de texto y botones para mantener una apariencia consistente.

### Servicio de autenticación y datos

- [`lib/services/auth_service.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/lib/services/auth_service.dart)
  - Inicio de sesión con usuario y contraseña.
  - Registro de usuarios.
  - Login con GitHub vía OAuth.
  - Persistencia de sesión local con `SharedPreferences`.
  - Lectura y actualización de perfil.
  - Guardado de puntos en Supabase.
  - Historial local por usuario.
  - Productos personalizados locales por usuario.
  - Cálculo de progreso hacia la recompensa más cercana.

## Pantallas

### Login

- [`lib/screens/login_page.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/lib/screens/login_page.dart)
  - Formulario de acceso con usuario y contraseña.
  - Opción de recordar credenciales.
  - Inicio de sesión con GitHub.
  - Verificación automática de sesión guardada.

### Registro

- [`lib/screens/register_page.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/lib/screens/register_page.dart)
  - Permite crear una cuenta nueva.
  - Guarda sesión después del registro.

### Home

- [`lib/screens/home_page.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/lib/screens/home_page.dart)
  - Vista principal de la app.
  - Muestra saldo actual de puntos.
  - Incluye navegación inferior entre Dashboard, Catálogo, Historial y Perfil.
  - Permite canjear rápidamente una recompensa fija.
  - Carga el catálogo desde Supabase.
  - Calcula la recompensa más cercana a partir de los puntos del usuario.

### Perfil

- [`lib/screens/profile_page.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/lib/screens/profile_page.dart)
  - Edita nombre, correo, teléfono, fecha de nacimiento y dirección.
  - Muestra los puntos disponibles.
  - Guarda cambios en Supabase.

### Historial

- [`lib/screens/history_page.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/lib/screens/history_page.dart)
  - Lee el historial local del usuario.
  - Renderiza cada movimiento con imagen, estado, fecha y puntos gastados.

### Detalle de recompensa

- [`lib/screens/reward_details_page.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/lib/screens/reward_details_page.dart)
  - Muestra información ampliada de una recompensa.
  - Calcula si el usuario puede canjearla.
  - Confirma el canje antes de descontar puntos.
  - Registra la operación en el historial.

### Mis productos

- [`lib/screens/purchases_page.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/lib/screens/purchases_page.dart)
  - Lista productos personalizados guardados localmente.
  - Permite simular una compra y sumar puntos.
  - Agrega el movimiento al historial.

### Agregar producto

- [`lib/screens/add_product_page.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/lib/screens/add_product_page.dart)
  - Formulario para crear un producto local.
  - Permite seleccionar una imagen desde el equipo.
  - Convierte la imagen a Base64 para guardarla en preferencias locales.

## Flujo de la aplicación

1. La app inicia en login.
2. Se verifica si existe una sesión guardada en `SharedPreferences`.
3. Si hay sesión activa, se redirige al `HomePage`.
4. El usuario puede:
   - iniciar sesión con usuario/contraseña,
   - registrarse,
   - conectarse con GitHub,
   - revisar catálogo de recompensas,
   - abrir detalle de una recompensa,
   - canjear puntos,
   - consultar historial,
   - editar perfil,
   - crear productos locales.

## Datos y almacenamiento

### Supabase

La app usa dos tablas principales:

- `usuarios`
  - `username`
  - `password`
  - `points`
  - `email`
  - `nombre_completo`
  - `numero_de_telefono`
  - `fecha_de_nacimiento`
  - `address`

- `productos`
  - `title`
  - `points`
  - `image_url`
  - `tag`
  - `description`

### Almacenamiento local

Se usa `SharedPreferences` para:

- recordar sesión del usuario,
- guardar credenciales si el usuario activa "Remember me",
- almacenar historial por usuario,
- guardar productos personalizados por usuario.

## Lógica importante

### Cálculo de recompensas

En `AuthService` existen dos métodos clave:

- `calculateClosestRewardProgress(currentPoints, products)`
  - ordena los productos por puntos,
  - busca la recompensa más cercana,
  - calcula progreso, puntos faltantes y estado listo/no listo.

- `calculateRewardProgress(currentPoints, rewardPoints)`
  - calcula el progreso de un producto específico.

Estas funciones son usadas por el dashboard, el catálogo y la pantalla de detalle para mostrar barras de progreso y mensajes dinámicos.

### Historial

Cada canje o compra simulada agrega una entrada con:

- fecha,
- título,
- descripción,
- puntos gastados o ganados,
- imagen,
- estado.

## Configuración

### Requisitos

- Flutter instalado.
- Un proyecto Supabase activo.
- Tablas `usuarios` y `productos` creadas en Supabase.

### Instalación

```bash
flutter pub get o flutter run -d chrome --web-port 3000
```

### Ejecución

```bash
flutter run
```

### Pruebas

```bash
flutter test
```

## Pruebas incluidas

- [`test/widget_test.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/test/widget_test.dart)
  - Verifica que se renderice la pantalla de login.

- [`test/closest_reward_progress_test.dart`](C:/Users/Asus/Desktop/Nueva carpeta (6)/tienda2-main/test/closest_reward_progress_test.dart)
  - Valida la lógica de cálculo de progreso de recompensas.

## Recursos del proyecto

La carpeta `resources/` contiene imágenes y archivos HTML de referencia para distintas pantallas y diseños. Sirve como documentación visual del producto.

## Observaciones

- La URL y la `anon key` de Supabase están definidas en `lib/main.dart`.
- El proyecto mezcla textos en español e inglés en algunas pantallas; eso refleja el estado actual del código.
- Si quieres llevar este proyecto a producción, conviene mover credenciales sensibles a variables de entorno.

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
