import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    // Beri jeda 2-3 detik untuk menampilkan logo orisinil Ramdet Otomotif
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Ekstrak fungsi cek token valid dari AuthProvider yang kita buat kemarin
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isValid = await authProvider.checkTokenValidity();

    if (mounted) {
      if (isValid) {
        // Jika token aktif ada, langsung bypass masuk ke Dashboard Utama
        Navigator.pushReplacementNamed(context, '/products');
      } else {
        // Jika tidak ada token (belum login/sudah logout), arahkan ke gerbang Login
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pasang Icon atau Logo Ramdet Otomotif andalan kamu di sini
            Icon(Icons.directions_car_filled_outlined, size: 80, color: Color(0xFFFF6B00)),
            SizedBox(height: 16),
            Text(
              'Ramdet Otomotif',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B00),
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Color(0xFFFF6B00)),
          ],
        ),
      ),
    );
  }
}