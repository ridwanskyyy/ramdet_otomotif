import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart'; // REVISI: Wajib diimport agar AuthProvider dikenali

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Mobil'; // Nilai awal dropdown
  Uint8List? _pickedImageBytes; // Menyimpan data gambar yang dipilih

  // Fungsi Image Picker khusus Flutter Web
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Memantau perubahan state isLoading secara pasif/aktif di UI
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang premium yang serasi
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(), // Kembali ke Dashboard Admin
        ),
        title: Text(
          'Tambah Produk Baru',
          style: TextStyle(
            color: Colors.brown[800],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // 1. AREA UPLOAD GAMBAR CUSTOM (Elegan & Melengkung Sesuai Desain Baru)
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: _pickedImageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.memory(_pickedImageBytes!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B00),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Pilih Gambar Komponen',
                            style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Format JPG, PNG (Max 2MB)',
                            style: TextStyle(color: Colors.black38, fontSize: 11),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. INPUT NAMA PRODUK
            _buildInputLabel('Nama Komponen / Velg'),
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration('Masukkan nama suku cadang'),
              style: const TextStyle(fontSize: 13),
              validator: (val) => val!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            // 3. DROPDOWN KATEGORI CUSTOM (Capsule Style)
            _buildInputLabel('Kategori Kendaraan'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                  style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                  items: ['Mobil', 'Motor'].map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. INPUT HARGA
            _buildInputLabel('Harga Suku Cadang (Rp)'),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration('Contoh: 7500000'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              validator: (val) {
                if (val!.isEmpty) return 'Harga tidak boleh kosong';
                if (int.tryParse(val) == null) return 'Masukkan angka yang valid';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 5. INPUT DESKRIPSI (Multilines)
            _buildInputLabel('Deskripsi Spesifikasi Produk'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _buildInputDecoration('Jelaskan kondisi, ukuran ring, atau keaslian spesifikasi komponen...'),
              style: const TextStyle(fontSize: 13),
              validator: (val) => val!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
            ),
            const SizedBox(height: 32),

            // 6. TOMBOL SUBMIT KAPSUL ORANYE DENGAN INTEGRASI TOKEN BEARER SANCTUM
            productProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00), // Oranye ikonik pilihanmu
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // REVISI: Ambil string token dari AuthProvider kelompokmu sebelum eksekusi AP
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final String adminToken = authProvider.token ?? '';

                        // Jalankan fungsi tambah produk ke provider dengan menyisipkan adminToken
                        final isSuccess = await productProvider.addProduct(
                          adminToken, // KUNCI UTAMA: Token dilempar ke provider agar tidak ditolak api.php
                          _nameController.text,
                          int.parse(_priceController.text),
                          _descriptionController.text,
                          _selectedCategory,
                          imageBytes: _pickedImageBytes,
                        );

                        // Penanganan kondisi setelah await selesai
                        if (isSuccess && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Produk baru sukses ditambahkan ke katalog!')),
                          );
                          // Mengeluarkan user dari form screen dan kembali ke katalog utama
                          Navigator.of(context).pop(); 
                        } else if (!isSuccess && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gagal menyimpan produk. Periksa kembali token hak akses admin Anda.')),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Simpan Komponen Baru',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Helper membuat Label Input minimalis
  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  // Helper dekorasi kolom input kapsul abu-abu melengkung
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFEFEFEF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1),
      ),
    );
  }
}