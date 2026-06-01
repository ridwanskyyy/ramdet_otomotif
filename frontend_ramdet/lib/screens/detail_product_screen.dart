import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data produk yang dilempar dari daftar katalog user
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF6B00),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === TAMPILAN GAMBAR PRODUK BESAR ===
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child: product.imageBytes != null
                  ? Image.memory(product.imageBytes!, fit: BoxFit.cover)
                  : product.image != null && product.image!.isNotEmpty
                      ? Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                        )
                      : const Icon(Icons.directions_car, size: 100, color: Color(0xFFFF6B00)),
            ),
            
            // === INFORMASI DETAIL ===
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk & Kategori Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (product.category != null)
                        Chip(
                          label: Text(
                            product.category!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: const Color(0xFFFF6B00),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Harga Produk
                  Text(
                    'Rp ${product.price.toString()}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B00),
                    ),
                  ),
                  const Divider(height: 30, thickness: 1.5),
                  
                  // Judul Deskripsi
                  const Text(
                    'Spesifikasi & Deskripsi Produk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  // Isi Deskripsi Lengkap
                  Text(
                    product.description ?? 'Tidak ada deskripsi untuk produk ini.',
                    style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}