import 'package:flutter/material.dart';

class EditKendaraanScreen extends StatefulWidget {
  final String namaAwal;
  final String platAwal;
  final String spekAwal;
  final String tipeAwal; // 'Mobil' atau 'Motor'

  const EditKendaraanScreen({
    super.key,
    required this.namaAwal,
    required this.platAwal,
    required this.spekAwal,
    required this.tipeAwal,
  });

  @override
  State<EditKendaraanScreen> createState() => _EditKendaraanScreenState();
}

class _EditKendaraanScreenState extends State<EditKendaraanScreen> {
  late String tipeKendaraan;

  @override
  void initState() {
    super.initState();
    // Set pilihan awal sesuai data yang dikirim
    tipeKendaraan = widget.tipeAwal;
  }

  @override
  Widget build(BuildContext context) {
    const Color orangePrimary = Color(0xFFFF6B00);
    const Color rustBrown = Color(0xFF9E4300);
    const Color bgLight = Color(0xFFF9F9F9);
    const Color inputBg = Color(0xFFF2F2F2);

    // Memecah spek dummy (contoh: "2022 • White Pearl") untuk mengisi form
    List<String> splitSpek = widget.spekAwal.split(' • ');
    String tahunAwal = splitSpek.isNotEmpty ? splitSpek[0] : '';
    String warnaAwal = splitSpek.length > 1 ? splitSpek[1] : '';

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
          'Ubah Detail Kendaraan',
          style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Vehicle Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Perbarui informasi kendaraan Anda jika terdapat kesalahan data.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Pilihan Tipe Kendaraan
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

            // Form Input Fields dengan Nilai Awal (Initial Value)
            _buildFormInput('Nama Kendaraan', widget.namaAwal, Icons.drive_file_rename_outline, inputBg),
            _buildFormInput('Nomor Plat Kendaraan', widget.platAwal, Icons.pin_outlined, inputBg),
            _buildFormInput('Tahun Produksi', tahunAwal, Icons.calendar_today_outlined, inputBg),
            _buildFormInput('Warna Kendaraan', warnaAwal, Icons.color_lens_outlined, inputBg),

            const SizedBox(height: 32),

            // Tombol Simpan Perubahan
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
                    const SnackBar(content: Text('Perubahan data kendaraan berhasil disimpan (Dummy)')),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save_as_outlined, color: Colors.white),
                label: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildFormInput(String label, String initialValue, IconData icon, Color bgColor) {
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