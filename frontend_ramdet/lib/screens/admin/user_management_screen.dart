import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_ramdet/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> _users = [];
  bool _isLoading = false;
  
  // IP Address Valid Laptop
  final String _usersUrl = 'http://192.168.100.62:8001/api/users';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUsersFromDatabase();
    });
  }

  // 1. READ: Ambil seluruh data user dari Database Laravel
  Future<void> _fetchUsersFromDatabase() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token ?? '';
      
      final response = await http.get(
        Uri.parse(_usersUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> extractedData = responseData['data'] ?? [];
        
        if (mounted) {
          setState(() {
            _users = extractedData;
          });
        }
      } else {
        _showSnackBar('Gagal memuat data dari server.', Colors.red);
      }
    } catch (e) {
      debugPrint("DEBUG API: Eror/Timeout: $e");
      _showSnackBar('Koneksi terputus. Pastikan API backend berjalan.', Colors.red);
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // 2. CREATE & UPDATE: Fungsi kirim data tambah/edit ke Laravel
  Future<void> _submitUserToDatabase({
    Map<String, dynamic>? existingUser,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String membership,
    required String role, 
  }) async {
    if (!mounted) return;
    setState(() { _isLoading = true; });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token ?? '';
    
    try {
      final isEdit = existingUser != null;
      final url = isEdit ? '$_usersUrl/${existingUser['id']}' : _usersUrl;
      
      // Siapkan wadah datanya
      final Map<String, dynamic> bodyData = {
        'name': name,
        'email': email,
        'phone_number': phone,
        'address': address,
        'membership_status': membership,
        'role': role,
      };

      // Hanya kirim password ke server jika admin mengetikkan password baru
      if (password.isNotEmpty) {
        bodyData['password'] = password;
      }
      
      http.Response response;

      // REVISI: Pisahkan metode POST (Tambah) dan PUT (Edit) secara murni
      if (isEdit) {
        response = await http.put(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(bodyData),
        ).timeout(const Duration(seconds: 8));
      } else {
        response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(bodyData),
        ).timeout(const Duration(seconds: 8));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchUsersFromDatabase(); 
        _showSnackBar(isEdit ? 'Profil & Hak Akses sukses diperbarui!' : 'User baru berhasil tersimpan!', Colors.green);
      } else {
        debugPrint("DEBUG API Error Body: ${response.body}");
        _showSnackBar('Gagal menyimpan. Email mungkin duplikat / ditolak sistem.', Colors.redAccent);
      }
    } catch (e) {
      debugPrint("DEBUG API: Eror POST/PUT: $e");
      _showSnackBar('Koneksi terputus. Gagal menyimpan data.', Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // 3. DELETE: Fungsi untuk menghapus user dari database
  Future<void> _deleteUser(dynamic id) async {
    // Tampilkan Dialog Konfirmasi terlebih dahulu
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menghapus akun ini? Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    // Jika user menekan "Batal" atau menutup dialog, hentikan fungsi
    if (confirm != true) return;

    if (!mounted) return;
    setState(() { _isLoading = true; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token ?? '';

    try {
      final response = await http.delete(
        Uri.parse('$_usersUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _fetchUsersFromDatabase();
        _showSnackBar('Akun pengguna berhasil dihapus.', Colors.green);
      } else {
        debugPrint("DEBUG API Error Body: ${response.body}");
        _showSnackBar('Gagal menghapus pengguna. Cek koneksi server.', Colors.redAccent);
      }
    } catch (e) {
      debugPrint("DEBUG API: Eror DELETE: $e");
      _showSnackBar('Koneksi terputus. Gagal menghapus data.', Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }
  
  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 4)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Manajemen Pengguna', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF6B00),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF6B00),
        onPressed: () => _showUserFormDialog(),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text('Tambah User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : _users.isEmpty
              ? const Center(child: Text('Tidak ada data pengguna.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    String tier = (user['membership_status'] ?? 'bronze').toString().toUpperCase();
                    String role = (user['role'] ?? 'user').toString().toUpperCase();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 1.5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          backgroundColor: role == 'ADMIN' ? const Color(0xFFFF6B00).withOpacity(0.2) : const Color(0xFFEFEFEF),
                          child: Icon(
                            role == 'ADMIN' ? Icons.admin_panel_settings : Icons.person, 
                            color: const Color(0xFFFF6B00)
                          ),
                        ),
                        title: Text(user['name']?.toString() ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Email: ${user['email']}'),
                            Text('Telp: ${user['phone_number'] ?? '-'}'),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8, 
                              runSpacing: 4, 
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B00).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'MEMBER: $tier',
                                    style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: role == 'ADMIN' ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    role,
                                    style: TextStyle(
                                      color: role == 'ADMIN' ? Colors.red : Colors.blue, 
                                      fontSize: 10, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 24),
                              onPressed: () => _showUserFormDialog(user: user),
                              tooltip: 'Edit User',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24),
                              onPressed: () => _deleteUser(user['id']),
                              tooltip: 'Hapus User',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // 3. DIALOG UI: Tampilan Rapi & Responsif
  void _showUserFormDialog({Map<String, dynamic>? user}) {
    final isEdit = user != null;
    final nameCtrl = TextEditingController(text: isEdit ? user['name']?.toString() : '');
    final emailCtrl = TextEditingController(text: isEdit ? user['email']?.toString() : '');
    final phoneCtrl = TextEditingController(text: isEdit ? user['phone_number']?.toString() : '');
    final addrCtrl = TextEditingController(text: isEdit ? user['address']?.toString() : '');
    final passCtrl = TextEditingController(); 
    
    String selectedTier = isEdit ? (user['membership_status'] ?? 'bronze').toString().toLowerCase() : 'bronze';
    String selectedRole = isEdit ? (user['role'] ?? 'user').toString().toLowerCase() : 'user';

    if (!['bronze', 'silver', 'gold', 'platinum'].contains(selectedTier)) selectedTier = 'bronze';
    if (!['user', 'admin'].contains(selectedRole)) selectedRole = 'user';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: Column(
            children: [
              Icon(
                isEdit ? Icons.manage_accounts_rounded : Icons.person_add_alt_1_rounded, 
                size: 40, 
                color: const Color(0xFFFF6B00)
              ),
              const SizedBox(height: 12),
              Text(
                isEdit ? 'Ubah Profil User' : 'Tambah User Baru', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A1A)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  _buildDialogTextField(nameCtrl, 'Nama Lengkap', Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildDialogTextField(emailCtrl, 'Alamat Email', Icons.email_outlined),
                  const SizedBox(height: 12),
                  if (!isEdit) ...[
                    _buildDialogTextField(passCtrl, 'Password Akun', Icons.lock_outline, isPassword: true),
                    const SizedBox(height: 12),
                  ],
                  _buildDialogTextField(phoneCtrl, 'Nomor Telepon', Icons.phone_outlined, isNumber: true),
                  const SizedBox(height: 12),
                  _buildDialogTextField(addrCtrl, 'Alamat Rumah', Icons.home_outlined),
                  const SizedBox(height: 12),
                  
                  // Dropdown Role
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Hak Akses (Role)',
                      labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      prefixIcon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.grey, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.5)),
                    ),
                    items: ['user', 'admin'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() { selectedRole = val!; });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Dropdown Membership
                  DropdownButtonFormField<String>(
                    value: selectedTier,
                    decoration: InputDecoration(
                      labelText: 'Level Membership',
                      labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      prefixIcon: const Icon(Icons.workspace_premium_outlined, color: Colors.grey, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.5)),
                    ),
                    items: ['bronze', 'silver', 'gold', 'platinum'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() { selectedTier = val!; });
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 24, right: 24, left: 24, top: 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
                      Navigator.pop(ctx);
                      _submitUserToDatabase(
                        existingUser: user,
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        password: passCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        address: addrCtrl.text.trim(),
                        membership: selectedTier,
                        role: selectedRole,
                      );
                    },
                    child: Text(isEdit ? 'Simpan Data' : 'Tambah User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. WIDGET BANTUAN UI TEXTFIELD
  Widget _buildDialogTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8F9FA), 
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.5)),
      ),
    );
  }
}