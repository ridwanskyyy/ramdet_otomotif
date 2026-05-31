<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FavoriteController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $favoriteProducts = DB::table('favorites')
            ->join('products', 'favorites.product_id', '=', 'products.id') 
            ->where('favorites.user_id', $user->id)
            ->select('products.*')
            ->get();
        return $this->sendResponse($favoriteProducts, 'Daftar produk favorit berhasil diambil.');
    }

    public function toggleFavorite(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
        ]);

        $userId = auth()->id();
        $productId = $request->product_id;

        // Cek apakah produk sudah difavoritkan sebelumnya
        $favorite = DB::table('favorites')
            ->where('user_id', $userId)
            ->where('product_id', $productId)
            ->first();

        if ($favorite) {
            // Jika sudah ada, hapus dari favorit
            DB::table('favorites')
                ->where('user_id', $userId)
                ->where('product_id', $productId)
                ->delete();

            return $this->sendResponse(null, 'Produk berhasil dihapus dari daftar favorit.');
        } else {
            // Jika belum ada, tambahkan ke favorit
            DB::table('favorites')->insert([
                'user_id' => $userId,
                'product_id' => $productId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            return $this->sendResponse(null, 'Produk berhasil ditambahkan ke daftar favorit.', 201);
        }
    }
}