import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/tactical_theme.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ShadowTraceApp()));
}

class ShadowTraceApp extends StatelessWidget {
  const ShadowTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShadowTrace',
      debugShowCheckedModeBanner: false,
      theme: TacticalTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
