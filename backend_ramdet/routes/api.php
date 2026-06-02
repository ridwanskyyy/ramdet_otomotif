<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController; 
use App\Http\Controllers\Api\FavoriteController; 
use App\Http\Middleware\CheckAdmin; 
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    
    // 1. Rute Profil & Otentikasi
    Route::get('/user', function (Request $request) {
        return response()->json([
            'success' => true,
            'message' => 'Data profil pengguna berhasil diambil.',
            'data' => $request->user()
        ], 200);
    });
    Route::put('/user', [AuthController::class, 'updateProfile']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // 2. Rute Favorit (Bisa diakses semua user yang login)
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites/toggle', [FavoriteController::class, 'toggleFavorite']);

    // 3. Rute Produk untuk SEMUA USER (User & Admin) - Hanya Melihat List & Detail
    Route::apiResource('products', ProductController::class)->only(['index', 'show'])->missing(function (Request $request) {
        return response()->json([
            'success' => false,
            'message' => 'Gagal memproses! Data produk tidak tersedia atau sudah dihapus.'
        ], 404);
    });

    // 4. Rute Produk KHUSUS ADMIN - Tambah (Store), Ubah (Update), Hapus (Destroy)
    // REVISI: Mengganti fungsi closure inline dengan class CheckAdmin yang sah
    Route::middleware(CheckAdmin::class)->group(function () {
        
        Route::apiResource('products', ProductController::class)->except(['index', 'show'])->missing(function (Request $request) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memproses! Data produk tidak tersedia atau sudah dihapus.'
            ], 404);
        });
        
    });

});