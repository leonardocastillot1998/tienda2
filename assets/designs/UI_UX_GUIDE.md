# Guía de UI/UX y UI Kit: The Prestige Exchange

Este documento define las bases de diseño de interfaces de usuario (UI) y la experiencia de usuario (UX) para el proyecto, inspirado en las pautas establecidas en el diseño *The Prestige Exchange*.

## 1. Visión UX y "North Star"

**North Star: "El Conserje Digital"**
La experiencia de la aplicación se aleja de una utilidad transaccional básica para ofrecer una **curaduría premium**. Buscamos que el usuario sienta que interactúa dentro de una sala lounge de alta gama.

Para lograr esto, la interfaz utiliza:
*   **Asimetría Intencional y Espaciado Editorial:** Se rompen los diseños de cajas rígidas tradicionales en favor de espacios amplios.
*   **Jerarquía Textual Dramática:** Contraste fuerte entre tamaños de texto para celebrar la información clave (por ejemplo, el saldo o puntos del usuario).
*   **Capas de "Cristal" (Glassmorphism):** Uso de superposiciones y desenfoques para dar sensación de profundidad y sofisticación artesanal.

---

## 2. Guía de Estilos (UI Kit)

### 2.1. Colores y Tonos
Utilizamos una paleta profunda donde la "estabilidad" (Azul Marino/Navy) se encuentra con la "aspiración" (Dorado/Gold).

#### Paleta Principal
*   **Navy (Primary Container):** `#0d1c32` - Utilizado para fondos de botones secundarios, cabeceras y elementos de confianza. Texto sobre este fondo: `#d6e3ff` (On Primary Fixed).
*   **Vibrant Gold (Secondary Container):** `#feb700` - El color del "premio". Usado para botones principales (CTAs). Texto sobre este fondo: `#6b4b00` (On Secondary Container).
*   **Gold Suave (Secondary Fixed):** `#ffdea8` - Usado para chips de selección.

#### Capas de Superficie (Fondos)
La UI se concibe como una serie de capas físicas apiladas:
*   **Base (`surface`):** `#f7f9fb` - El lienzo principal o fondo base de la app.
*   **Agrupación (`surface-container-low`):** `#f2f4f6` - Usado para agrupar contenido relacionado.
*   **Elevación (`surface-container-lowest`):** `#ffffff` - Reservado para tarjetas de alta prioridad o elementos interactivos.
*   **Texto Principal (`on_surface`):** `#191c1e` - Nunca usar negro puro (#000000) para mantener un aspecto suave y premium.

#### Gradientes y Materiales
*   **Gradiente Signature:** Para CTAs primarios y balances de puntos, usar un gradiente lineal de `#000000` a `#0d1c32` a un ángulo de 135°.
*   **Cristal (Glassmorphism):** Las barras de navegación flotantes o modales usan fondos semitransparentes (`surface-container-lowest`) con `backdrop-filter: blur(20px)`.

### 2.2. Tipografía
Se emplea una estrategia de doble fuente para balancear personalidad y extrema legibilidad:

*   **Títulos y Displays (Manrope):** La voz de la marca. Sus formas geométricas transmiten modernidad y calidad premium. (Ej. `display-lg` para balances, `headline-md` para categorías).
*   **Cuerpo y Etiquetas (Inter):** La capa de información. Utilizada para detalles técnicos, descripciones y letra pequeña. Su excelente legibilidad en tamaños pequeños la hace ideal (`body-sm`).

### 2.3. Elevación y Profundidad
No se usan sombras de caída tradicionales. La profundidad se logra mediante la luz y el tono.

*   **Regla de "Sin Líneas" (No-Line):** Prohibido el uso de bordes sólidos de 1px para seccionar. La separación se hace mediante el cambio de fondo de las superficies. Si un borde es estrictamente necesario, usar un "Borde Fantasma" (color `outline-variant` al 15% de opacidad).
*   **Sombras Ambientales:** Para elementos flotantes, usar sombras muy difusas: `blur: 32px`, `spread: -4px`, opacidad de 6% del color `on-surface`.

### 2.4. Componentes Clave

*   **Botones (Momento de Recompensa):**
    *   *Primario:* Fondo Dorado (`#feb700`) con texto oscuro (`#6b4b00`). Forma tipo "píldora" (redondeado total). Al presionarse, la escala debe reducirse a 0.98 para simular resistencia física.
    *   *Secundario:* Fondo Marino (`#0d1c32`) con texto claro (`#d6e3ff`).
*   **Tarjetas (Showcase de Productos):**
    *   Sin líneas divisorias. Separar imágenes de descripciones con márgenes amplios (ej. 1.5rem o 24px) o cambios sutiles de fondo.
    *   Bordes redondeados grandes: `1rem` (lg) para tarjetas normales y `1.5rem` (xl) para banners.
*   **Chips (Filtros y Estados):**
    *   Selección: Fondo `#ffdea8` con un borde fantasma de 2px.
    *   Etiquetas Especiales (Ej. "Exclusivo"): Fondo Marino (`#0d1c32`) con texto muy pequeño (`label-sm`).
*   **Campos de Entrada (Inputs):**
    *   Limpios y minimalistas: Sin color de fondo, solo una línea inferior ("Borde Fantasma" al 20%). Al estar activos, la línea cambia a color Dorado y crece a 2px.

---

## 3. Resumen de Buenas y Malas Prácticas

**✔️ QUÉ HACER:**
*   Utilizar diseños asimétricos (ej. imágenes sangrando por los bordes).
*   Priorizar el espacio en blanco (whitespace).
*   Usar el dorado con moderación como acento de "recompensa".

**❌ QUÉ NO HACER:**
*   Usar bordes sólidos de 1px para dividir contenido (usar márgenes de 16px en su lugar).
*   Usar colores negros puros para textos.
*   Emplear sombras estándar (Material Design clásico); usar en su lugar sombras difusas e imperceptibles.
