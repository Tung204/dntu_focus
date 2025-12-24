import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    print('Khởi tạo SplashScreen');

    // Tạo animation controller với duration 2.5 giây
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Animation fade in (0.0 -> 1.0) trong 800ms đầu
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.32, curve: Curves.easeIn),
      ),
    );

    // Animation fade out (1.0 -> 0.0) ở 600ms cuối
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.76, 1.0, curve: Curves.easeOut),
      ),
    );

    // Bắt đầu animation
    _animationController.forward();

    // Chờ animation hoàn thành rồi navigate
    _waitAndNavigate();
  }

  Future<void> _waitAndNavigate() async {
    // Chờ animation hoàn thành (2.5 giây)
    await _animationController.forward();

    // Kiểm tra trạng thái đăng nhập và chuyển màn hình
    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      Navigator.pushReplacementNamed(
        context,
        user != null ? AppRoutes.home : AppRoutes.login,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          // Kết hợp cả fade in và fade out
          final opacity = _animationController.value < 0.76
              ? _fadeInAnimation.value
              : _fadeOutAnimation.value;

          return Opacity(
            opacity: opacity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo_inapp.png',
                    width: 180,
                    height: 180,
                  ),
                  const SizedBox(height: 24),
                  // Text "Moji Focus"
                  Text(
                    'Moji Focus',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade400,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}