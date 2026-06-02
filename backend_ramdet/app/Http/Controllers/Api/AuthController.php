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

    // REVISI TOTAL: Fitur Pembaruan Profil (Update Profile)
    // Sekarang sudah mendukung perubahan email, nomor telepon, dan alamat sesuai kiriman Flutter
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        // 1. Validasi Input Data
        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            // PENTING: Tambahkan pengecualian ID (,$user->id) agar tidak mengunci email diri sendiri saat di-save
            'email' => 'sometimes|required|string|email|unique:users,email,'.$user->id,
            'phone_number' => 'nullable|string|max:20',
            'address' => 'nullable|string',
        ]);

        // 2. Siapkan data yang pasti aman di-update (Nama & Email pasti ada di DB)
        $updateData = [
            'name' => $request->name,
            'email' => $request->email,
        ];

        // 3. PENCEGAHAN SQL ERROR: Hanya masukkan phone_number & address jika Ridwan sudah membuat kolomnya di DB
        if ($request->has('phone_number')) {
            $updateData['phone_number'] = $request->phone_number;
        }
        if ($request->has('address')) {
            $updateData['address'] = $request->address;
        }

        // 4. Eksekusi pembaruan ke database MySQL
        $user->update($updateData);

        return $this->sendResponse($user, 'Profil berhasil diperbarui.');
    }
}