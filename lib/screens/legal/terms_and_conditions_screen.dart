import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Información Legal'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Términos de Uso'),
              Tab(text: 'Privacidad'),
            ],
            indicatorColor: Colors.blueAccent,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const TabBarView(
          children: [
            _TermsOfUseContent(),
            _PrivacyPolicyContent(),
          ],
        ),
      ),
    );
  }
}

class _TermsOfUseContent extends StatelessWidget {
  const _TermsOfUseContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader('Términos y Condiciones de Servicio'),
          _LastUpdated('Última actualización: 9 de marzo, 2026'),
          _SectionTitle('1. Aceptación de los Términos'),
          _SectionText(
              'Al descargar, instalar o utilizar la aplicación "Koippo", usted acepta quedar vinculado por estos Términos y Condiciones. Si no está de acuerdo con alguna parte, no deberá utilizar nuestros servicios.'),
          
          _SectionTitle('2. Descripción del Servicio'),
          _SectionText(
              'Koippo es una plataforma digital que facilita el contacto entre usuarios que buscan servicios del hogar (Clientes) y profesionales independientes que los ofrecen (Koippo). La plataforma actúa únicamente como un directorio dinámico e intermediario de comunicación.'),
          
          _SectionTitle('3. Roles y Responsabilidades'),
          _SectionText(
              '• Clientes: Son responsables de verificar la idoneidad y certificaciones del Maestro antes de contratar. El pago se acuerda y realiza directamente con el profesional.'),
          _SectionText(
              '• Koippo: Se comprometen a proporcionar información veraz sobre sus servicios, experiencia y precios. Son responsables exclusivos de la ejecución técnica y legal de los trabajos realizados.'),
          
          _SectionTitle('4. Exclusión de Responsabilidad'),
          _SectionText(
              'Koippo App no garantiza la calidad, seguridad, legalidad o puntualidad de los servicios prestados por los profesionales listados. No intervenimos en la transacción monetaria ni en la ejecución del servicio.'),
          
          _SectionTitle('5. Geolocalización y Búsqueda'),
          _SectionText(
              'La aplicación utiliza servicios de geolocalización para mostrar profesionales disponibles en su cercanía (Región y Comuna). El uso de esta función requiere permisos de GPS que el usuario puede revocar en cualquier momento.'),
          
          _SectionTitle('6. Enlaces Externos y WhatsApp'),
          _SectionText(
              'Facilitamos la comunicación directa mediante API de WhatsApp. Una vez que el usuario sale de la aplicación para comunicarse, Koippo no tiene control ni responsabilidad sobre el intercambio de mensajes o datos en plataformas de terceros.'),
          
          _SectionTitle('7. Modificaciones'),
          _SectionText(
              'Nos reservamos el derecho de modificar estos términos en cualquier momento para reflejar cambios en la funcionalidad de la app o normativas legales.'),
          
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader('Política de Privacidad'),
          _LastUpdated('Última actualización: 13 de marzo, 2026'),
          _SectionTitle('1. Información que Recopilamos'),
          _SectionText(
              '• Datos de Cuenta: Nombre, correo, teléfono y foto de perfil (Google Auth o manual).'),
          _SectionText(
              '• Multimedia (Maestros): Acceso a cámara y galería para subir fotos de perfil y portafolio de trabajos realizados.'),
          _SectionText(
              '• Datos de Ubicación: Recopilamos ubicación precisa para filtrar profesionales por cercanía (Región y Comuna).'),
          
          _SectionTitle('2. Uso de la Información'),
          _SectionText(
              'Utilizamos sus datos para facilitar la conexión cliente-maestro, personalizar la búsqueda según su zona y mantener la seguridad de las cuentas.'),
          
          _SectionTitle('3. Almacenamiento y Seguridad'),
          _SectionText(
              'Sus datos y fotos se almacenan de forma segura en Google Firebase (Firestore y Storage), con reglas que protegen su información contra accesos no autorizados.'),
          
          _SectionTitle('4. Compartición de Datos'),
          _SectionText(
              'No vendemos sus datos. Sus fotos de trabajos y especialidad son visibles para clientes interesados. Su teléfono solo se usa para habilitar el contacto por WhatsApp.'),
          
          _SectionTitle('5. Sus Derechos'),
          _SectionText(
              'Usted puede acceder, corregir o eliminar sus datos y fotos desde la sección "Editar Perfil" en cualquier momento.'),
          
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }
}

class _LastUpdated extends StatelessWidget {
  final String date;
  const _LastUpdated(this.date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        date,
        style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
