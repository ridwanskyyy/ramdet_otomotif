import 'package:flutter/material.dart';

class EditAlamatScreen extends StatefulWidget {
  final String labelAwal;
  final String detailAwal;
  final String tagAwal;

  const EditAlamatScreen({
    super.key,
    required this.labelAwal,
    required this.detailAwal,
    required this.tagAwal,
  });

  @override
  State<EditAlamatScreen> createState() => _EditAlamatScreenState();
}

class _EditAlamatScreenState extends State<EditAlamatScreen> {
  late bool isDefault;

  @override
  void initState() {
    super.initState();
    // Jika tag awalnya 'DEFAULT', otomatis nyalakan switch utama
    isDefault = widget.tagAwal == 'DEFAULT';
  }

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
          'Ubah Alamat',
          style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Location Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Perbarui informasi lokasi Anda agar mempermudah mekanik menemukan rute perjalanan.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Form Input Fields dengan Initial Value bawaan alamat lama
            _buildFormInput('Label Alamat', widget.labelAwal, Icons.bookmark_outline, inputBg, maxLines: 1),
            _buildFormInput('Detail Alamat / Nama Jalan', widget.detailAwal, Icons.location_on_outlined, inputBg, maxLines: 3),
            _buildFormInput('Patokan (Opsional)', 'Samping gedung / Pagar warna cokelat', Icons.explore_outlined, inputBg, maxLines: 1),

            const SizedBox(height: 10),

            // Opsi Switch Alamat Utama
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

            // Tombol Simpan Perubahan Alamat
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
                    const SnackBar(content: Text('Perubahan alamat berhasil diperbarui! (Dummy)')),
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

  Widget _buildFormInput(String label, String initialValue, IconData icon, Color bgColor, {required int maxLines}) {
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
            maxLines: maxLines,
            style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
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