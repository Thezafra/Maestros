# Arquitectura del Proyecto

"Maestros" es una aplicación multiplataforma (Android, Web) construida con **Flutter**. Utiliza **Firebase** para servicios de backend (Auth, Firestore).

## Stack Tecnológico
*   **Frontend**: Flutter (Dart)
*   **Backend**: Firebase (Firestore, Auth)
*   **Gestión de Estado**: `Shared Preferences` + `setState` / StreamBuilders
*   **Mapas/Ubicación**: `geolocator`, `geocoding`

## Estructura de Carpetas (`lib/`)

```
lib/
├── firebase_options.dart   # Configuración de Firebase
├── main.dart               # Punto de entrada (Ciclo de vida y Rutas)
├── items/                  # (Legacy/Items compartidos)
│   └── auth_service.dart   # Lógica de Autenticación
├── models/                 # Modelos de datos
│   └── professional.dart   # Modelo de Profesional con lógica de formato
├── screens/
│   ├── auth/               # Pantallas de Autenticación (Login, Registro)
│   ├── client/             # Vistas específicas de Cliente (Home, Perfil, Historial)
│   ├── professional/       # Vistas específicas de Profesional (Panel, Perfil)
│   ├── request/            # Pantallas de flujo de Reserva
│   ├── role/               # Selección de Roles y enrutamiento
│   ├── splash/             # Pantallas de carga inicial
│   └── home_screen.dart    # Home Principal de Cliente (Marketplace)
├── utils/                  # Funciones auxiliares y constantes
│   └── chile_data.dart     # Datos estáticos para Regiones/Comunas
└── widgets/                # Componentes de UI reutilizables
    ├── professional_card.dart  # Tarjeta de visualización para profesionales
    └── responsive_layout.dart  # Envoltorio para diseños Web/Móvil
```

## Flujos Clave

### 1. Autenticación y Selección de Rol
*   Los usuarios inician sesión vía Google o Email/Contraseña.
*   Al entrar, la app verifica si el usuario es Cliente o Profesional vía Firestore.
*   `RoleLoaderScreen` los dirige al Panel (Dashboard) apropiado.

### 2. Manejo de Ubicación
*   **GPS**: La app usa `geolocator` para obtener coordenadas.
*   **Geocoding**: Las coordenadas se convierten a direcciones y se comparan con `ChileData` para seleccionar automáticamente la Región y Comuna del usuario para el filtrado.

### 3. Diseño Responsivo
*   El widget `ResponsiveLayout` verifica la restricción de ancho de pantalla (1100px).
*   **Móvil**: Usa `Scaffold` con `NavigationBar`.
*   **Escritorio**: Usa `Scaffold` con `NavigationRail` y restricciones de contenido centrado.

### 4. Sistema de Estado Online
*   **Automático**: `main.dart` escucha `AppLifecycleState`.
*   **Resumed (Abierto)**: Establece `isOnline = true` en Firestore.
*   **Paused/Detached (Cerrado)**: Establece `isOnline = false`.
