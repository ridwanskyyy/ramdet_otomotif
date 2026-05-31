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
  
  // REVISI: Mengubah tipe data untuk kontrol Checkbox yang tepat
  bool isChecked = false; 
  
  // REVISI: Menambahkan state kontrol visibilitas teks password
  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
              'Bergabunglah dengan komunitas otomotif performa tinggi kami!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.3)),
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
                    keyboardType: TextInputType.emailAddress,
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
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Min. 8 karakter',
                      prefixIcon: const Icon(Icons.lock_outline),
                      // REVISI: Mengaktifkan fungsionalitas interaktif tombol mata password
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      // REVISI: Mengganti Radio menjadi Checkbox agar bisa dicentang dan dilepas secara dinamis
                      Checkbox(
                        value: isChecked,
                        activeColor: const Color(0xFFFF6B00),
                        onChanged: (value) {
                          setState(() => isChecked = value ?? false);
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
                            final name = nameController.text.trim();
                            final email = emailController.text.trim();
                            final password = passwordController.text;

                            // REVISI: Validasi kelengkapan data input awal
                            if (name.isEmpty || email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Semua kolom formulir wajib diisi.')),
                              );
                              return;
                            }

                            // REVISI: Validasi format email sesuai Aturan Bisnis Otentikasi
                            if (!email.contains('@') || !email.contains('.')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Format email tidak valid (wajib mengandung @ dan domain).')),
                              );
                              return;
                            }

                            // REVISI: Validasi panjang password sesuai Aturan Bisnis Otentikasi
                            if (password.length < 8) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password minimal harus terdiri dari 8 karakter.')),
                              );
                              return;
                            }

                            if (!isChecked) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Harap setujui Syarat & Ketentuan terlebih dahulu.')),
                              );
                              return;
                            }

                            // Eksekusi registrasi dengan parameter yang sesuai kontrak API Postman
                            final success = await context.read<AuthProvider>().register(name, email, password);
                            
                            if (context.mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registrasi Berhasil!')),
                                );
                                Navigator.pop(context);
                              } else {
                                // REVISI: Memberikan umpan balik snackbar apabila gagal sesuai Aturan Antarmuka
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registrasi gagal. Silakan periksa kembali data atau koneksi Anda.')),
                                );
                              }
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