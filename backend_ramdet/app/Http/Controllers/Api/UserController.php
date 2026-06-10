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

public function destroy($id) {
    $user = User::find($id);
    if (!$user) {
        return response()->json(['message' => 'User tidak ditemukan'], 404);
    }
    
    // Opsional: Cegah admin menghapus dirinya sendiri
    if (auth()->user()->id == $id) {
        return response()->json(['message' => 'Tidak dapat menghapus akun Anda sendiri'], 403);
    }

    $user->delete();
    return response()->json(['message' => 'User berhasil dihapus'], 200);
}

    // 2. Menambah user baru langsung dari dashboard admin
   public function store(Request $request) {
    // 1. Validasi
    $request->validate([
        'name' => 'required|string',
        'email' => 'required|email|unique:users',
        'password' => 'required|min:6',
        'role' => 'required|string',
        'membership_status' => 'required|string',
    ]);

    // 2. Simpan ke Database
    $user = User::create([
        'name' => $request->name,
        'email' => $request->email,
        'password' => Hash::make($request->password),
        'phone_number' => $request->phone_number,           // <-- TANGKAP INI
        'address' => $request->address,                     // <-- TANGKAP INI
        'role' => $request->role,
        'membership_status' => $request->membership_status, // <-- TANGKAP INI
    ]);

    return response()->json(['message' => 'User berhasil dibuat', 'data' => $user], 201);
}

    // 3. Mengubah data user berdasarkan ID
    public function update(Request $request, $id) {
    $user = User::find($id);
    if (!$user) {
        return response()->json(['message' => 'User not found'], 404);
    }

    
    // 1. VALIDASI
    $request->validate([
        'name' => 'required|string',
        // PENTING: Tambahkan .$id di belakang agar Laravel tidak mengira email ini duplikat saat diedit
        'email' => 'required|email|unique:users,email,' . $id,
        // PENTING: Password wajib nullable, karena kalau kosong berarti admin gak mau ganti passwordnya
        'password' => 'nullable|min:6',
        'role' => 'required|string',
        'membership_status' => 'required|string',
    ]);

    // 2. SIMPAN DATA TEXT
    $user->name = $request->name;
    $user->email = $request->email;
    $user->phone_number = $request->phone_number;
    $user->address = $request->address;
    $user->role = $request->role;
    $user->membership_status = $request->membership_status;

    // 3. SIMPAN PASSWORD (HANYA JIKA DIISI)
    if ($request->filled('password')) {
        $user->password = Hash::make($request->password);
    }

    $user->save();

    return response()->json(['message' => 'User berhasil diupdate', 'data' => $user], 200);
}
}