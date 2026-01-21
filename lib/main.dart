import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qigwdnksooygwktvtmhv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpZ3dkbmtzb295Z3drdHZ0bWh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgwNzQxOTQsImV4cCI6MjA4MzY1MDE5NH0.gegSPRHECXlZVn2DMmx_nj66esfCCSddFviFHTopG34',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HikeMate',
      theme: ThemeData(
        primaryColor: const Color(0xFF0088D9),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
