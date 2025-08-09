import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/core/themes/app_theme.dart';
import 'package:finance_tracker/presentation/screens/splash_screen.dart';
import 'package:finance_tracker/core/services/notification_service.dart';
import 'package:finance_tracker/presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo notification service (không có push notifications)
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'MoneyFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}