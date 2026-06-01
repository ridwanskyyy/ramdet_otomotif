import 'package:flutter/material.dart';

class EditProfilScreen extends StatelessWidget {
  const EditProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisikan palet warna sesuai mockup
    const Color orangePrimary = Color(0xFFFF6B00);
    const Color rustBrown = Color(0xFF9E4300);
    const Color bgLight = Color(0xFFF9F9F9);
    const Color inputBg = Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ramdet Otomotif',
          style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar Stack dengan Edit Badge
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: orangePrimary, width: 3),
                      image: const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/150'), // Ganti dengan foto mekanik/user
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: orangePrimary, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Edit Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: rustBrown),
            ),
            const SizedBox(height: 4),
            const Text(
              'ID: RAM-99201-DT',
              style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Form Fields (Capsule Style)
            _buildInputField('Nama Lengkap', 'Ahmad Ramadhan', Icons.person_outline, inputBg),
            _buildInputField('Alamat Email', 'ahmad.ramadhan@example.com', Icons.email_outlined, inputBg),
            _buildInputField('Nomor Telepon', '+62 812-3456-7890', Icons.phone_outlined, inputBg),
            _buildInputField('Alamat Utama', 'Jl. Otomotif Raya No. 42, Jakarta Selatan', Icons.location_on_outlined, inputBg),
            
            const SizedBox(height: 24),

            // Tombol Simpan Orange Capsule
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangePrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil disimpan!')),
                  );
                },
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Catatan Sinkronisasi Sistem (Monospace style)
            const Text(
              'Pembaruan profil dapat memakan waktu hingga 5 menit untuk sinkronisasi sistem.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String initialValue, IconData icon, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey),
              filled: true,
              fillColor: bgColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}