import 'dart:typed_data'; // WAJIB UNTUK FLUTTER WEB
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // IMPORT LIBRARY
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  
  // Variabel untuk menyimpan data gambar di memori Web
  Uint8List? _webImage; 

  // === TAMBAHAN STATE LOKAL UNTUK KATEGORI ===
  String _selectedCategory = 'Mobil'; // Nilai default standar

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Fungsi untuk membuka file picker laptop
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      var f = await image.readAsBytes();
      setState(() {
        _webImage = f; // Simpan gambar ke dalam state berbentuk bytes
      });
    }
  }

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final price = int.parse(_priceController.text);
    final desc = _descController.text;

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // Kirim data ke provider (gambar dan variabel kategori ikut dikirimkan di sini)
    final success = await productProvider.addProduct(
      name, 
      price, 
      desc, 
      _selectedCategory, // <--- Data kategori sukses dilemparkan ke provider
      imageBytes: _webImage,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan!')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan produk.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<ProductProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk Otomotif'),
        backgroundColor: const Color(0xFFFF6B00),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // === FORM PREVIEW & PICKER GAMBAR ===
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFF6B00), width: 1.5),
                          ),
                          child: _webImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(_webImage!, fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40, color: Color(0xFFFF6B00)),
                                    SizedBox(height: 8),
                                    Text('Pilih Gambar Produk', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Produk / Velg'),
                      validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    // === TAMBAHAN DROPDOWN KATEGORI ===
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
                          _selectedCategory = newValue!; // Mengubah state pilihan kategori
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
                      child: const Text('Simpan Produk', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}