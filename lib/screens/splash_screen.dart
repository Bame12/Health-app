import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healthadmin/providers/auth_provider.dart';
import 'package:healthadmin/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Navigate after delay
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() async {
    try {
      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Add delay for splash screen
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        if (authProvider.isLoggedIn) {
          context.go('/home');
        } else {
          context.go('/auth');
        }
      }
    } catch (e) {
      print('Error in splash navigation: $e');
      if (mounted) {
        // Navigate to auth on error
        context.go('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 2),
                  // Logo with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        'assets/images/Logo.png',
                        width: screenSize.width * 0.6,
                        height: screenSize.width * 0.6,
                        errorBuilder: (_, __, ___) => Container(
                          width: screenSize.width * 0.6,
                          height: screenSize.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.medical_services,
                            size: screenSize.width * 0.3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // App name with fade animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'HealthAdmin',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your Health, Our Priority',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Spacer(flex: 3),
                  
                  // Developer info with delay animation
                  Opacity(
                    opacity: _animationController.value > 0.7 ? 
                      (_animationController.value - 0.7) * (1/0.3) : 0,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Developed by',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Bame Junior Noko',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'NB22000934',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Loading indicator
                  Opacity(
                    opacity: _animationController.value > 0.5 ? 1.0 : 0.0,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  
                  Spacer(),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
