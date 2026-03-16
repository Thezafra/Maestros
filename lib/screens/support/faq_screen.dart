import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Preguntas Frecuentes'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _FAQItem(
            question: '¿Cómo funciona Koippo?',
            answer: 'Koippo es una plataforma que conecta clientes con profesionales de servicios para el hogar. Puedes buscar maestros por especialidad y ubicación, y contactarlos directamente por WhatsApp.',
          ),
          _FAQItem(
            question: '¿Tengo que pagar por usar la app?',
            answer: 'El uso de la aplicación para buscar y contactar profesionales es gratuito en esta versión. El pago por los servicios se acuerda directamente con el maestro contratado.',
          ),
          _FAQItem(
            question: '¿Cómo puedo registrarme como profesional?',
            answer: 'En la pantalla de inicio, selecciona "Soy Profesional" y completa el formulario de registro con tus datos y especialidad.',
          ),
          _FAQItem(
            question: '¿Qué hago si tengo un problema con un servicio?',
            answer: 'Koippo actúa como intermediario tecnológico. Te recomendamos contactar directamente al profesional para resolver cualquier inconveniente. No obstante, puedes reportar problemas graves a nuestro email soporte@koippo.cl.',
          ),
          _FAQItem(
            question: '¿Cómo puedo eliminar mi cuenta?',
            answer: 'Puedes solicitar la eliminación de tu cuenta enviando un correo a soporte@koippo.cl con el asunto "Eliminar Cuenta" desde el correo con el que te registraste.',
          ),
          _FAQItem(
            question: '¿Mis datos están seguros?',
            answer: 'Sí, utilizamos Firebase de Google Cloud para el almacenamiento seguro de datos, cumpliendo con estándares internacionales de privacidad.',
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
