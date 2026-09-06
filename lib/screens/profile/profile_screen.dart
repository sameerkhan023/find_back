import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  bool _isLoading = true;

  String _name = '';
  String _email = '';
  String _phone = '';

  static const Color primaryBlue = Color(0xFF1557D6);
  static const Color darkNavy = Color(0xFF0B1B3A);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // =========================
  // LOAD PROFILE
  // =========================
  Future<void> _loadProfile() async {
    try {
      final DataSnapshot snapshot = await _authService.getUserData();

      if (!mounted) return;

      if (snapshot.exists && snapshot.value != null) {
        final Map<String, dynamic> data =
        Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          _name = data['name']?.toString() ?? '';
          _email = data['email']?.toString() ?? '';
          _phone = data['phone']?.toString() ?? '';
          _isLoading = false;
        });
      } else {
        // If Realtime Database doesn't have the data,
        // use Firebase Authentication data as fallback.
        final user = _authService.currentUser;

        setState(() {
          _name = user?.displayName ?? '';
          _email = user?.email ?? '';
          _phone = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      // Try to get basic information from Firebase Auth
      final user = _authService.currentUser;

      setState(() {
        _name = user?.displayName ?? '';
        _email = user?.email ?? '';
        _phone = '';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load profile: $e'),
        ),
      );
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> _logout() async {
    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
        ),
      );
    }
  }

  // =========================
  // GET INITIALS
  // =========================
  String _getInitials() {
    if (_name.trim().isEmpty) {
      return 'U';
    }

    final parts = _name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // =========================
  // BUILD UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: darkNavy,
        ),
      ),

      // =========================
      // BODY
      // =========================
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: primaryBlue,
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // =========================
              // PROFILE AVATAR
              // =========================
              CircleAvatar(
                radius: 48,
                backgroundColor: primaryBlue,
                child: Text(
                  _getInitials(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // =========================
              // NAME
              // =========================
              Text(
                _name.isEmpty ? 'User' : _name,
                style: const TextStyle(
                  color: darkNavy,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              // =========================
              // EMAIL
              // =========================
              Text(
                _email.isEmpty ? 'No email available' : _email,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // ACCOUNT INFORMATION
              // =========================
              _buildSectionTitle('Account Information'),

              const SizedBox(height: 10),

              // NAME CARD
              _buildInfoCard(
                icon: Icons.person_outline,
                title: 'Name',
                value: _name.isEmpty ? 'Not provided' : _name,
              ),

              const SizedBox(height: 12),

              // EMAIL CARD
              _buildInfoCard(
                icon: Icons.email_outlined,
                title: 'Email',
                value: _email.isEmpty ? 'Not provided' : _email,
              ),

              const SizedBox(height: 12),

              // PHONE CARD
              _buildInfoCard(
                icon: Icons.phone_outlined,
                title: 'Phone',
                value: _phone.isEmpty ? 'Not added yet' : _phone,
              ),

              const SizedBox(height: 30),

              // =========================
              // LOGOUT BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: darkNavy,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================
  // INFORMATION CARD
  // =========================
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE7EAF0),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: primaryBlue,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}