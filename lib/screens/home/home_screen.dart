import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../items/found_items_screen.dart';
import '../items/nearby_items_screen.dart';
import '../items/report_lost_screen.dart';
import '../reports/my_reports_screen.dart';
import '../alerts/alerts_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Color primaryBlue = const Color(0xFF0052CC);

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildHomeContent(),
      const MyReportsScreen(),
      const SizedBox(), // Placeholder for central button action
      const AlertsScreen(),
      const ProfileScreen(),
    ];
  }

  void _openScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _selectedIndex == 2 ? _screens[0] : _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigation(primaryBlue),
      floatingActionButton: _buildCentralAddButton(primaryBlue),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(primaryBlue),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickActionsGrid(),
                const SizedBox(height: 30),
                _buildRecentlyFoundHeader(primaryBlue),
                const SizedBox(height: 16),
                _buildRecentlyFoundList(),
                const SizedBox(height: 100), // Bottom padding for FAB
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryBlue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        color: primaryBlue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hi, Sameer 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What are you looking for?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 4),
                child: Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white.withOpacity(0.9),
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search lost & found items...',
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 15),
                      filled: false,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildActionCard(
          icon: Icons.location_on,
          iconColor: Colors.orange,
          title: 'Report Lost\nItem',
          onTap: () => _openScreen(const ReportLostItemScreen()),
        ),
        _buildActionCard(
          icon: Icons.person_search,
          iconColor: Colors.indigo,
          title: 'Found\nSomething?',
          onTap: () => _openScreen(const FoundItemScreen()),
        ),
        _buildActionCard(
          icon: Icons.description,
          iconColor: Colors.green,
          title: 'My\nReports',
          onTap: () => setState(() => _selectedIndex = 1),
        ),
        _buildActionCard(
          icon: Icons.near_me,
          iconColor: Colors.blue,
          title: 'Nearby\nItems',
          onTap: () => _openScreen(const NearbyItemsScreen()),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyFoundHeader(Color primaryBlue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recently Found',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        TextButton(
          onPressed: () => _openScreen(const FoundItemScreen()),
          child: Text(
            'See all',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyFoundList() {
    return SizedBox(
      height: 200,
      child: StreamBuilder(
        stream: FirebaseDatabase.instance.ref().child('found_items').limitToLast(5).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) return const Center(child: Text('No recent items'));

          Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<dynamic> items = map.values.toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildFoundCard(
                Icons.inventory_2_outlined,
                item['itemName'] ?? 'Unknown',
                item['location'] ?? 'Found recently',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFoundCard(IconData icon, String title, String subtitle) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 48, color: Colors.blueGrey[300]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(Color primaryBlue) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home, 'Home', 0, _selectedIndex == 0, primaryBlue),
            _buildNavItem(Icons.assignment_outlined, 'Reports', 1, _selectedIndex == 1, primaryBlue),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(Icons.notifications_none, 'Alerts', 3, _selectedIndex == 3, primaryBlue),
            _buildNavItem(Icons.person_outline, 'Profile', 4, _selectedIndex == 4, primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isSelected, Color primaryBlue) {
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? primaryBlue : Colors.grey, size: 26),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryBlue : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralAddButton(Color primaryBlue) {
    return FloatingActionButton(
      onPressed: () => _openScreen(const ReportLostItemScreen()),
      backgroundColor: primaryBlue,
      elevation: 4,
      child: const Icon(Icons.add, color: Colors.white, size: 32),
    );
  }
}
