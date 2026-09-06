import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF040B1A), // Very dark navy at top
              Color(0xFF0A1E3D), // Slightly lighter navy at bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            // Detailed Skyline
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.3,
                child: SizedBox(
                  height: 120,
                  child: CustomPaint(
                    painter: DetailedSkylinePainter(),
                  ),
                ),
              ),
            ),

            // Glow Line
            Positioned(
              bottom: 85,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.6),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Exact Logo Design
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Magnifying Glass Ring
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 8),
                          ),
                        ),
                        // Handle
                        Positioned(
                          bottom: 15,
                          right: 15,
                          child: Transform.rotate(
                            angle: 0.785, // 45 degrees
                            child: Container(
                              width: 12,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        // Inner Blue Handle part
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Transform.rotate(
                            angle: 0.785,
                            child: Container(
                              width: 8,
                              height: 15,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        // Location Pin
                        const Icon(
                          Icons.location_on_rounded,
                          size: 55,
                          color: Color(0xFF3B82F6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // "FindBack" Text
                  const Text(
                    'FindBack',
                    style: TextStyle(
                      color: Color(0xFF4FA5F1), // Bright vibrant blue
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tagline
                  const Text(
                    'Find what you lost,',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Text(
                    'Reunite what matters.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Progress Indicator
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 140,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: Container(
                          width: 140 * _animation.value,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedSkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    double w = size.width;
    double h = size.height;

    path.moveTo(0, h);
    path.lineTo(0, h * 0.8);
    path.lineTo(w * 0.05, h * 0.8);
    path.lineTo(w * 0.05, h * 0.65);
    path.lineTo(w * 0.1, h * 0.65);
    path.lineTo(w * 0.1, h * 0.85);
    
    // Dome shape
    path.quadraticBezierTo(w * 0.15, h * 0.5, w * 0.2, h * 0.85);
    
    path.lineTo(w * 0.25, h * 0.85);
    path.lineTo(w * 0.25, h * 0.55);
    path.lineTo(w * 0.3, h * 0.55);
    path.lineTo(w * 0.3, h * 0.75);
    
    // Pointy building
    path.lineTo(w * 0.35, h * 0.3);
    path.lineTo(w * 0.4, h * 0.75);
    
    path.lineTo(w * 0.45, h * 0.75);
    path.lineTo(w * 0.45, h * 0.6);
    path.lineTo(w * 0.55, h * 0.6);
    path.lineTo(w * 0.55, h * 0.8);
    
    // Large dome
    path.quadraticBezierTo(w * 0.65, h * 0.35, w * 0.75, h * 0.8);
    
    path.lineTo(w * 0.8, h * 0.8);
    path.lineTo(w * 0.8, h * 0.5);
    path.lineTo(w * 0.85, h * 0.5);
    path.lineTo(w * 0.85, h * 0.7);
    path.lineTo(w * 0.92, h * 0.7);
    path.lineTo(w * 0.92, h * 0.85);
    path.lineTo(w, h * 0.85);
    path.lineTo(w, h);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
