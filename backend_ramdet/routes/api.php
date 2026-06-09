<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController; 
use App\Http\Controllers\Api\FavoriteController; 
use App\Http\Controllers\Api\UserController; 
use App\Http\Middleware\CheckAdmin; 
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// -------------------------------------------------------------
// RUTE PUBLIK (Bisa diakses siapa saja, TERMASUK setelah LOGOUT)
// -------------------------------------------------------------
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Pindahkan ke sini agar data seeder & produk bisa muncul di dashboard publik
Route::apiResource('products', ProductController::class)->only(['index', 'show']);

// -------------------------------------------------------------
// RUTE PROTEKSI (Wajib Login / Harus Bawa Token Sanctum)
// -------------------------------------------------------------
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
    Route::post('/user/update', [AuthController::class, 'updateProfile']); 
    Route::post('/user/change-password', [AuthController::class, 'changePassword']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // 2. Rute Favorit
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites/toggle', [FavoriteController::class, 'toggleFavorite']);

    // 3. Rute KHUSUS ADMIN (Tambah, Edit, Hapus Produk & User)
    Route::middleware(CheckAdmin::class)->group(function () {
        
        // Pengelolaan Produk oleh Admin
        Route::apiResource('products', ProductController::class)->except(['index', 'show']);
        
        // Rute Pengelolaan User
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::put('/users/{id}', [UserController::class, 'update']);
        
    });

});