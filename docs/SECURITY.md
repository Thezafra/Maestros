# Resumen de Seguridad 🛡️

Este documento describe las medidas de seguridad implementadas en la aplicación **Maestros** para proteger los datos de los usuarios y prevenir accesos no autorizados ("hackeos").

## 1. Seguridad de la Base de Datos (Reglas de Firestore)
Hemos implementado **Seguridad a Nivel de Fila** (Row Level Security) en Firestore. Esta es la capa de defensa más crítica.

*   **Archivo de Reglas**: `firestore.rules` (en la raíz del proyecto).
*   **Cómo funciona**:
    *   **Acceso Estricto**: La base de datos rechaza cualquier solicitud de lectura/escritura que no cumpla con criterios específicos.
    *   **Aislamiento de Usuarios**: Un usuario *solo* puede editar su propio perfil. Incluso si un "hacker" intenta enviar un comando para editar el perfil de otro usuario, la base de datos lo rechazará inmediatamente.
    *   **Privacidad de Datos**: Los datos personales (como números de teléfono en reservas) solo son visibles para el Cliente y el Profesional involucrados en esa reserva específica.

## 2. Autenticación
*   **Proveedor**: Google Identity Platform (Firebase Auth).
*   **Seguridad**: No almacenamos contraseñas directamente. Toda la autenticación es manejada por los servidores seguros de Google.
*   **Protección**: Previene ataques de fuerza bruta en tu propio servidor, ya que Google gestiona la infraestructura de inicio de sesión.

## 3. Encriptación de Comunicaciones
*   Todos los datos transmitidos entre la App y la Base de Datos son encriptados usando **SSL/TLS (HTTPS)** automáticamente por Firebase. Esto previene ataques "Man-in-the-Middle" donde alguien escucha el tráfico de la red.

## 4. Acción Manual Requerida: Restricción de API Keys ⚠️

Aunque el código de la app es seguro, tus **API Keys de Google Maps / Firebase** son visibles en el código (esto es normal en apps móviles). Para prevenir que otros usen tus llaves en sus propios sitios web (robo de cuota), debes restringirlas en la Consola de Google Cloud.

### Pasos para Restringir Llaves:
1.  Ve a la [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
2.  Selecciona tu proyecto.
3.  Busca la **Android Key** (usada en `google-services.json`).
4.  Haz clic en **Editar** (ícono de lápiz).
5.  **Restricciones de Aplicación**:
    *   Selecciona **Android apps**.
    *   Haz clic en **Add an item**.
    *   Ingresa tu Nombre de Paquete: `com.example.marketplace_app` (o tu nombre de paquete de producción).
    *   Ingresa tu **Huella SHA-1** (de tu keystore).
6.  **Restricciones de API**:
    *   Selecciona **Restrict key**.
    *   Selecciona *solo* las APIs que esta llave necesita (ej. Firestore, Maps SDK for Android, Geocoding API).
7.  **Guardar**.

*Hacer esto asegura que incluso si alguien roba tu llave, no podrá usarla fuera de tu aplicación Android específica.*

### Para iOS (iPhone) 🍎
Si en el futuro compilas la app para iPhone (recuerda que necesitas una Mac para esto):
1.  Debes crear una **iOS Key** en la consola de Google.
2.  Restringirla a **iOS apps**.
3.  Ingresar el **Bundle ID** de tu app (ej. `com.example.marketplace_app`).
