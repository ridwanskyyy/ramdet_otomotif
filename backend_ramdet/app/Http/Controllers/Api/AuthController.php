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

    // Fitur Pembaruan Profil (Update Profile)
    // Diperbarui agar menggunakan nama kolom baru: phone_number dan alamat
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'phone_number' => 'nullable|string|max:20', // Menggantikan phone
            'alamat' => 'nullable|string',               // Menggantikan bio
        ]);

        // Proteksi Mass Assignment menggunakan request->only()
        // Kita hanya mengizinkan perubahan nama, nomor telepon, dan alamat.
        // Jangan pernah masukkan 'role' atau 'membership' di dalam array only() ini,
        // supaya user biasa tidak bisa menembak API ini untuk mengubah role mereka sendiri menjadi admin.
        $user->update($request->only(['name', 'phone_number', 'alamat']));

        return $this->sendResponse($user, 'Profil berhasil diperbarui.');
    }
}