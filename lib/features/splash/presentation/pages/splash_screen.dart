import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main entry animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Continuous pulsing animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_mainController);

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    ));

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _mainController.forward();
    _navigateToNext();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      final authState = Provider.of<AuthState>(context, listen: false);
      
      // If the user is already authenticated, go to home, otherwise go to login
      if (authState.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Animated Gradient & Rings
          _buildAnimatedBackground(),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with Pulse and Entry Animation
              _buildAnimatedLogo(),
              
              const SizedBox(height: 40),

              // Text with Slide and Fade Animation
              _buildBrandingText(),
            ],
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 80,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildLoader(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Radial Glow
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.05 * _pulseController.value),
                    AppColors.background,
                  ],
                  radius: 1.5,
                ),
              ),
            ),
            // Floating rings
            ...List.generate(3, (index) {
              final double scale = 1.0 + (index * 0.4) + (_pulseController.value * 0.1);
              return Opacity(
                opacity: (0.1 - (index * 0.03)).clamp(0, 1),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: RotationTransition(
        turns: _rotateAnimation,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15 + (_pulseController.value * 0.1)),
                    blurRadius: 40 + (_pulseController.value * 20),
                    spreadRadius: 5 + (_pulseController.value * 10),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Image.asset(
            'assets/images/aafiya_logo.png',
            width: 160,
            height: 160,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.health_and_safety_rounded,
              size: 120,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingText() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Text(
              'AAFIYAH',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 12,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1),
                ),
              ),
              child: Text(
                'YOUR HEALTH • OUR PRIORITY',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary.withOpacity(0.8),
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Column(
      children: [
        const SizedBox(
          width: 40,
          height: 2,
          child: LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'LOADING',
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.5),
            fontSize: 10,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
