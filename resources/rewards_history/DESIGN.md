# Design System Specification: The Prestige Exchange

## 1. Overview & Creative North Star
**North Star: "The Digital Concierge"**
The objective of this design system is to move the loyalty points experience away from "transactional utility" and toward "premium curation." We are building a digital environment that feels like a high-end physical lounge. 

To achieve this, we move beyond the rigid, boxy layouts of standard apps. We embrace **Intentional Asymmetry** and **Editorial Spacing**. By utilizing dramatic typography scales and overlapping "glass" layers, we create a sense of bespoke craftsmanship. The interface shouldn't just show a balance; it should celebrate the user's status through depth, light, and motion.

---

## 2. Colors: Tonal Depth & Soul
We use a sophisticated palette where "stability" (Navy) meets "aspiration" (Gold). 

### The "No-Line" Rule
**Prohibit 1px solid borders for sectioning.** Boundaries are defined strictly through background shifts. A `surface-container-low` card sitting on a `surface` background provides all the definition needed. If a border is essential for accessibility, use the **Ghost Border** (the `outline-variant` token at 15% opacity).

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked, physical layers. 
*   **Base Layer:** `surface` (#f7f9fb) – The canvas.
*   **Secondary Sections:** `surface-container-low` (#f2f4f6) – Used for grouping related content.
*   **Elevated Content:** `surface-container-lowest` (#ffffff) – Reserved for high-priority cards or interactive elements.

### The "Glass & Gradient" Rule
To elevate the "Vibrant Gold" beyond a flat yellow:
*   **Signature Textures:** For primary CTAs and Point Balance headers, use a linear gradient: `primary` (#000000) to `primary-container` (#0d1c32) at a 135° angle.
*   **Glassmorphism:** Floating navigation bars or modal headers must use a semi-transparent `surface-container-lowest` with a `backdrop-filter: blur(20px)`. This integrates the UI rather than "pasting" it on.

---

## 3. Typography: The Editorial Voice
We use a dual-font strategy to balance character with extreme readability.

*   **Display & Headlines (Manrope):** Our "Brand Voice." The wide apertures and geometric forms of Manrope convey a modern, premium feel. Use `display-lg` for point balances and `headline-md` for category titles.
*   **Body & Labels (Inter):** Our "Information Layer." Inter is used for technical details, item descriptions, and fine print. Its high x-height ensures readability at small scales (`body-sm`).

**Hierarchy Guideline:** Use high contrast in scale. A `display-lg` point value should sit near a `label-md` "Points Available" tag to create an intentional, high-fashion editorial hierarchy.

---

## 4. Elevation & Depth: Tonal Layering
Traditional drop shadows are too "heavy" for a premium store. We use light and tone to imply height.

*   **Layering Principle:** Instead of a shadow, place a `surface-container-highest` element inside a `surface-container-low` area. The shift in hex value creates a natural perception of depth.
*   **Ambient Shadows:** For floating elements (like a "Redeem" button), use extra-diffused shadows: `blur: 32px`, `spread: -4px`, and an opacity of 6% using the `on-surface` color.
*   **The Depth Stack:**
    1.  **Level 0:** `surface` (The floor)
    2.  **Level 1:** `surface-container-low` (Subtle grouping)
    3.  **Level 2:** `surface-container-lowest` + Ambient Shadow (Interactive cards)

---

## 5. Components

### Buttons: The "Moment of Reward"
*   **Primary (Gold/Black):** Use `secondary_container` (#feb700) for the background with `on_secondary_container` (#6b4b00) for text. Shape: `full` (pill-shaped) for a modern, friendly feel.
*   **Secondary:** `primary_container` (#0d1c32) with `on_primary_fixed` (#d6e3ff). 
*   **Motion:** On press, scale the button down to 0.98 to simulate physical resistance.

### Cards: The Product Showcase
*   **Forbid Divider Lines.** Separate the product image from the description using a `1.5rem` (`xl`) vertical margin or a subtle background shift from `surface-lowest` to `surface-low`.
*   **Radius:** Always use `lg` (1rem) for product cards and `xl` (1.5rem) for hero banners.

### Chips: Status & Filters
*   **Selection Chips:** Use `secondary_fixed` (#ffdea8) with a 2px `outline-variant` Ghost Border. 
*   **Reward Tags:** Tiny `label-sm` text placed in a `primary_container` chip to denote "Exclusive" or "Limited" status.

### Input Fields: Clean & Minimal
*   **Style:** No background color. Only a bottom "Ghost Border" using `outline-variant` at 20%. 
*   **Active State:** The border transitions to `secondary` (Gold) and grows to 2px.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use asymmetrical layouts. A product image can bleed off the right edge of a card to imply a larger world.
*   **Do** use the `secondary` gold sparingly as an accent—it is the "reward," don't exhaust the user's eyes with it.
*   **Do** prioritize whitespace. If a screen feels crowded, increase the spacing between sections by one step in the scale.

### Don’t:
*   **Don’t** use pure black (#000000) for text. Use `on_surface` (#191c1e) to maintain a soft, premium look.
*   **Don’t** use 1px solid lines to separate list items. Use a 16px vertical gap instead.
*   **Don’t** use standard "Material Design" shadows. Keep them diffused and tinted.