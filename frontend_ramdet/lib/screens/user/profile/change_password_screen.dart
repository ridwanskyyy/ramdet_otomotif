import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _submitPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    setState(() { _isLoading = false; });

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Kembali ke halaman edit profil
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.redAccent),
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

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: rustBrown),
        title: const Text('Keamanan Akun', style: TextStyle(color: rustBrown, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ubah Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 6),
              const Text('Demi menjaga keamanan data transaksi bengkel Anda, gunakan kombinasi password yang kuat.', style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4)),
              const SizedBox(height: 32),

              // 1. INPUT PASSWORD LAMA
              _buildPasswordField(
                label: 'Password Saat Ini',
                controller: _oldPasswordController,
                bgColor: inputBg,
                obscureText: _obscureOld,
                validationMsg: 'Password saat ini wajib diisi',
                onToggleVisibility: () {
                  setState(() { _obscureOld = !_obscureOld; });
                },
              ),

              // 2. INPUT PASSWORD BARU
              _buildPasswordField(
                label: 'Password Baru',
                controller: _newPasswordController,
                bgColor: inputBg,
                obscureText: _obscureNew,
                validationMsg: 'Password baru minimal berisi 8 karakter',
                isNewPassword: true,
                onToggleVisibility: () {
                  setState(() { _obscureNew = !_obscureNew; });
                },
              ),

              const SizedBox(height: 24),

              // TOMBOL SUBMIT PREMIUM
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
                        onPressed: _submitPassword,
                        icon: const Icon(Icons.verified_user_rounded, color: Colors.white),
                        label: const Text('Perbarui Password', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required Color bgColor,
    required bool obscureText,
    required String validationMsg,
    required VoidCallback onToggleVisibility,
    bool isNewPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return validationMsg;
              if (isNewPassword && value.length < 8) return 'Password baru minimal harus terdiri dari 8 karakter.';
              return null;
            },
            style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                onPressed: onToggleVisibility,
              ),
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