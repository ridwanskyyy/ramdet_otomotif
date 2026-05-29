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
        if ($request->has('search') && $request->search != '') {
            $query->where('title', 'like', '%' . $request->search . '%');
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
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric',
            'category' => 'required|string',
            'image_url' => 'nullable|string',
        ]);

        $data = $request->all();
        $data['user_id'] = auth()->id(); 
        $product = Product::create($data);
        return $this->sendResponse($product, 'Produk berhasil ditambahkan.', 201);
    }

    public function show(Product $product)
    {
        return $this->sendResponse($product, 'Detail produk berhasil ditampilkan.');
    }

    public function update(Request $request, Product $product)
    {
        if ($product->user_id !== auth()->id()) {
            return $this->sendError('Akses ditolak! Anda hanya dapat mengubah produk Anda sendiri.', 403);
        }
        $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'price' => 'sometimes|required|numeric',
            'category' => 'sometimes|required|string',
        ]);
        $product->update($request->all());
        return $this->sendResponse($product, 'Data produk berhasil diperbarui.');
    }

    public function destroy(Product $product)
    {
        if ($product->user_id !== auth()->id()) {
            return $this->sendError('Akses ditolak! Anda hanya dapat menghapus produk Anda sendiri.', 403);
        }

        $product->delete();
        return $this->sendResponse(null, 'Produk berhasil dihapus.');
    }
}