import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_ramdet/screens/change_password_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EditProfilScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditProfilScreen({super.key, this.userData});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  String _selectedMemberStatus = 'bronze'; 
  XFile? _selectedImage; 
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<String> _memberTiers = ['bronze', 'silver', 'gold', 'platinum'];

  @override
  void initState() {
    super.initState();
    
    final String nameInitial = widget.userData?['data']?['name'] ?? widget.userData?['name'] ?? '';
    final String emailInitial = widget.userData?['data']?['email'] ?? widget.userData?['email'] ?? '';
    final String phoneInitial = widget.userData?['data']?['phone_number'] ?? widget.userData?['phone_number'] ?? '';
    final String addressInitial = widget.userData?['data']?['address'] ?? widget.userData?['address'] ?? '';
    final String memberInitial = widget.userData?['data']?['membership_status'] ?? widget.userData?['membership_status'] ?? 'bronze';

    _nameController = TextEditingController(text: nameInitial);
    _emailController = TextEditingController(text: emailInitial);
    _phoneController = TextEditingController(text: phoneInitial);
    _addressController = TextEditingController(text: addressInitial);
    
    if (_memberTiers.contains(memberInitial.toLowerCase())) {
      _selectedMemberStatus = memberInitial.toLowerCase();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final isSuccess = await authProvider.updateProfileMultipart(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      membershipStatus: _selectedMemberStatus, 
      imageFile: _selectedImage,
    );

    setState(() { _isLoading = false; });

    if (isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui data server.'), backgroundColor: Colors.redAccent),
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

    final String? photoPath = widget.userData?['data']?['profile_photo_path'] ?? widget.userData?['profile_photo_path'];
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        title: const Text('Ramdet Otomotif', style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage, 
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: orangePrimary, width: 3),
                          image: _selectedImage != null
                              ? DecorationImage(image: FileImage(File(_selectedImage!.path)), fit: BoxFit.cover)
                              : DecorationImage(
                                  // REVISI: Menggunakan fungsi getFullImageUrl untuk menarik gambar lama dari server Laragon
                                  image: NetworkImage(authProvider.getFullImageUrl(photoPath)), 
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: orangePrimary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Edit Data Pengguna', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: rustBrown)),
              const SizedBox(height: 24),

              _buildInputField('Nama Lengkap', _nameController, Icons.person_outline, inputBg, "Nama tidak boleh kosong"),
              _buildInputField('Alamat Email', _emailController, Icons.email_outlined, inputBg, "Email tidak boleh kosong"),
              _buildInputField('Nomor Telepon', _phoneController, Icons.phone_outlined, inputBg, null),
              _buildInputField('Alamat Utama', _addressController, Icons.location_on_outlined, inputBg, null),
              
              Align(
  alignment: Alignment.centerRight,
  child: TextButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
      );
    },
    icon: const Icon(Icons.lock_reset_rounded, color: rustBrown, size: 20),
    label: const Text(
      'Ubah Password Akun',
      style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold, fontSize: 13),
    ),
  ),
),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status Membership', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedMemberStatus,
                    items: _memberTiers.map((tier) {
                      return DropdownMenuItem(
                        value: tier,
                        child: Text(tier.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() { _selectedMemberStatus = value!; });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.workspace_premium_outlined, color: Colors.grey),
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: orangePrimary))
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: orangePrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        onPressed: _submitData,
                        icon: const Icon(Icons.save_rounded, color: Colors.white),
                        label: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, Color bgColor, String? validationMsg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: (value) {
              if (validationMsg != null && (value == null || value.trim().isEmpty)) return validationMsg;
              return null;
            },
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