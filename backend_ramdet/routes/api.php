<?php
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController; 
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('products', ProductController::class);
});