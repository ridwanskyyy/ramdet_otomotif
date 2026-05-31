import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'profile_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');

    // Beri jeda sedikit agar efek splash screen terlihat elegan (opsional)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (token != null) {
        // Token ada, langsung masuk ke dalam aplikasi
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      } else {
        // Token tidak ada, arahkan ke halaman Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        // Tampilkan logo aplikasi atau loading spinner saat mengecek sesi
        child: CircularProgressIndicator(),
      ),
    );
  }
}