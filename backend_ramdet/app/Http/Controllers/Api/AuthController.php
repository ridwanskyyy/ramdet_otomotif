<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'email' => 'required|string|email|unique:users',
            'password' => 'required|string|min:8'
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password)
        ]);

        $data['access_token'] = $user->createToken('auth_token')->plainTextToken;
        $data['token_type'] = 'Bearer';
        $data['user'] = $user; // Otomatis menyertakan data role default ('user') ke Flutter

        return $this->sendResponse($data, 'Register berhasil', 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return $this->sendError('Email atau password yang Anda masukkan salah', 401);
        }

        $data['access_token'] = $user->createToken('auth_token')->plainTextToken;
        $data['token_type'] = 'Bearer';
        $data['user'] = $user; // Otomatis menyertakan data 'role' dan 'membership' dari database ke Flutter

        return $this->sendResponse($data, 'Login berhasil');
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return $this->sendResponse([], 'Logout berhasil');
    }

    // REVISI TOTAL: Menggabungkan logika proteksi role (Ridwan) dan pembaruan email (Dimas)
    // Menggunakan kolom database yang sah: phone_number dan alamat
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        // 1. Validasi Input Data
        // Ditambahkan pengecualian ID (,$user->id) agar user tidak mengunci emailnya sendiri saat update data lain
        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|string|email|unique:users,email,'.$user->id,
            'phone_number' => 'nullable|string|max:20', 
            'alamat' => 'nullable|string',               
        ]);

        // 2. Proteksi Mass Assignment menggunakan request->only()
        // Kita hanya mengizinkan perubahan nama, email, nomor telepon, dan alamat.
        // Kolom 'role' atau 'membership' sengaja tidak dimasukkan agar tidak bisa ditembak oleh user biasa.
        $updateData = $request->only(['name', 'email', 'phone_number', 'alamat']);

        // 3. Eksekusi pembaruan ke database MySQL
        $user->update($updateData);

        return $this->sendResponse($user, 'Profil berhasil diperbarui.');
    }
}