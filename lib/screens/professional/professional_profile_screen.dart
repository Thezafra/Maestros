import 'package:flutter/material.dart';

import '../../models/professional.dart';
import '../request/request_service_screen.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  final Professional professional;

  const ProfessionalProfileScreen({
    super.key,
    required this.professional,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Perfil Profesional',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compartir: próximamente')),
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _HeaderCard(professional: professional),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(.06),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sobre mí', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(
                    professional.about ??
                        'Profesional certificado con experiencia en servicios residenciales y comerciales. Enfoque en seguridad, calidad y tiempos de respuesta rápidos.',
                    style: TextStyle(color: cs.onSurface.withOpacity(.75), height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Trabajos recientes',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Galería: próximamente')),
                          );
                        },
                        child: const Text('Ver todo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 78,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, __) => _WorkThumb(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RequestServiceScreen(professional: professional),
                          ),
                        );
                      },
                      child: const Text('Reservar ahora'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(.06),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reseñas', style: TextStyle(fontWeight: FontWeight.w900)),
                    SizedBox(height: 10),
                    Text(
                      'Aún no hay reseñas para este profesional.',
                      style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                    ),
                    /*
                    _ReviewRow(
                      name: 'María López',
                      text: 'Excelente servicio y muy profesional. Recomendado.',
                      stars: 5,
                    ),
                    */
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Professional professional;
  const _HeaderCard({required this.professional});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _ProfileAvatar(avatarAsset: professional.avatarAsset),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${professional.role} • ${professional.yearsExp}+ años exp',
                      style: TextStyle(color: cs.onSurface.withOpacity(.7)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (professional.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.place_outlined,
                              size: 16, color: cs.onSurface.withOpacity(.6)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              professional.location!,
                              style: TextStyle(color: cs.onSurface.withOpacity(.6)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.verified, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatCard(
                icon: Icons.star,
                iconColor: Colors.amber,
                value: professional.jobsDone == 0 ? 'Nuevo' : professional.rating.toStringAsFixed(1),
                label: 'Calificación',
              ),
              const SizedBox(width: 10),
              _StatCard(
                icon: Icons.work_outline,
                value: '${professional.yearsExp}+',
                label: 'Años exp.',
              ),
              const SizedBox(width: 10),
              _StatCard(
                icon: Icons.task_alt,
                iconColor: Colors.green,
                value: '${professional.jobsDone}+',
                label: 'Trabajos',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? avatarAsset;
  const _ProfileAvatar({required this.avatarAsset});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: 32,
      backgroundColor: cs.surfaceContainerHighest,
      child: ClipOval(
        child: (avatarAsset == null || avatarAsset!.isEmpty)
            ? Icon(Icons.person, size: 34, color: cs.onSurface.withOpacity(.6))
            : Image.asset(
                avatarAsset!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person, size: 34, color: cs.onSurface.withOpacity(.6)),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(.35),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: iconColor ?? cs.primary),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: cs.onSurface.withOpacity(.65), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _WorkThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.image_outlined, color: cs.onSurface.withOpacity(.5)),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String name;
  final String text;
  final int stars;

  const _ReviewRow({
    required this.name,
    required this.text,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: cs.surfaceContainerHighest,
          child: Icon(Icons.person, size: 18, color: cs.onSurface.withOpacity(.55)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w900))),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < stars ? Icons.star : Icons.star_border,
                        size: 14,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(text, style: TextStyle(color: cs.onSurface.withOpacity(.75))),
            ],
          ),
        ),
      ],
    );
  }
}
