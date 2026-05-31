import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isChecked = false; // Status checkbox S&K

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF9E4300)),
        title: Row(
          children: const [
            Icon(Icons.directions_car, color: Color(0xFF9E4300)),
            SizedBox(width: 8),
            Text('RAMDET', style: TextStyle(color: Color(0xFF9E4300), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Daftar Akun Baru',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bergabunglah dengan komunitas otomotif performa tinggi kami.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.3)), // Border tipis warna oren
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Budi Santoso',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'nama@email.com',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Min. 8 karakter',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: Icon(Icons.visibility_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Radio(
                        value: true,
                        groupValue: isChecked,
                        activeColor: const Color(0xFFFF6B00),
                        onChanged: (value) {
                          setState(() => isChecked = true);
                        },
                      ),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Saya menyetujui ',
                            style: TextStyle(fontSize: 12),
                            children: [
                              TextSpan(text: 'Syarat & Ketentuan\n', style: TextStyle(color: Color(0xFF9E4300), fontWeight: FontWeight.bold)),
                              TextSpan(text: 'serta '),
                              TextSpan(text: 'Kebijakan Privasi', style: TextStyle(color: Color(0xFF9E4300), fontWeight: FontWeight.bold)),
                              TextSpan(text: ' Ramdet Otomotif.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  authProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            if (!isChecked) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap setujui Syarat & Ketentuan')));
                              return;
                            }
                            final success = await context.read<AuthProvider>().register(
                              nameController.text, emailController.text, passwordController.text,
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Berhasil!')));
                              Navigator.pop(context);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Daftar'),
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
                const Text('Sudah punya akun? '),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('Login di sini', style: TextStyle(color: Color(0xFF9E4300), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}