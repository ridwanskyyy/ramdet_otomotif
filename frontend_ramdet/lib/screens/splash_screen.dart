import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    
    // Memanggil fungsi validasi token yang telah kita buat di AuthProvider
    bool hasToken = await authProvider.checkTokenValidity(); 

    if (mounted) {
      if (hasToken) {
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.directions_car, color: Color(0xFF9E4300), size: 40),
                SizedBox(width: 12),
                Text(
                  'RAMDET',
                  style: TextStyle(
                    color: Color(0xFF9E4300),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Katalog Velg & Modifikasi Motor',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
            ),
          ],
        ),
      ),
    );
  }
}