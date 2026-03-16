# Koippo 🛠️

**Koippo** es una aplicación moderna en Flutter diseñada para conectar profesionales de servicios del hogar (gasfíteres, electricistas, carpinteros, etc.) con clientes en Chile.

## Características

### Para Clientes 🏠
*   **Búsqueda Inteligente**: Filtra profesionales por Región y Comuna fácilmente.
*   **Integración GPS**: Auto-detecta tu ubicación para completar direcciones rápido.
*   **Sistema de Reservas**: Agenda visitas o solicita asistencia de emergencia.
*   **Calificaciones**: Califica profesionales y ve reseñas verificadas.

### Para Profesionales 👷
*   **Panel (Dashboard)**: Rastrea ganancias, trabajos realizados y solicitudes pendientes.
*   **Estado Online Automático**: Gestión automática de disponibilidad basada en el uso de la app.
*   **Gestión de Perfil**: Muestra tu experiencia, precios y portafolio.
*   **Conexión con Cliente**: Integración directa con WhatsApp para comunicación.

## Documentación

Tenemos documentación detallada disponible en la carpeta `docs/`:

*   [**Esquema de Base de Datos**](docs/DATABASE_SCHEMA.md): Aprende sobre la estructura de datos en Firestore.
*   [**Arquitectura**](docs/ARCHITECTURE.md): Entiende la estructura del código y el stack tecnológico.
*   [**Guía de Usuario**](docs/USER_GUIDE.md): Instrucciones para usar la app.
*   [**Seguridad y Protección Hackers**](docs/SECURITY.md): Cómo protegemos los datos de los usuarios.
*   [**Guía de Despliegue (Google Play)**](docs/DEPLOYMENT_GUIDE_ANDROID.md): Pasos para generar el archivo AAB y subir a la tienda.

## Comenzando

1.  **Clonar el repositorio**:
    ```bash
    git clone https://github.com/tuusuario/maestros.git
    ```
2.  **Instalar dependencias**:
    ```bash
    flutter pub get
    ```
3.  **Correr la app**:
    ```bash
    flutter run
    ```

## Tecnología

*   **Flutter** (Dart)
*   **Firebase** (Auth, Firestore, Hosting)
*   **Geolocator** & **Geocoding**

---
*Construido con ❤️ para Maestros*
