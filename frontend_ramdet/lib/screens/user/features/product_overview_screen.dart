import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/product_provider.dart';

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({super.key});

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  // 1. Tambahkan variabel state untuk merekam ketikan pencarian
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // 2. Logika memfilter produk dari database secara realtime berdasarkan ketikan
    final allProducts = productProvider.products;
    final displayedProducts = allProducts.where((product) {
      final productName = product.name.toLowerCase();
      return productName.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        // Kunci ke kode AppBar bawaan kelompokmu agar rute tidak bentrok
        title: const Text(
          'Dasbor Admin - Kelola Katalog',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF6B00),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => productProvider.fetchProducts(),
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
              ),
            )
          : Column(
              children: [
                // 3. SEKAT KOTAK PENCARIAN FISIK (Pasti bisa diklik & memunculkan kursor di Chrome)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Cari suku cadang atau produk...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6B00)),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase(); // Ambil input ketikan user
                      });
                    },
                  ),
                ),
                
                // 4. Sisa area diisi oleh daftar list produk hasil filter
                Expanded(
                  child: displayedProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_car_filled_outlined, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Belum ada produk otomotif di katalog.'
                                    : 'Produk tidak ditemukan.',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: displayedProducts.length, // REVISI: Pakai data terfilter
                          itemBuilder: (ctx, i) {
                            final product = displayedProducts[i]; // REVISI: Pakai data terfilter

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12.0),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: product.imageBytes != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10.0),
                                          child: Image.memory(product.imageBytes!, fit: BoxFit.cover),
                                        )
                                      : const Icon(Icons.directions_car, color: Color(0xFFFF6B00)),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (product.category != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          product.category!,
                                          style: const TextStyle(fontSize: 10, color: Colors.black87),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${product.price.toString()}',
                                      style: const TextStyle(
                                        color: Color(0xFFFF6B00),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (product.description != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        product.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.of(context).pushNamed('/edit-product', arguments: product);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteDialog(context, productProvider, product);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B00),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.of(context).pushNamed('/add-product'),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProductProvider provider, var product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus ${product.name}?'),
        actions: [
          TextButton(child: const Text('Batal'), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (product.id != null) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final String adminToken = authProvider.token ?? '';

                await provider.deleteProduct(adminToken, product.id!);
              }
            },
          ),
        ],
      ),
    );
  }
}