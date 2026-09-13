---
name: Jolus Professional Core
colors:
  surface: '#faf8ff'
  surface-dim: '#dad9e1'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f3fa'
  surface-container: '#eeedf4'
  surface-container-high: '#e9e7ef'
  surface-container-highest: '#e3e1e9'
  on-surface: '#1a1b21'
  on-surface-variant: '#444651'
  inverse-surface: '#2f3036'
  inverse-on-surface: '#f1f0f7'
  outline: '#757682'
  outline-variant: '#c5c5d3'
  surface-tint: '#4059aa'
  primary: '#00236f'
  on-primary: '#ffffff'
  primary-container: '#1e3a8a'
  on-primary-container: '#90a8ff'
  inverse-primary: '#b6c4ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#4b1c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#6e2c00'
  on-tertiary-container: '#f39461'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b6c4ff'
  on-primary-fixed: '#00164e'
  on-primary-fixed-variant: '#264191'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#ffdbcb'
  tertiary-fixed-dim: '#ffb691'
  on-tertiary-fixed: '#341100'
  on-tertiary-fixed-variant: '#773205'
  background: '#faf8ff'
  on-background: '#1a1b21'
  surface-variant: '#e3e1e9'
typography:
  h1:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  h2:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  h3:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  gutter: 16px
  margin: 20px
---

## Brand & Style
Este sistema de diseño proyecta confianza, eficiencia y pulcritud. Está dirigido a propietarios de viviendas y oficinas que buscan soluciones rápidas pero de alta calidad. La estética es **Corporate / Modern**, fusionando la estructura funcional de una aplicación de eventos (donde el tiempo y la reserva son clave) con la higiene visual necesaria para servicios de limpieza y mantenimiento. El objetivo es transmitir una sensación de orden y profesionalismo mediante el uso generoso de espacios en blanco y una paleta de colores sobria.

## Colors
La paleta se centra en un "Azul Profesional" profundo que evoca autoridad y calma. El blanco actúa como base para maximizar la legibilidad, mientras que los grises claros y azulados se utilizan para jerarquizar la información sin saturar la vista. 

- **Primario (#1E3A8A):** Utilizado para branding, botones de acción principal y estados activos.
- **Secundario (#64748B):** Para texto de apoyo, iconos secundarios y estados deshabilitados.
- **Superficies:** Fondos en gris extremadamente claro (#F8FAFC) para diferenciar tarjetas de contenido blancas.

## Typography
Se ha seleccionado **Manrope** por su equilibrio entre modernidad geométrica y calidez humanista, ideal para una aplicación de servicios personales. Para elementos de datos técnicos o etiquetas de estado, se utiliza **Inter**, que ofrece una claridad excepcional en tamaños reducidos. La jerarquía prioriza títulos grandes y claros para facilitar la navegación rápida, similar a una cartelera de eventos.

## Layout & Spacing
El sistema utiliza un **Fluid Grid** basado en un ritmo de 4px. La estructura se inspira en aplicaciones de eventos, organizando los servicios en tarjetas verticales y horizontales con espaciados generosos para evitar el desorden visual. Los márgenes laterales de 20px aseguran que el contenido respire en dispositivos móviles, mientras que las medianiles de 16px mantienen los elementos relacionados cohesionados pero distinguibles.

## Elevation & Depth
Para mantener la estética limpia y profesional, se emplean **Tonal Layers** y sombras ambientales muy suaves. 
- **Nivel 0 (Fondo):** Gris muy claro para separar la interfaz del dispositivo.
- **Nivel 1 (Tarjetas):** Superficies blancas con bordes sutiles de 1px (#E2E8F0) y sin sombra para una apariencia plana y técnica.
- **Nivel 2 (Interacción):** Al interactuar o destacar un servicio, se aplica una sombra difusa (Y: 4px, Blur: 12px, Opacity: 5% del color primario) para elevar el elemento visualmente.

## Shapes
Se utiliza una redondez de nivel **2 (Rounded)**. Los botones y contenedores principales tienen un radio de 0.5rem (8px), lo que suaviza la seriedad del azul profesional y hace que la interfaz se sienta más amigable y accesible. Para elementos tipo "píldora" (chips de estado), se utiliza un radio máximo para indicar dinamismo.

## Components

- **Buttons:** El botón primario es de color azul sólido con texto blanco en semi-bold. Los botones secundarios usan un borde fino azul y fondo transparente. El radio de esquina es de 8px.
- **Service Cards:** Inspiradas en tarjetas de eventos; incluyen una imagen en la parte superior (opcional), título en H3, precio destacado y un botón de "Reservar" o "Ver disponibilidad".
- **Chips (Categorías):** Pequeños indicadores con fondo gris claro y texto en azul oscuro para filtrar servicios (ej: "Limpieza", "Plomería").
- **Inputs:** Campos de texto con bordes definidos en gris claro que cambian a azul primario al recibir el foco. Las etiquetas siempre se mantienen visibles.
- **Status Indicators:** Puntos de color sólido (verde para confirmado, amarillo para pendiente, azul para en curso) acompañados de texto en Inter para una lectura técnica precisa.
- **Calendar Picker:** Un componente crítico debido a la naturaleza de la app; debe ser limpio, con el día seleccionado en azul primario y los días no disponibles en gris tenue.