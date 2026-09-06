import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

// =====================================================
// SCREENS
// =====================================================

import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/reports/my_reports_screen.dart';
import 'screens/alerts/alerts_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/items/report_lost_screen.dart';
import 'screens/items/found_items_screen.dart';
import 'screens/items/nearby_items_screen.dart';

Future<void> main() async {
  // Make sure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // =====================================================
  // FIREBASE INITIALIZATION
  // =====================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // =====================================================
  // RUN APP
  // =====================================================

  runApp(const FindBackApp());
}

class FindBackApp extends StatelessWidget {
  const FindBackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // =====================================================
      // APP SETTINGS
      // =====================================================

      debugShowCheckedModeBanner: false,

      title: 'FindBack - Smart Lost & Found',

      // =====================================================
      // THEME
      // =====================================================

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1557D6),
        ),

        scaffoldBackgroundColor:
        const Color(0xFFF5F7FB),

        // ===================================================
        // APP BAR
        // ===================================================

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0B1B3A),
          elevation: 0,
          centerTitle: false,
        ),

        // ===================================================
        // TEXT FIELDS
        // ===================================================

        inputDecorationTheme: InputDecorationTheme(
          filled: true,

          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE3E7EF),
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE3E7EF),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF1557D6),
              width: 1.5,
            ),
          ),
        ),

        // ===================================================
        // ELEVATED BUTTON
        // ===================================================

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
            const Color(0xFF1557D6),

            foregroundColor: Colors.white,

            elevation: 0,

            minimumSize: const Size(
              double.infinity,
              48,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // =====================================================
      // INITIAL ROUTE
      // =====================================================

      initialRoute: '/splash',

      // =====================================================
      // APP ROUTES
      // =====================================================

      routes: {
        // ---------------------------------------------------
        // SPLASH SCREEN
        // ---------------------------------------------------

        '/splash': (context) =>
        const SplashScreen(),

        // ---------------------------------------------------
        // HOME SCREEN
        // ---------------------------------------------------

        '/': (context) =>
        const HomeScreen(),

        // ---------------------------------------------------
        // MY REPORTS
        // ---------------------------------------------------

        '/reports': (context) =>
        const MyReportsScreen(),

        // ---------------------------------------------------
        // NEARBY ITEMS
        // ---------------------------------------------------

        '/nearby': (context) =>
        const NearbyItemsScreen(),

        // ---------------------------------------------------
        // ALERTS
        // ---------------------------------------------------

        '/alerts': (context) =>
        const AlertsScreen(),

        // ---------------------------------------------------
        // PROFILE
        // ---------------------------------------------------

        '/profile': (context) =>
        const ProfileScreen(),

        // ---------------------------------------------------
        // REPORT LOST ITEM
        // ---------------------------------------------------

        '/report-lost': (context) =>
        const ReportLostItemScreen(),

        // ---------------------------------------------------
        // FOUND ITEM
        // ---------------------------------------------------

        '/found-item': (context) =>
        const FoundItemScreen(),
      },
    );
  }
}