import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  static const Color primaryBlue = Color(0xFF1557D6);
  static const Color darkNavy = Color(0xFF0B1B3A);

  final List<AlertItem> _alerts = [
    AlertItem(
      title: 'Report Published',
      message: 'Your lost item report has been published successfully.',
      time: '10m ago',
      icon: Icons.campaign_outlined,
      color: Colors.red,
      unread: true,
    ),
    AlertItem(
      title: 'New Match Found',
      message: 'A new match was found for your lost item "Black Wallet".',
      time: '1h ago',
      icon: Icons.location_searching,
      color: Colors.blue,
      unread: true,
    ),
    AlertItem(
      title: 'Claim Request',
      message: 'Your claim request has been accepted.',
      time: '2h ago',
      icon: Icons.check_circle_outline,
      color: Colors.green,
      unread: false,
    ),
    AlertItem(
      title: 'Reminder',
      message: 'Update your report if your lost item is still missing.',
      time: '1d ago',
      icon: Icons.notifications_active_outlined,
      color: Colors.pink,
      unread: false,
    ),
  ];

  int get unreadCount {
    return _alerts.where((alert) => alert.unread).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Alerts',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),

      body: _alerts.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          15,
          16,
          15,
          25,
        ),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          return _buildAlertCard(
            _alerts[index],
            index,
          );
        },
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // =========================================================
  // ALERT CARD
  // =========================================================

  Widget _buildAlertCard(
      AlertItem alert,
      int index,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _alerts[index] = alert.copyWith(
            unread: false,
          );
        });

        _showAlertDetails(alert);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFE6EAF0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                color: alert.color.withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                alert.icon,
                color: alert.color,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: const TextStyle(
                            color: darkNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        alert.time,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    alert.message,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            if (alert.unread)
              Container(
                margin: const EdgeInsets.only(
                  left: 7,
                  top: 3,
                ),
                height: 7,
                width: 7,
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DETAILS
  // =========================================================

  void _showAlertDetails(AlertItem alert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: alert.color.withOpacity(.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        alert.icon,
                        color: alert.color,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        alert.title,
                        style: const TextStyle(
                          color: darkNavy,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  alert.message,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  alert.time,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // MARK ALL READ
  // =========================================================

  void _markAllRead() {
    setState(() {
      for (int i = 0; i < _alerts.length; i++) {
        _alerts[i] = _alerts[i].copyWith(
          unread: false,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'All alerts marked as read',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 40,
              color: primaryBlue,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No Alerts',
            style: TextStyle(
              color: darkNavy,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'You are all caught up!',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM NAVIGATION
  // =========================================================

  Widget _buildBottomNavigation() {
    return NavigationBar(
      height: 72,
      backgroundColor: Colors.white,
      selectedIndex: 3,
      indicatorColor: primaryBlue.withOpacity(.10),

      onDestinationSelected: (index) {
        if (index == 0) {
          Navigator.pop(context);
        }

        if (index == 1) {
          Navigator.pop(context);
        }
      },

      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: 'Reports',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'Add',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_none),
          selectedIcon: Icon(Icons.notifications),
          label: 'Alerts',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

// =========================================================
// MODEL
// =========================================================

class AlertItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool unread;

  AlertItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    required this.unread,
  });

  AlertItem copyWith({
    String? title,
    String? message,
    String? time,
    IconData? icon,
    Color? color,
    bool? unread,
  }) {
    return AlertItem(
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      unread: unread ?? this.unread,
    );
  }
}