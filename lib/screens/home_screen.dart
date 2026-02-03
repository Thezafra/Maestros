import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'client/client_reservations_screen.dart';
import 'client/client_profile_screen.dart';
import '../models/professional.dart';
import '../widgets/category_item.dart';
import '../widgets/professional_card.dart';
import 'professional/professional_profile_screen.dart';
import '../utils/categories_data.dart';
import '../utils/chile_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Todos';
  String? _selectedRegion;
  String? _selectedCommune;
  int navIndex = 0;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: [
        _buildHomeContent(),
        const ClientReservationsScreen(),
        const ClientProfileScreen(),
      ][navIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        onDestinationSelected: (v) => setState(() => navIndex = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Reservas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            InkWell(
              onTap: _showLocationPicker,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on_outlined, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TU UBICACIÓN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedCommune != null
                              ? '$_selectedCommune, $_selectedRegion'
                              : 'Seleccionar ubicación',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Buscar servicios o maestro...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.black54),
                ),
                onChanged: (val) {
                  setState(() {}); // Trigger rebuild to filter
                },
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            _SectionHeader(
              title: 'Categorías de servicios',
              actionText: 'Ver todo',
              onAction: () {},
            ),
            const SizedBox(height: 10),
            _buildCategoriesGrid(),
            if (_selectedCategory != 'Todos')
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: ActionChip(
                    label: Text('Mostrando: $_selectedCategory (Borrar filtro)'),
                    onPressed: () => setState(() => _selectedCategory = 'Todos'),
                    avatar: const Icon(Icons.close, size: 16),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            _SectionHeader(
              title: 'Maestros recomendados',
              actionText: 'Ver todo',
              onAction: () => setState(() => _selectedCategory = 'Todos'),
            ),
            const SizedBox(height: 10),

            // ✅ REAL FIRESTORE DATA
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('professionals')
                  // Removed .where('active') to guarantee showing all users for testing
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error al cargar profesionales');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 1. Convert docs to Professional objects
                final docs = snapshot.data!.docs;
                final allPros = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Professional.fromFirestore(data, doc.id);
                }).toList();
                
                return Column(
                  children: _buildFilteredList(allPros, context),
                );
              },
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: cs.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Solicita un servicio y encuentra el mejor maestro para tu trabajo.',
                      style: TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    // Show top 7 categories + 'More'
    final topCats = CategoryData.categories.take(7).toList();
    final moreCat = {
      'name': 'Más',
      'icon': Icons.grid_view,
      'bg': const Color(0xFFF2F4F8),
      'fg': const Color(0xFF3E4A59)
    };

    final displayCats = [...topCats, moreCat];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: displayCats.map((cat) {
        final name = cat['name'] as String;
        return CategoryItem(
          icon: cat['icon'] as IconData,
          label: name,
          bg: cat['bg'] as Color,
          fg: cat['fg'] as Color,
          onTap: () {
            if (name == 'Más') {
              _showAllCategories();
            } else {
              setState(() => _selectedCategory = name);
            }
          },
        );
      }).toList(),
    );
  }

  void _showAllCategories() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Todas las categorías',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                  children: CategoryData.categories.map((cat) {
                    final name = cat['name'] as String;
                    return CategoryItem(
                      icon: cat['icon'] as IconData,
                      label: name,
                      bg: cat['bg'] as Color,
                      fg: cat['fg'] as Color,
                      onTap: () {
                        setState(() => _selectedCategory = name);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildFilteredList(List<Professional> allPros, BuildContext context) {
      // 2. Filter client-side
      final displayPros = _selectedCategory == 'Todos'
          ? allPros
          : allPros.where((p) {
                // Normalize for comparison
                final pCat = p.category.trim().toLowerCase();
                final selCat = _selectedCategory.trim().toLowerCase();
                return pCat == selCat;
            }).toList();

      // 3. Filter by location
      final locationFiltered = _selectedCommune == null
          ? displayPros
          : displayPros.where((p) {
              final pCommune = p.commune.trim().toLowerCase();
              final selected = _selectedCommune!.trim().toLowerCase();
              
              return pCommune == selected || p.location.toLowerCase().contains(selected);
            }).toList();

      // 4. Search Filter (if text exists)
      if (_searchCtrl.text.trim().isNotEmpty) {
        final query = _searchCtrl.text.trim().toLowerCase();
        locationFiltered.retainWhere((p) {
          final name = p.name.toLowerCase();
          final cat = p.category.toLowerCase();
          return name.contains(query) || cat.contains(query);
        });
      }

      if (locationFiltered.isEmpty) {
        return [
          Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              _searchCtrl.text.isNotEmpty
                  ? 'No se encontraron resultados para tu búsqueda.'
                  : (_selectedCommune != null
                      ? 'No hay maestros en $_selectedCommune para $_selectedCategory'
                      : 'No hay maestros en $_selectedCategory'),
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        )
        ];
      }

      return locationFiltered
          .map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ProfessionalCard(
                  professional: p,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfessionalProfileScreen(
                            professional: p),
                      ),
                    );
                  },
                  onBook: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfessionalProfileScreen(
                            professional: p),
                      ),
                    );
                  },
                ),
              ))
          .toList();
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String? tempRegion = _selectedRegion;
        String? tempCommune = _selectedCommune;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona tu ubicación',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: tempRegion,
                    decoration: InputDecoration(
                      labelText: 'Región',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ChileData.regiones.keys.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        tempRegion = val;
                        tempCommune = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tempCommune,
                    decoration: InputDecoration(
                      labelText: 'Comuna',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: tempRegion == null
                        ? []
                        : ChileData.regiones[tempRegion]!.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                    onChanged: tempRegion == null
                        ? null
                        : (val) => setModalState(() => tempCommune = val),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _selectedRegion = tempRegion;
                          _selectedCommune = tempCommune;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Confirmar Ubicación'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(onPressed: onAction, child: Text(actionText)),
      ],
    );
  }
}
