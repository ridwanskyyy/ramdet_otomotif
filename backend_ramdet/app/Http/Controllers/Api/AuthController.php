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
        $data['user'] = $user;

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
        $data['user'] = $user;

        return $this->sendResponse($data, 'Login berhasil');
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return $this->sendResponse([], 'Logout berhasil');
    }

    // Fitur Pembaruan Profil (Update Profile)
    // Berfungsi untuk mengubah nama, nomor telepon, dan bio singkat pengguna
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'bio' => 'nullable|string',
        ]);

        // Proteksi Mass Assignment menggunakan request->only()
        $user->update($request->only(['name', 'phone', 'bio']));

        return $this->sendResponse($user, 'Profil berhasil diperbarui.');
    }
}