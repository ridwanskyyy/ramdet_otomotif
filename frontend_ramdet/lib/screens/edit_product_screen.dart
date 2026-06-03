import 'dart:typed_data'; // WAJIB UNTUK FLUTTER WEB
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // IMPORT UNTUK IMAGE PICKER
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // IMPORT UNTUK MENGAKSES TOKEN
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  bool _isInit = true;
  late Product _product;

  String _selectedCategory = 'Mobil'; 
  Uint8List? _newWebImage; // Penampung data gambar baru

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments;
      
      if (args == null) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed('/admin-dashboard');
        });
        return;
      }

      _product = args as Product;
      _nameController = TextEditingController(text: _product.name);
      _priceController = TextEditingController(text: _product.price.toString());
      _descController = TextEditingController(text: _product.description ?? '');
      _selectedCategory = _product.category ?? 'Mobil'; 
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Fungsi interaktif pembuka file explorer laptop
  Future<void> _pickImage() async {
    print("Membuka File Picker Laptop..."); // Indikator debug di terminal VS Code
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        var bytes = await image.readAsBytes();
        setState(() {
          _newWebImage = bytes; // Sukses menimpa memori gambar di frontend
        });
        print("Gambar baru sukses dimuat ke memori!"); 
      } else {
        print("User membatalkan pemilihan gambar.");
      }
    } catch (e) {
      print("Error saat memilih gambar: $e");
    }
  }

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String adminToken = authProvider.token ?? '';
    // PASTIKAN line "imageBytes" di bawah ini membaca variabel _newWebImage!
    final success = await productProvider.updateProduct(
      adminToken,
      _product.id!,
      _nameController.text,
      int.parse(_priceController.text),
      _descController.text,
      _selectedCategory,
      imageBytes: _newWebImage, // <--- KRUSIAL: Harus mengoper gambar baru!
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diperbarui!')),
      );
      Navigator.of(context).pop(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui produk.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<ProductProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk Otomotif', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF6B00),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00))))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // === REVISI STRUKTUR AREA PREVIEW GAMBAR ===
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            height: 160,
                            width: 260,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFF6B00), width: 2),
                            ),
                            child: _newWebImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(_newWebImage!, fit: BoxFit.cover),
                                  )
                                : _product.imageBytes != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(_product.imageBytes!, fit: BoxFit.cover),
                                      )
                                    : const Icon(Icons.directions_car, size: 50, color: Color(0xFFFF6B00)),
                          ),
                          // Tombol pemicu absolut berbentuk lingkaran oranye di pojok kanan bawah gambar
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton.small(
                              heroTag: "btn_pick_edit",
                              backgroundColor: const Color(0xFFFF6B00),
                              onPressed: _pickImage, // Mengunci pemicu langsung ke fungsi picker
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Produk / Velg'),
                      validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori Kendaraan'),
                      items: ['Mobil', 'Motor'].map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Harga tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Deskripsi Produk'),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _submitData,
                      child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}