<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController; 
use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return response()->json([
            'success' => true,
            'message' => 'Data profil pengguna berhasil diambil.',
            'data' => $request->user()
        ], 200);
    });
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::apiResource('products', ProductController::class)->missing(function (Request $request) {
        return response()->json([
            'success' => false,
            'message' => 'Gagal memproses! Data produk tidak tersedia atau sudah dihapus.'
        ], 404);
    });
});