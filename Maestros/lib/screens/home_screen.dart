import 'package:flutter/material.dart';
import 'package:maestros_app/widgets/promo_card.dart';
import 'package:maestros_app/widgets/category_item.dart';
import 'package:maestros_app/widgets/professional_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF137fec)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Your Location',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'New York, NY',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search for services...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                PromoCard(
                  offer: 'Limited Offer',
                  title: '20% Off First\nPlumbing Service',
                  subtitle: 'Book by end of the week',
                  buttonText: 'Claim Now',
                  color: Color(0xFF137fec),
                  icon: Icons.plumbing,
                ),
                PromoCard(
                  offer: 'New Service',
                  title: 'Professional\nHome Cleaning',
                  subtitle: r'Starting from only $49',
                  buttonText: 'Explore',
                  color: Color(0xFF10b981),
                  icon: Icons.cleaning_services,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              CategoryItem(icon: Icons.bolt, label: 'Electrician', color: Color(0xFF137fec)),
              CategoryItem(icon: Icons.plumbing, label: 'Plumber', color: Colors.orange),
              CategoryItem(icon: Icons.format_paint, label: 'Painter', color: Colors.purple),
              CategoryItem(icon: Icons.cleaning_services, label: 'Cleaner', color: Colors.red),
              CategoryItem(icon: Icons.ac_unit, label: 'AC Repair', color: Colors.blue),
              CategoryItem(icon: Icons.pest_control, label: 'Pest Control', color: Colors.yellow),
              CategoryItem(icon: Icons.carpenter, label: 'Carpenter', color: Colors.green),
              CategoryItem(icon: Icons.grid_view, label: 'More', color: Colors.grey),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recommended Professionals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          const ProfessionalCard(
            name: 'John Smith',
            rating: '4.9',
            specialty: 'Expert Electrician • 8 yrs exp',
            price: r'$45',
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCLnT3M4OhaDLbIX2kUSlQzn46NtswV-PszEB3NLphreWy7WyoqXNPNpKaWoravFCF51ykYKEvGRxGrkLMtCJq4Z7I1DWP79cqW5JZWba2VgQ3n9_eWYNRE6-fHUJ25IFZ1p4wK1OE0Q70rTIFNpZGFdzDhRfi-cEhxXVcRsgejWG1AyFcU79V7-ToeLx9q_KpcWCGmLb_Tl3ctJhpo8WaxDFV-tjdE6xF48tXIRE8iUhdYAlKWMu5HFa_5RTLmea4hzOmJ1zJLJMkS',
          ),
          const ProfessionalCard(
            name: 'Elena Rodriguez',
            rating: '4.8',
            specialty: 'Certified Interior Painter',
            price: r'$38',
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCnxu4xADoDNHr_i2FTbqsVQyWjPiZ8kgt1Szbc7flsoxLXllWw76LkuDbsb55vPNuC7iveh5_t327_-2_rUdToqeIzPVwYYCKkSntdBVm16jk9YhRWFmR7pSSLvS0dt_uk1VRpmZOEEOfTQays-pH6NVGKZsKhbDMwwZB8qj1gOfrcSM5DIS3U0I79R-n3fKfk67fRWANhwhVuhC1CnH2eiJv2fCZWq5GTalIZ2Ro8Em2tyrXy6Z1pVnf0r4OYFL2XrnphJMHPaQNi',
          ),
          const ProfessionalCard(
            name: 'Marcus Chen',
            rating: '4.7',
            specialty: 'Master Plumber • Commercial',
            price: r'$55',
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuC3xXM59GI0m60q-CrGwB6XGgb95BiXB7ZB4qk_4P8nPV9umoFv-jgvWUWg5rCH3PNkpSykjI6FFog-TqPpsJcHsSFIs2H0UYWkHn21YpKo4ndI0uHhhN1y_dE7ywpYJUl02cijH2e0HBBaH2bbwInDJPmvHr7y6r_oK9VmHoZnTTZeGVwoDJ5eDOjzPXpdtL5PKc7uCaC1KwKcCljhdikP-Vp8FeKYYfHP6jA8-yBByOWknY6k2HrdKmPw2m-izD-xAhza_1f_lRap',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF137fec),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }
}
