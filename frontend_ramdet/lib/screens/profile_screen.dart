import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await context.read<AuthProvider>().getProfile();
    if (mounted) {
      setState(() {
        if (data != null) userData = data;
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.directions_car, color: Color(0xFF9E4300)),
            SizedBox(width: 8),
            Text('PROFIL SAYA', style: TextStyle(color: Color(0xFF9E4300), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
      body: isFetching 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Card Profil Atas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFF6B00), width: 3),
                          image: const DecorationImage(
                            image: NetworkImage('https://via.placeholder.com/150'), // Avatar placeholder
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFF9E4300), shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData?['name'] ?? 'Budi Santoso', // Fallback teks statis
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData?['email'] ?? 'budi.santoso@email.com',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.stars, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Gold Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // List Menu Navigasi
            _buildListTile(Icons.person_outline, 'Edit Profil', false, () {}),
            _buildListTile(Icons.directions_car_outlined, 'Kendaraan Saya', false, () {}),
            _buildListTile(Icons.location_on_outlined, 'Alamat Tersimpan', false, () {}),
            _buildListTile(Icons.notifications_none, 'Pengaturan Notifikasi', false, () {}),
            
            // Tombol Logout Terintegrasi
            _buildListTile(Icons.logout, 'Keluar', true, () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            }),

            const SizedBox(height: 24),
            // Banner Diskon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF9E4300),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Dapatkan Diskon Servis 20%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('BERLAKU UNTUK GOLD MEMBER', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
                    ],
                  ),
                  const Icon(Icons.local_offer, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget bantuan (Reusable) untuk list menu
  Widget _buildListTile(IconData icon, String title, bool isLogout, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red.withOpacity(0.1) : const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF1A1A1A)),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: isLogout ? Colors.red : const Color(0xFF1A1A1A)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}