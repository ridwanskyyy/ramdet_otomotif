import 'package:flutter/material.dart';

class TambahKendaraanScreen extends StatefulWidget {
  const TambahKendaraanScreen({super.key});

  @override
  State<TambahKendaraanScreen> createState() => _TambahKendaraanScreenState();
}

class _TambahKendaraanScreenState extends State<TambahKendaraanScreen> {
  String tipeKendaraan = 'Mobil'; // Nilai bawaan awal

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
          'Tambah Kendaraan',
          style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Register New Vehicle',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Masukkan detail kendaraan Anda untuk mempermudah pelacakan servis.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Pilihan Tipe Kendaraan (Kapsul Pilihan)
            const Text(
              'Tipe Kendaraan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildTypeButton('Mobil', Icons.directions_car, orangePrimary),
                const SizedBox(width: 12),
                _buildTypeButton('Motor', Icons.two_wheeler, orangePrimary),
              ],
            ),
            const SizedBox(height: 24),

            // Form Input Fields
            _buildFormInput('Nama Kendaraan', 'Contoh: Honda Civic RS', Icons.drive_file_rename_outline, inputBg),
            _buildFormInput('Nomor Plat Kendaraan', 'Contoh: B 1234 ABC', Icons.pin_outlined, inputBg),
            _buildFormInput('Tahun Produksi', 'Contoh: 2023', Icons.calendar_today_outlined, inputBg),
            _buildFormInput('Warna Kendaraan', 'Contoh: Dark Gray', Icons.color_lens_outlined, inputBg),

            const SizedBox(height: 32),

            // Tombol Simpan Kendaraan Baru
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
                    const SnackBar(content: Text('Kendaraan baru berhasil didaftarkan (Dummy)')),
                  );
                  Navigator.pop(context); // Kembali ke Garage
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  'Simpan Kendaraan',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Pembantu untuk Membuat Tombol Pilihan Mobil / Motor
  Widget _buildTypeButton(String type, IconData icon, Color activeColor) {
    bool isSelected = tipeKendaraan == type;
    return Expanded(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? activeColor : Colors.white,
          side: BorderSide(color: isSelected ? activeColor : Colors.grey.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          setState(() {
            tipeKendaraan = type;
          });
        },
        icon: Icon(icon, color: isSelected ? Colors.white : Colors.black),
        label: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget Pembantu Form Input
  Widget _buildFormInput(String label, String hint, IconData icon, Color bgColor) {
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
            style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 14),
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