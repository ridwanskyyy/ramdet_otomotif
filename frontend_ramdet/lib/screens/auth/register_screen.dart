import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // REVISI: Menyeragamkan penamaan controller menggunakan underscore (_) agar sinkron dengan fungsi submit
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isChecked = false; 
  bool obscurePassword = true;

  @override
  void dispose() {
    // REVISI: Membersihkan SELURUH 5 controller dari memori agar aplikasi tidak bocor (leak)
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
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
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Budi Santoso',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'nama@email.com',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TAMBAHAN: Tampilan Input Nomor Telepon di Form UI
                  const Text('Nomor Telepon', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 08123456789',
                      prefixIcon: Icon(Icons.phone_android_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TAMBAHAN: Tampilan Input Alamat Rumah di Form UI
                  const Text('Alamat Rumah', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan alamat lengkap pengiriman',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Min. 8 karakter',
                      prefixIcon: const Icon(Icons.lock_outline),
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
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
                      : ElevatedButton(
                          onPressed: () async {
                            final name = _nameController.text.trim();
                            final email = _emailController.text.trim();
                            final phone = _phoneController.text.trim();
                            final address = _addressController.text.trim();
                            final password = _passwordController.text;

                            // REVISI: Validasi kelengkapan data input mencakup aturan field baru
                            if (name.isEmpty || email.isEmpty || phone.isEmpty || address.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Semua kolom formulir wajib diisi.')),
                              );
                              return;
                            }

                            if (!email.contains('@') || !email.contains('.')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Format email tidak valid (wajib mengandung @ dan domain).')),
                              );
                              return;
                            }

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

                            // REVISI: Pemanggilan fungsi register menggunakan variabel lokal bersih yang sudah lolos validasi
                            final success = await authProvider.register(
                              name: name,
                              email: email,
                              password: password,
                              phone: phone,    
                              address: address, 
                            );
                            
                            if (context.mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registrasi Berhasil! Silakan masuk.'), backgroundColor: Colors.green),
                                );
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registrasi gagal. Email mungkin sudah terdaftar.'), backgroundColor: Colors.redAccent),
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