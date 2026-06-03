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
        
        return $this->sendResponse($product, 'Produk berhasil ditambahkan.', 201);
    }

    public function show(Product $product)
    {
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