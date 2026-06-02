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
        
        // Pencarian berdasarkan nama produk sesuai struktur baru
        if ($request->has('search') && $request->search != '') {
            $query->where('name', 'like', '%' . $request->search . '%');
        }
        
        if ($request->has('category') && $request->category != '') {
            $query->where('category', $request->category);
        }
        
        $products = $query->get();
        return $this->sendResponse($products, 'Daftar data produk berhasil diambil.');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric',
            'category' => 'required|string',
            'image' => 'nullable|string',
        ]);

        $safeData = $request->only(['name', 'description', 'price', 'category', 'image']);
        $product = Product::create($safeData);
        
        return $this->sendResponse($product, 'Produk berhasil ditambahkan.', 201);
    }

    public function show(Product $product)
    {
        return $this->sendResponse($product, 'Detail produk berhasil ditampilkan.');
    }

    public function update(Request $request, Product $product)
    {
        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'sometimes|required|numeric',
            'category' => 'sometimes|required|string',
            'image' => 'nullable|string',
        ]);

        $safeData = $request->only(['name', 'description', 'price', 'category', 'image']);
        $product->update($safeData);
        
        return $this->sendResponse($product, 'Data produk berhasil diperbarui.');
    }

    public function destroy(Product $product)
    {
        $product->delete();
        return $this->sendResponse(null, 'Produk berhasil dihapus.');
    }
}