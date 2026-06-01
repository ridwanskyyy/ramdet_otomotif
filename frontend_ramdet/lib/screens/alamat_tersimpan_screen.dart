import 'package:flutter/material.dart';
import 'tambah_alamat_screen.dart'; // Import halaman tambah
import 'edit_alamat_screen.dart';   // Import halaman edit

class AlamatTersimpanScreen extends StatelessWidget {
  const AlamatTersimpanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color rustBrown = Color(0xFF9E4300);
    const Color bgLight = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        title: const Text('Ramdet Otomotif', style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saved Addresses', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Manage locations for quick service bookings and deliveries.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),

            // Tombol Add New Address (Navigasi Aktif)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: rustBrown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahAlamatScreen()));
                },
                icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 20),
                label: const Text('Add New Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),

            _buildCleanAddressCard(
              context,
              'Home',
              'DEFAULT',
              'Jl. Sudirman No. 45, Kebayoran Baru, Jakarta Selatan, 12110',
              Icons.home_outlined,
              const Color(0xFFFFEBE0),
            ),
            _buildCleanAddressCard(
              context,
              'Office',
              'Gedung Astra Tower',
              'Level 28, Astra Tower, Kav 5-6, Jakarta Pusat, 10220',
              Icons.card_travel_outlined,
              const Color(0xFFE8F0FE),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanAddressCard(BuildContext context, String title, String tag, String fullAddress, IconData icon, Color iconBg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: iconBg, radius: 20, child: Icon(icon, color: const Color(0xFF1A1A1A), size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(tag, style: const TextStyle(fontSize: 10, color: Color(0xFF9E4300), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              // Navigasi ke Halaman Edit Alamat dengan melempar data awal
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAlamatScreen(
                        labelAwal: title,
                        detailAwal: fullAddress,
                        tagAwal: tag,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              
              // Tombol Aksi Hapus Dummy
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Alamat "$title" berhasil dihapus (Dummy)'), backgroundColor: Colors.red),
                  );
                },
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Text(fullAddress, style: const TextStyle(color: Color(0xFF555555), fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}