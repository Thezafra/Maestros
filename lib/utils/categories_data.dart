import 'package:flutter/material.dart';

class CategoryData {
  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Electricista',
      'icon': Icons.bolt,
      'bg': Color(0xFFEAF2FF),
      'fg': Color(0xFF2E6CF6)
    },
    {
      'name': 'Gásfiter',
      'icon': Icons.plumbing,
      'bg': Color(0xFFFFEDED),
      'fg': Color(0xFFFF4D4D)
    },
    {
      'name': 'Carpintero',
      'icon': Icons.handyman,
      'bg': Color(0xFFFFF0F6),
      'fg': Color(0xFFE84393)
    },
    {
      'name': 'Pintor',
      'icon': Icons.format_paint,
      'bg': Color(0xFFFFF3E6),
      'fg': Color(0xFFFF9F2D)
    },
    {
      'name': 'Albañil',
      'icon': Icons.foundation,
      'bg': Color(0xFFEFFFF6),
      'fg': Color(0xFF18B26A)
    },
    {
      'name': 'Jardinero',
      'icon': Icons.grass,
      'bg': Color(0xFFF3EEFF),
      'fg': Color(0xFF6C5CE7)
    },
    {
      'name': 'Aseo / Limpieza',
      'icon': Icons.cleaning_services,
      'bg': Color(0xFFEAF7FF),
      'fg': Color(0xFF00BCD4)
    },
    {
      'name': 'Soldador',
      'icon': Icons.local_fire_department,
      'bg': Color(0xFFFFEAEA),
      'fg': Color(0xFFD32F2F)
    },
    {
      'name': 'Cerrajero',
      'icon': Icons.key,
      'bg': Color(0xFFFFF8E1),
      'fg': Color(0xFFFFA000)
    },
    {
      'name': 'Mecánico',
      'icon': Icons.car_repair,
      'bg': Color(0xFFECEFF1),
      'fg': Color(0xFF455A64)
    },
    {
      'name': 'Técnico PC / Redes',
      'icon': Icons.computer,
      'bg': Color(0xFFE1F5FE),
      'fg': Color(0xFF0288D1)
    },
    {
      'name': 'Otros',
      'icon': Icons.grid_view,
      'bg': Color(0xFFF2F4F8),
      'fg': Color(0xFF3E4A59)
    },
  ];

  static List<String> get names =>
      categories.map((e) => e['name'] as String).toList();
}
