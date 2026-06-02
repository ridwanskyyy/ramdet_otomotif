import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // Pastikan jalur import provider benar

class EditProfilScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditProfilScreen({super.key, this.userData});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  // Deklarasi controller untuk menangkap inputan form
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  bool _isLoading = false; // State indikator loading saat kirim data

  @override
  void initState() {
    super.initState();
    
    // Ekstrak data awal dari database untuk dimasukkan langsung ke form input
    final String nameInitial = widget.userData?['data']?['name'] ?? widget.userData?['name'] ?? '';
    final String emailInitial = widget.userData?['data']?['email'] ?? widget.userData?['email'] ?? '';
    final String phoneInitial = widget.userData?['data']?['phone_number'] ?? widget.userData?['phone_number'] ?? '';
    final String addressInitial = widget.userData?['data']?['address'] ?? widget.userData?['address'] ?? '';

    // Inisialisasi controller dengan data awal dari DB
    _nameController = TextEditingController(text: nameInitial);
    _emailController = TextEditingController(text: emailInitial);
    _phoneController = TextEditingController(text: phoneInitial);
    _addressController = TextEditingController(text: addressInitial);
  }

  @override
  void dispose() {
    // Bersihkan controller dari memori saat halaman ditutup
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Panggil fungsi update dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isSuccess = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Kembali ke halaman profil utama dan memicu pembaruan data
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui profil. Coba lagi nanti.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color orangePrimary = Color(0xFFFF6B00);
    const Color rustBrown = Color(0xFF9E4300);
    const Color bgLight = Color(0xFFF9F9F9);
    const Color inputBg = Color(0xFFF2F2F2);

    final String userIdFromDb = widget.userData?['data']?['id']?.toString() ?? widget.userData?['id']?.toString() ?? '00000';

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
          'Ramdet Otomotif',
          style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: orangePrimary, width: 3),
                        image: const DecorationImage(
                          image: NetworkImage('https://via.placeholder.com/150'), 
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: orangePrimary, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Edit Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: rustBrown),
              ),
              const SizedBox(height: 4),
              Text(
                'ID: RAM-$userIdFromDb-DT', 
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Memanggil fungsi input field dengan menyematkan controllernya masing-masing
              _buildInputField('Nama Lengkap', _nameController, Icons.person_outline, inputBg, "Nama tidak boleh kosong"),
              _buildInputField('Alamat Email', _emailController, Icons.email_outlined, inputBg, "Email tidak boleh kosong"),
              _buildInputField('Nomor Telepon', _phoneController, Icons.phone_outlined, inputBg, null, hintText: 'Masukkan nomor HP aktif'),
              _buildInputField('Alamat Utama', _addressController, Icons.location_on_outlined, inputBg, null, hintText: 'Masukkan alamat pengiriman'),
              
              const SizedBox(height: 24),

              // Tombol Simpan Interaktif (Otomatis berubah jadi spinner loading kalau sedang proses kirim)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: orangePrimary))
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangePrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        onPressed: _submitData,
                        icon: const Icon(Icons.save_rounded, color: Colors.white),
                        label: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Pembaruan profil akan langsung disimpan ke server database Ramdet Otomotif.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, Color bgColor, String? validationMsg, {String? hintText}) {
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
            controller: controller,
            validator: (value) {
              if (validationMsg != null && (value == null || value.trim().isEmpty)) {
                return validationMsg;
              }
              return null;
            },
            style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 14),
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