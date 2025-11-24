import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for a bit

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/');
      return;
    }

    try {
      final userId = session.user.id;
      final metadata = session.user.userMetadata;
      final profile = await SupabaseService().getProfile(userId);

      if (mounted) {
        // Check if user is an advocate based on metadata or profile
        final isAdvocate = (metadata?['role'] == 'advocate') || 
                           (profile != null && profile['role'] == 'advocate');

        if (isAdvocate) {
          // If profile exists, go to dashboard
          if (profile != null) {
            Navigator.pushReplacementNamed(context, '/lawyer_dashboard');
          } else {
            // If profile missing, go to completion step
            Navigator.pushReplacementNamed(context, '/advocate_step1');
          }
        } else {
          // Default to client home
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      // If error, default to home
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
