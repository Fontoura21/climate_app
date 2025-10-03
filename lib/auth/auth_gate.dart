import 'package:flutter/material.dart';
import 'package:olly_app/pages/login_page.dart';
import 'package:olly_app/pages/weather_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        // check if user is logged in
        if (session != null) {
          return const WeatherPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
