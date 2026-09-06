import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NearbyItemsScreen extends StatefulWidget {
  const NearbyItemsScreen({super.key});

  @override
  State<NearbyItemsScreen> createState() => _NearbyItemsScreenState();
}

class _NearbyItemsScreenState extends State<NearbyItemsScreen> {
  static const Color primaryBlue = Color(0xFF1557D6);
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  int _viewIndex = 0; // 0 for Map, 1 for List
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: primaryBlue, foregroundColor: Colors.white,
        title: const Text('Nearby Items', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          List<dynamic> allItems = [];
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            if (data.containsKey('lost_items')) {
              Map<dynamic, dynamic> lost = data['lost_items'] as Map<dynamic, dynamic>;
              allItems.addAll(lost.values);
            }
            if (data.containsKey('found_items')) {
              Map<dynamic, dynamic> found = data['found_items'] as Map<dynamic, dynamic>;
              allItems.addAll(found.values);
            }
          }

          List<dynamic> filtered = allItems.where((item) {
            if (_filter == 'All') return true;
            return item['status'].toString().toLowerCase() == _filter.toLowerCase();
          }).toList();

          return Column(
            children: [
              _buildViewTabs(),
              _buildFilters(),
              Expanded(
                child: _viewIndex == 0 ? _buildMapView(filtered) : _buildListView(filtered),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildViewTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _viewTab(title: 'Map View', icon: Icons.map_outlined, index: 0),
          _viewTab(title: 'List View', icon: Icons.list_alt_outlined, index: 1),
        ],
      ),
    );
  }

  Widget _viewTab({required String title, required IconData icon, required int index}) {
    final selected = _viewIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _viewIndex = index),
        child: Container(
          height: 48, alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: selected ? primaryBlue : Colors.transparent, width: 2.5))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? primaryBlue : Colors.grey),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: selected ? primaryBlue : Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60, color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: ['All', 'Lost', 'Found'].map((f) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            label: Text(f, style: TextStyle(color: _filter == f ? Colors.white : Colors.black, fontSize: 11)),
            selected: _filter == f,
            onSelected: (val) => setState(() => _filter = f),
            selectedColor: primaryBlue,
            checkmarkColor: Colors.white,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMapView(List<dynamic> items) {
    return FlutterMap(
      options: const MapOptions(initialCenter: LatLng(33.7, 73.0), initialZoom: 12),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        MarkerLayer(
          markers: items.where((i) => i['latitude'] != null && i['longitude'] != null).map((item) {
            return Marker(
              point: LatLng(item['latitude'], item['longitude']),
              child: Icon(Icons.location_on, color: item['status'] == 'lost' ? Colors.red : Colors.green, size: 30),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildListView(List<dynamic> items) {
    if (items.isEmpty) return const Center(child: Text('No items found nearby'));
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
            title: Text(item['itemName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['location'] ?? 'No location'),
            trailing: Text(item['status'].toString().toUpperCase(), style: TextStyle(color: item['status'] == 'lost' ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        );
      },
    );
  }
}
