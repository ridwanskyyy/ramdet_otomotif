import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_ramdet/providers/auth_provider.dart'; // REVISI: Import AuthProvider untuk ambil URL penuh server
import '../../../providers/product_provider.dart';
import '../../../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Mengambil argumen data produk yang dikirim dari rute navigasi katalog
    final routeProduct = ModalRoute.of(context)!.settings.arguments as Product;
    
    // 2. Ambil data asli dari Provider agar status isFavorite-nya sinkron secara real-time
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false); // AMBIL AUTH PROVIDER
    
    final product = productProvider.products.firstWhere(
      (prod) => prod.id == routeProduct.id,
      orElse: () => routeProduct,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Produk',
          style: TextStyle(
            color: Colors.brown[800],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          // Konten Utama Scrollable
          Expanded(
            child: ListView(
              children: [
                // REVISI: AREA DISPLAY GAMBAR PRODUK ANTI-FREEZE & DUKUNG NETWORK IMAGE
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F3F5),
                  ),
                  child: product.imageBytes != null
                      ? Image.memory(product.imageBytes!, fit: BoxFit.cover)
                      : (product.image != null && product.image!.isNotEmpty)
                          ? Image.network(
                              authProvider.getFullImageUrl(product.image),
                              fit: BoxFit.cover,
                              // LOADING BUILDER: Indikator saat gambar sedang ditarik dari laptop
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
                                );
                              },
                              // ERROR BUILDER: Sabuk pengaman mutlak dari crash engine grafis LDPlayer
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  product.category?.toLowerCase() == 'motor' 
                                      ? Icons.motorcycle_rounded 
                                      : Icons.directions_car_filled_outlined, 
                                  size: 80, 
                                  color: Colors.black.withOpacity(0.24),
                                );
                              },
                            )
                          : Icon(
                              product.category?.toLowerCase() == 'motor' 
                                  ? Icons.motorcycle_rounded 
                                  : Icons.directions_car_filled_outlined, 
                              size: 80, 
                              color: Colors.black.withOpacity(0.24),
                            ),
                ),

                // BLOK INFORMASI UTAMA PRODUK
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B00),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (product.category ?? 'Umum').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8A4F3E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[200], thickness: 1),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, color: Colors.green[600], size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Kondisi: Orisinil / Baru (Tersedia)',
                            style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // BLOK SPESIFIKASI & DESKRIPSI PRODUK
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spesifikasi & Deskripsi Produk',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description ?? 'Tidak ada deskripsi untuk produk ini.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // =========================================================================
          // BOTTOM ACTION BAR - FULL TOMBOL FAVORIT (CHAT DIHAPUS)
          // =========================================================================
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity, 
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: product.isFavorite ? const Color(0xFF2C3033) : const Color(0xFFFF6B00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    productProvider.toggleFavorite(product.id!);
                  });
                  
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        product.isFavorite 
                            ? 'Produk berhasil ditambahkan ke favorit!' 
                            : 'Produk dihapus dari favorit.',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  product.isFavorite ? 'Hapus dari Favorit Saya' : 'Masukkan ke Favorit Saya',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}