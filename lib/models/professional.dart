class Professional {
  final String id;
  final String name;
  final String role;
  final double rating;

  // ✅ IMPORTANTE para el filtro
  final String category;

  // Tu campo original
  final int yearsExperience;

  final int jobsDone;
  final double pricePerHour;

  // Para que no falle aunque no tengas imágenes aún
  final String avatarAsset;

  // Campos explícitos para filtrado
  final String region;
  final String commune;

  // Restaurando campos eliminados
  final String location;
  final String about;
  final String phone;
  final String rut;
  final String? certificationNumber;
  final bool isVerified;

  const Professional({
    required this.id,
    required this.name,
    required this.role,
    required this.rating,
    required this.category,
    required this.yearsExperience,
    required this.jobsDone,
    required this.pricePerHour,
    this.avatarAsset = '',
    this.location = '',
    this.about = '',
    required this.region,
    required this.commune,
    this.phone = '',
    required this.rut,
    this.certificationNumber,
    this.isVerified = false,
  });

  // Alias para tu UI
  int get yearsExp => yearsExperience;

  factory Professional.fromFirestore(Map<String, dynamic> data, String uid) {
    return Professional(
      id: uid,
      name: '${data['name']} ${data['lastname']}',
      role: data['job'] ?? 'Profesional',
      category: data['job'] ?? 'Otros',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      yearsExperience: (data['yearsExperience'] as num?)?.toInt() ?? 0,
      jobsDone: (data['jobsDone'] as num?)?.toInt() ?? 0,
      pricePerHour: (data['price'] as num?)?.toDouble() ?? 0.0,
      location: '${data['commune'] ?? ''}, ${data['region'] ?? ''}',
      about: data['about'] ?? 'Sin descripción',
      region: data['region'] ?? '',
      commune: data['commune'] ?? '',
      phone: data['phone'] ?? '',
      rut: data['rut'] ?? '',
      certificationNumber: data['certificationNumber'],
      isVerified: data['isVerified'] ?? false,
    );
  }
}
