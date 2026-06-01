import 'package:flutter/material.dart';

class TambahAlamatScreen extends StatefulWidget {
  const TambahAlamatScreen({super.key});

  @override
  State<TambahAlamatScreen> createState() => _TambahAlamatScreenState();
}

class _TambahAlamatScreenState extends State<TambahAlamatScreen> {
  bool isDefault = false;

  @override
  Widget build(BuildContext context) {
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
          'Tambah Alamat',
          style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Location',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Simpan alamat baru untuk mempercepat proses pemesanan layanan servis.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Form Input Fields
            _buildFormInput('Label Alamat', 'Contoh: Rumah, Kantor, Kos', Icons.bookmark_outline, inputBg, maxLines: 1),
            _buildFormInput('Detail Alamat / Nama Jalan', 'Masukkan nama jalan, nomor rumah, RT/RW', Icons.location_on_outlined, inputBg, maxLines: 3),
            _buildFormInput('Patokan (Opsional)', 'Contoh: Samping pagar hitam / Depan warung', Icons.explore_outlined, inputBg, maxLines: 1),

            const SizedBox(height: 10),

            // Opsi Set Sebagai Alamat Utama
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jadikan Alamat Utama',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                ),
                Switch(
                  value: isDefault,
                  activeColor: orangePrimary,
                  onChanged: (value) {
                    setState(() {
                      isDefault = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tombol Simpan Alamat
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
                    const SnackBar(content: Text('Alamat baru berhasil disimpan! (Dummy)')),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  'Simpan Alamat',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormInput(String label, String hint, IconData icon, Color bgColor, {required int maxLines}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: maxLines,
            style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.grey),
              filled: true,
              fillColor: bgColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(maxLines > 1 ? 20 : 30), 
                borderSide: BorderSide.none
              ),
            ),
          ),
        ],
      ),
    );
  }
}