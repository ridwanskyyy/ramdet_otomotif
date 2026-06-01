import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'kendaraan_saya_screen.dart';
import 'alamat_tersimpan_screen.dart';

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
      if (data == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      setState(() {
        userData = data;
        isFetching = false;
      });
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); 
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Anda telah berhasil keluar.')),
                  );
                }
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
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
                            image: NetworkImage('https://via.placeholder.com/150'),
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
                    userData?['data']?['name'] ?? 'Nama Tidak Ditemukan',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData?['data']?['email'] ?? 'Email Tidak Ditemukan',
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
            
            // 2. REVISI: Mengganti ProfileMenuTile mentah dengan fungsi _buildListTile bawaan kodemu agar seragam dan tidak error
            _buildListTile(
              Icons.person_outline, 
              'Edit Profil', 
              false, 
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilScreen())),
            ),
            // _buildListTile(
            //   Icons.directions_car_filled_outlined, 
            //   'Kendaraan Saya', 
            //   false, 
            //   () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KendaraanSayaScreen())),
            // ),
            // _buildListTile(
            //   Icons.location_on_outlined, 
            //   'Alamat Tersimpan', 
            //   false, 
            //   () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AlamatTersimpanScreen())),
            // ),
            _buildListTile(
              Icons.logout, 
              'Keluar', 
              true, 
              _showLogoutConfirmationDialog,
            ),

            const SizedBox(height: 24),
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

  Widget _buildListTile(IconData icon, String title, bool isLogout, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias, // Menjaga efek ketukan tetap rapi di dalam lengkungan
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
      ),
    );
  }
}