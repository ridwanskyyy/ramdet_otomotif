import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // REVISI: State lokal untuk mengontrol visibilitas password
  bool _obscurePassword = true;

  @override
  void dispose() {
    // REVISI: Wajib dispose untuk mencegah memory leak
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengamati perubahan status loading dari AuthProvider
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF9E4300),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_car, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'RAMDET',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF9E4300), letterSpacing: 2),
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Akses layanan otomotif premium Anda.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'nama@email.com',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Lupa Password?', style: TextStyle(color: Color(0xFF9E4300), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        // REVISI: Mengubah Suffix Icon menjadi IconButton agar bisa diklik untuk toggle password
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Indikator loading sesuai dengan Dokumen Kebutuhan Sistem
                    authProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9E4300)),
                            onPressed: () async {
                              // REVISI: Validasi dasar sebelum menembak REST API Laravel
                              if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Email dan password tidak boleh kosong!')),
                                );
                                return;
                              }

                              final success = await context.read<AuthProvider>().login(
                                _emailController.text.trim(), 
                                _passwordController.text,
                              );
                              
                              if (success && context.mounted) {
                                Navigator.pushReplacementNamed(context, '/profile');
                              } else if (context.mounted) {
                                // Feedback Snackbar sesuai dengan Dokumen Kebutuhan Sistem
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Login Gagal! Email atau password Anda salah.')),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Masuk'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? '),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                    child: const Text('Daftar Sekarang', style: TextStyle(color: Color(0xFF9E4300), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}