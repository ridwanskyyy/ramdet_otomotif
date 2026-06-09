<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    // 1. Mengambil semua data user untuk halaman list di Flutter
    public function index()
    {
        $users = User::all();
        
        return response()->json([
            'success' => true,
            'message' => 'Daftar pengguna berhasil diambil.',
            'data' => $users
        ], 200);
    }

    // 2. Menambah user baru langsung dari dashboard admin
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8', // Perbaikan: Menggunakan tanda titik dua
            'role' => 'required|string' 
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengguna baru berhasil ditambahkan.',
            'data' => $user
        ], 201);
    }

    // 3. Mengubah data user berdasarkan ID
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Pengguna tidak ditemukan.'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255', // Perbaikan: Menggunakan tanda titik dua
            'email' => 'sometimes|required|string|email|max:255|unique:users,email,' . $id,
            'password' => 'sometimes|nullable|string|min:8', // Perbaikan: Menggunakan tanda titik dua
            'role' => 'sometimes|required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors' => $validator->errors()
            ], 422);
        }

        // Update jika ada inputan baru, jika tidak ada pakai data lama
        $user->name = $request->name ?? $user->name;
        $user->email = $request->email ?? $user->email;
        
        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }
        
        $user->role = $request->role ?? $user->role;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Data pengguna berhasil diperbarui.',
            'data' => $user
        ], 200);
    }
}