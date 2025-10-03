import 'package:flutter/material.dart';
import 'package:olly_app/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hrwkcuxzmkemrfsugbup.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhyd2tjdXh6bWtlbXJmc3VnYnVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzMzM0ODEsImV4cCI6MjA3NDkwOTQ4MX0.BjxrKg1sOg60fF4jzN1peWNRQ4RHJoaqDTJkI-tW0V0',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Olly App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B73FF)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
