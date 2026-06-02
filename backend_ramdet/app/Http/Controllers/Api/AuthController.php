<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage; 

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

    // REVISI: Mendukung penyimpanan foto profil 
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        // 1. Validasi Input Data
        // Ditambahkan aturan validasi file 'image' (wajib berupa gambar, tipe jpeg/png/jpg, ukuran maksimal 2MB)
        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|string|email|unique:users,email,'.$user->id,
            'phone_number' => 'nullable|string|max:20', 
            'alamat' => 'nullable|string', 
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048', 
        ]);

        // 2. Proteksi Mass Assignment menggunakan request->only()
        $updateData = $request->only(['name', 'email', 'phone_number', 'alamat']);

        // 3. Logika Upload Foto Profil
        if ($request->hasFile('image')) {
            // Jika user sebelumnya sudah punya foto profil, hapus file lamanya dari folder storage
            if ($user->image && Storage::disk('public')->exists($user->image)) {
                Storage::disk('public')->delete($user->image);
            }

            // Simpan file gambar baru ke dalam folder 'storage/app/public/profiles'
            $path = $request->file('image')->store('profiles', 'public');
            
            // Masukkan path file baru ke array data yang akan di-update
            $updateData['image'] = $path;
        }

        // 4. Eksekusi pembaruan data ke database
        $user->update($updateData);

        return $this->sendResponse($user, 'Profil berhasil diperbarui.');
    }
}