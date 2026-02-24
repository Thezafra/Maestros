# Guía de Despliegue en Google Play Store 🚀

Esta guía te explicará cómo generar el archivo final de tu aplicación (.aab) para subirlo a la tienda de Google.

## 1. Prerrequisitos
*   Tener una **Cuenta de Desarrollador de Google Play** (Cuesta $25 USD pago único).
*   Tener el proyecto listo y probado.

## 2. Generar la Llave de Firmado (Upload Keystore) 🔑
Para que Google sepa que la app es tuya, debes "firmarla".

1.  Abre una terminal en la carpeta de tu proyecto.
2.  Ejecuta este comando (Windows):
    ```powershell
    keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    ```
    *   *Nota*: Si no reconoce `keytool`, búscalo en la carpeta de Java/JDK de tu PC o instálalo.
3.  Te pedirá una **contraseña**. ¡Guárdala muy bien! Si la pierdes, no podrás actualizar tu app.
4.  Te pedirá datos (Nombre, Organización, etc.). Llénalos.
5.  Esto creará el archivo `android/app/upload-keystore.jks`.

## 3. Configurar la Llave en el Proyecto
1.  Crea un archivo llamado `key.properties` en la carpeta `android/`.
2.  Escribe lo siguiente dentro (reemplaza `tu_contraseña`):
    ```properties
    storePassword=tu_contraseña
    keyPassword=tu_contraseña
    keyAlias=upload
    storeFile=upload-keystore.jks
    ```
    *   **IMPORTANTE**: Nunca subas este archivo a GitHub/Internet.

## 4. Configurar `build.gradle`
Asegúrate de que `android/app/build.gradle` esté configurado para usar esta llave (normalmente Flutter ya trae una configuración lista para leer `key.properties` si existe, o debes agregarla).

*Verifique que su sección `android { ... signingConfigs { ... } }` lea el archivo.*

## 5. Generar el App Bundle (.aab) 📦
Google Play ya no usa `.apk`, usa `.aab` (Android App Bundle).

1.  En la terminal del proyecto ejecuta:
    ```bash
    flutter build appbundle
    ```
2.  Espera unos minutos...
3.  Al finalizar, el archivo estará en:
    `build/app/outputs/bundle/release/app-release.aab`

## 6. Subir a Google Play Console ☁️
1.  Entra a [Google Play Console](https://play.google.com/console).
2.  **Crear aplicación**: Pon el nombre "Maestros", idioma, etc.
3.  Ve a **Producción** (o "Pruebas internas" si quieres probar primero).
4.  **Crear nueva versión**.
5.  Sube el archivo `app-release.aab` que generaste.
6.  Llena la ficha de la tienda (Descripción, Imágenes, Logo, Política de Privacidad).
    *   *Tip*: Usa el enlace a tus Términos y Condiciones si tienes web, o genera una política simple.
7.  Envía a revisión. Google tardará unos días en aprobarla.

---
**¡Éxito!** Tu app estará disponible para millones de personas.
