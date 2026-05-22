import 'package:flutter/material.dart';
import '../app_branding.dart';
import '../app_colors.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Duration displayDuration = Duration(seconds: 5);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(SplashScreen.displayDuration);
    if (!mounted) return;

    Widget destination = const LoginScreen();

    if (await AuthStorage.hasSession()) {
      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        try {
          final user = await AuthService.verifyToken(token);
          destination = HomeScreen(
            userName: user.displayName,
            userEmail: user.email,
            currency: user.devise,
          );
        } on AuthException {
          await AuthStorage.clear();
        } catch (_) {
          final cached = await AuthStorage.getUser();
          if (cached != null) {
            destination = HomeScreen(
              userName: cached.displayName,
              userEmail: cached.email,
              currency: cached.devise,
            );
          }
        }
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(120),
                    const SizedBox(height: 28),
                    Text(
                      AppBranding.appName,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gérez votre budget en toute simplicité',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.mediumGray,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.mintSurface,
        border: Border.all(color: AppColors.fieldBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          AppBranding.logoAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.account_balance_wallet_rounded,
            size: 56,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
