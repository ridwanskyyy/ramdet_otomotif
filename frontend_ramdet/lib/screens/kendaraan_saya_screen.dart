import 'package:flutter/material.dart';
import 'package:frontend_ramdet/screens/edit_kendaraan_screen.dart';
import 'tambah_kendaraan_screen.dart'; // Pastikan import file baru ini

class KendaraanSayaScreen extends StatelessWidget {
  const KendaraanSayaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color rustBrown = Color(0xFF9E4300);
    const Color orangePrimary = Color(0xFFFF6B00);
    const Color bgLight = Color(0xFFF9F9F9);
    const Color textDark = Color(0xFF1A1A1A);
    const Color solidGrey = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        title: const Text('Ramdet Otomotif', style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Garage', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 4),
            const Text('Manage your registered vehicles and track service status.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),

            // Card Kendaraan 1
            _buildFlatVehicleCard(
              context,
              'Toyota Avanza Veloz',
              'B 1234 ABC',
              '2022 • White Pearl',
              'Healthy',
              '15 Oct 2024',
              'NEXT CHECKUP',
              Colors.brown,
              Icons.directions_car,
              solidGrey,
            ),

            // Card Kendaraan 2
            _buildFlatVehicleCard(
              context,
              'Honda Civic RS',
              'D 9999 RS',
              '2023 • Dark Gray',
              'Service Overdue',
              '12 Feb 2024',
              'LAST SERVICE',
              Colors.red,
              Icons.directions_car_filled,
              solidGrey,
            ),

            // Tombol Add New Vehicle (Sudah Aktif Navigasinya)
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahKendaraanScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  children: const [
                    Icon(Icons.add, color: rustBrown, size: 28),
                    SizedBox(height: 12),
                    Text('Add New Vehicle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Register a new car to your garage.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Banner Performance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: rustBrown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL FLEET PERFORMANCE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('85% Optimal', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  MaterialButton(
                    color: Colors.white,
                    elevation: 0,
                    onPressed: () {},
                    child: const Text('Full Report', style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatVehicleCard(BuildContext context, String name, String plate, String specs, String status, String date, String dateLabel, Color statusColor, IconData icon, Color solidBg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                    Text(specs, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              
              // REVISI: Mengganti ikon static menjadi PopupMenuButton (Pilihan Ubah & Hapus)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'ubah') {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditKendaraanScreen(
        namaAwal: name,
        platAwal: plate,
        spekAwal: specs,
        tipeAwal: icon == Icons.directions_car || icon == Icons.directions_car_filled ? 'Mobil' : 'Motor',
      ),
    ),
  );
} else if (value == 'hapus') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name berhasil dihapus (Dummy)'), backgroundColor: Colors.red),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'ubah',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Ubah Kendaraan'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'hapus',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(6),
            color: solidBg,
            child: Text(plate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SERVICE STATUS', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                  Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(dateLabel, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                  Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1A1A))),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}