import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/auth_model.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';
import '../welcome_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isFirstTime = true;
  bool _isCheckingFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('is_first_time') ?? true;
    
    setState(() {
      _isFirstTime = isFirstTime;
      _isCheckingFirstTime = false;
    });
  }

  Future<void> markNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
    setState(() {
      _isFirstTime = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingFirstTime) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isFirstTime) {
      return const WelcomeScreen();
    }

    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: Builder(
        builder: (context) {
          switch (authState) {
            case AuthState.initial:
            case AuthState.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );
            
            case AuthState.authenticated:
              return const MainScreen();
            
            case AuthState.unauthenticated:
            case AuthState.error:
              return const LoginScreen();
          }
        },
      ),
    );
  }
}