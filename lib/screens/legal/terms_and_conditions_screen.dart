import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Términos y Condiciones de Uso',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Última actualización: Febrero 2026',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            SizedBox(height: 20),
            _SectionTitle('1. Introducción'),
            _SectionText(
                'Bienvenido a Maestros. Esta aplicación conecta a profesionales de servicios (en adelante "Maestros") con usuarios que requieren dichos servicios (en adelante "Clientes"). Al utilizar esta aplicación, usted acepta estos términos.'),
            
            _SectionTitle('2. Responsabilidad'),
            _SectionText(
                'Maestros actúa únicamente como intermediario tecnológico. No somos responsables de la calidad, cumplimiento o garantías de los trabajos realizados por los profesionales. La relación contractual es exclusivamente entre el Cliente y el Maestro.'),
            
            _SectionTitle('3. Cuenta de Usuario'),
            _SectionText(
                'Usted es responsable de mantener la confidencialidad de su cuenta y contraseña. Debe notificar inmediatamente cualquier uso no autorizado.'),
            
            _SectionTitle('4. Conducta de los Usuarios'),
            _SectionText(
                'Se prohíbe el uso de la aplicación para fines ilegales, fraudulentos o para acosar a otros usuarios. Nos reservamos el derecho de suspender cuentas que violen estas normas.'),
            
            _SectionTitle('5. Pagos'),
            _SectionText(
                'Los pagos por servicios se acuerdan y realizan directamente entre el Cliente y el Maestro. La aplicación no procesa pagos ni cobra comisiones en esta versión.'),
            
            _SectionTitle('6. Privacidad'),
            _SectionText(
                'Su información personal será utilizada únicamente para el funcionamiento de la aplicación y facilitar la conexión entre las partes. Consulte nuestra Política de Privacidad para más detalles.'),
            
            SizedBox(height: 40),
            Center(
              child: Text(
                'Maestros App - Chile',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
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
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
      textAlign: TextAlign.justify,
    );
  }
}
