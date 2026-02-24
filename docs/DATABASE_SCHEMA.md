# Esquema de Base de Datos (Firestore)

La aplicación utiliza Cloud Firestore como su base de datos principal. A continuación se detalla la estructura de las colecciones y documentos.

## Colecciones

### 1. `clients` (Clientes)
Almacena información sobre los usuarios registrados como clientes (que buscan servicios).

**ID del Documento**: `uid` (de Firebase Auth)

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `uid` | String | ID Único de Usuario (igual al Doc ID) |
| `role` | String | Siempre `'client'` |
| `name` | String | Nombre completo |
| `email` | String | Correo electrónico |
| `photoUrl` | String | URL de la foto de perfil (ej. de Google) |
| `phone` | String | Teléfono de contacto (Opcional) |
| `address` | String | Dirección predeterminada (Opcional) |
| `region` | String | Región predeterminada (ej. "Metropolitana") |
| `commune` | String | Comuna predeterminada (ej. "Providencia") |
| `createdAt` | Timestamp | Fecha de creación de la cuenta |

---

### 2. `professionals` (Profesionales)
Almacena información sobre los usuarios registrados como profesionales (que ofrecen servicios).

**ID del Documento**: `uid` (de Firebase Auth)

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `uid` | String | ID Único de Usuario (igual al Doc ID) |
| `role` | String | Siempre `'professional'` |
| `name` | String | Nombre |
| `lastname` | String | Apellido |
| `email` | String | Correo electrónico |
| `phone` | String | Teléfono de contacto |
| `job` | String | Profesión principal (ej. "Carpintero") |
| `yearsExperience` | Number | Años de experiencia |
| `region` | String | Región de operación |
| `commune` | String | Comuna de operación |
| `rating` | Number | Calificación promedio actual (ej. 4.5) |
| `jobsDone` | Number | Total de trabajos completados |
| `isOnline` | Boolean | Estado de disponibilidad (Actualizado automáticamente) |
| `about` | String | Descripción "Sobre mí" |
| `price` | Number | Precio referencial por hora/visita |
| `createdAt` | Timestamp | Fecha de creación de la cuenta |

---

### 3. `reservations` (Reservas)
Almacena las solicitudes de servicio y reservas entre clientes y profesionales.

**ID del Documento**: Generado automáticamente

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `clientId` | String | ID del cliente que hace la solicitud |
| `clientName` | String | Nombre del cliente |
| `clientPhone` | String | Teléfono de contacto del cliente |
| `professionalId` | String | ID del profesional |
| `professionalName`| String | Nombre del profesional |
| `professionalJob` | String | Servicio solicitado (ej. "Gasfitería") |
| `professionalPhone`| String | Teléfono del profesional |
| `details` | String | Descripción del problema/solicitud |
| `address` | String | Ubicación donde se necesita el servicio |
| `isEmergency` | Boolean | Verdadero si se necesita atención inmediata |
| `scheduledDate` | Timestamp | Fecha y hora solicitada |
| `status` | String | Estado actual (ver abajo) |
| `rating` | Number | Calificación del cliente (1-5) si se completó |
| `review` | String | Reseña escrita del cliente |
| `createdAt` | Timestamp | Fecha de la solicitud |

#### Flujo de Estados (Status)
1.  `Pendiente`: Estado inicial cuando se envía la solicitud.
2.  `Confirmado`: El profesional acepta el trabajo.
3.  `Rechazado`: El profesional declina el trabajo.
4.  `Completado`: El trabajo se marca como finalizado (Característica futura).

---

## Reglas de Seguridad (Resumen)
*   **Lectura**: La lectura pública de profesionales está permitida. Los clientes solo pueden leer sus propios datos.
*   **Escritura**: Los usuarios solo pueden modificar sus propios documentos.
