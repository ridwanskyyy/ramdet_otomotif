import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

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
    // REVISI: Mengambil path foto fisik dan kasta member asli hasil olahan database MySQL Laragon
    final String? photoPath = userData?['data']?['profile_photo_path'] ?? userData?['profile_photo_path'];
    final String memberStatus = userData?['data']?['membership_status'] ?? userData?['membership_status'] ?? 'bronze';
    final authProvider = context.read<AuthProvider>();

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
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
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
                              // REVISI: Menampilkan foto fisik asli dari server via fungsi getFullImageUrl
                              image: DecorationImage(
                                image: NetworkImage(authProvider.getFullImageUrl(photoPath)),
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
                          children: [
                            const Icon(Icons.stars, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            // REVISI: Status bertingkat dinamis
                            Text(
                              '${memberStatus.toUpperCase()} MEMBER', 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildListTile(
                  Icons.person_outline, 
                  'Edit Profil', 
                  false, 
                  () => Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => EditProfilScreen(userData: userData),
                    ),
                  ).then((_) {
                    // REVISI MUTLAK: Saat halaman edit ditutup, paksa halaman profil refresh total mengambil data baru
                    setState(() {
                      isFetching = true;
                    });
                    _loadProfile();
                  }),
                ),
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
                        children: [
                          const Text('Dapatkan Diskon Servis 20%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          // REVISI: Judul banner diskon mengikuti status baru member secara real-time
                          Text('BERLAKU UNTUK ${memberStatus.toUpperCase()} MEMBER', style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
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
        clipBehavior: Clip.antiAlias,
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