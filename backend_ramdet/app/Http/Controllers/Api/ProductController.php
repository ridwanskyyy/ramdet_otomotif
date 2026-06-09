<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::query();
        
        // Pencarian berdasarkan nama produk
        if ($request->has('search') && $request->search != '') {
            $query->where('name', 'like', '%' . $request->search . '%');
        }
        
        // Mengubah pencarian kategori menjadi huruf kecil (case-insensitive)
        if ($request->has('category') && $request->category != '') {
            $query->where('category', strtolower($request->category));
        }
        
        $products = $query->get();

        // REVISI: Transformasi string mentah menjadi URL utuh untuk Flutter
        $products->transform(function ($product) {
            if ($product->image) {
                // Jika string di DB sudah diawali 'storage/', langsung bungkus asset()
                if (str_starts_with($product->image, 'storage/')) {
                    $product->image = asset($product->image);
                } else {
                    // Jika dari seeder (hanya 'products/...'), tambahkan prefix 'storage/'
                    $product->image = asset('storage/' . $product->image);
                }
            }
            return $product;
        });

        return $this->sendResponse($products, 'Daftar data produk berhasil diambil.');
    }

    public function store(Request $request)
    {
        // Normalisasi teks kategori dari Flutter ke huruf kecil sebelum divalidasi
        if ($request->has('category')) {
            $request->merge(['category' => strtolower($request->category)]);
        }

        // REVISI: Mengubah validasi image agar menerima kiriman file fisik gambar asli
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric',
            'category' => 'required|in:mobil,motor', 
            'image' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
        ]);

        $data = $request->only(['name', 'description', 'price', 'category']);

        // Logika simpan berkas gambar fisik ke storage server Ramdet
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $fileName = 'prod_' . time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('storage/products'), $fileName);
            $data['image'] = 'storage/products/' . $fileName;
        }

        $product = Product::create($data);
        
        // Response data baru juga dibungkus URL penuh
        if ($product->image) {
            $product->image = asset($product->image);
        }
        
        return $this->sendResponse($product, 'Produk berhasil ditambahkan.', 201);
    }

    public function show(Product $product)
    {
        // REVISI: Transformasi URL untuk detail produk tunggal
        if ($product->image) {
            if (str_starts_with($product->image, 'storage/')) {
                $product->image = asset($product->image);
            } else {
                $product->image = asset('storage/' . $product->image);
            }
        }

        return $this->sendResponse($product, 'Detail produk berhasil ditampilkan.');
    }

    public function update(Request $request, Product $product)
    {
        if ($request->has('category')) {
            $request->merge(['category' => strtolower($request->category)]);
        }

        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'sometimes|required|numeric',
            'category' => 'sometimes|required|in:mobil,motor',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
        ]);

        $data = $request->only(['name', 'description', 'price', 'category']);

        if ($request->hasFile('image')) {
            // Hapus gambar lama jika ada sebelum menimpa dengan yang baru
            if ($product->image && file_exists(public_path($product->image))) {
                @unlink(public_path($product->image));
            }

            $file = $request->file('image');
            $fileName = 'prod_' . time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('storage/products'), $fileName);
            $data['image'] = 'storage/products/' . $fileName;
        }

        $product->update($data);
        
        if ($product->image) {
            $product->image = asset($product->image);
        }
        
        return $this->sendResponse($product, 'Data produk berhasil diperbarui.');
    }

    public function destroy(Product $product)
    {
        if ($product->image && file_exists(public_path($product->image))) {
            @unlink(public_path($product->image));
        }
        
        $product->delete();
        return $this->sendResponse(null, 'Produk berhasil dihapus.');
    }
}