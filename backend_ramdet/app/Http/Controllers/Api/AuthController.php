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
            'password' => 'required|string|min:8',
            'phone_number' => 'required|string|max:20', 
            'address' => 'required|string'               
        ]);

        // SEKARANG AMAN: Semua key array di bawah ini sudah punya kolom aslinya di DB & Model
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phone_number' => $request->phone_number, 
            'address' => $request->address,           
            'membership_status' => 'bronze' // Masuk ke enum kasta terendah secara otomatis
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

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|unique:users,email,'.$user->id,
            'phone_number' => 'nullable|string|max:20',
            'address' => 'nullable|string', 
            'membership_status' => 'required|in:bronze,silver,gold,platinum',
            'profile_photo' => 'nullable|image|mimes:jpeg,png,jpg|max:2048'
        ]);

        $updateData = [
            'name' => $request->name,
            'email' => $request->email,
            'phone_number' => $request->phone_number, 
            'address' => $request->address,           
            'membership_status' => $request->membership_status,
        ];

        if ($request->hasFile('profile_photo')) {
            $file = $request->file('profile_photo');
            $fileName = 'avatar_' . $user->id . '_' . time() . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('storage/avatars'), $fileName);
            
            $updateData['profile_photo_path'] = 'storage/avatars/' . $fileName;
        }

        $user->update($updateData);

        return $this->sendResponse($user, 'Profil berhasil diperbarui.');
    }
    public function changePassword(Request $request)
{
    // 1. Validasi input dari Flutter
    $request->validate([
        'old_password' => 'required|string',
        'new_password' => 'required|string|min:8',
    ]);

    $user = $request->user();

    // 2. Cek apakah password lama cocok dengan yang ada di database MySQL
    if (!Hash::check($request->old_password, $user->password)) {
        return response()->json([
            'success' => false,
            'message' => 'Password lama yang Anda masukkan salah.'
        ], 401);
    }

    // 3. Update password baru (otomatis di-hash ulang oleh cast Laravel)
    $user->update([
        'password' => Hash::make($request->new_password)
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Password akun berhasil diperbarui.'
    ], 200);
}
}