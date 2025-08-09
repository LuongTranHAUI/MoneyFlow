import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../providers/auth_provider.dart';
import 'main_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthStatus();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  void _checkAuthStatus() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    try {
      // Check auth status directly from service for more reliable check
      final authService = ref.read(authServiceProvider);
      final isLoggedIn = await authService.isLoggedIn();
      final currentUser = await authService.getCurrentUser();
      
      if (mounted) {
        if (isLoggedIn && currentUser != null) {
          // User is logged in, navigate to main screen
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        } else {
          // User is not logged in, navigate to login screen
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      }
    } catch (e) {
      // Error checking auth status, navigate to login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.8),
              colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 60,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // App Name
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              'MoneyFlow',
                              style: textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Quản lý tài chính cá nhân',
                              style: textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Loading indicator
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.8),
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Đang khởi tạo...',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const Spacer(),
                
                // Version info at the bottom
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Text(
                          'Version 1.0.0',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}