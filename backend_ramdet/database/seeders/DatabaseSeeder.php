<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Membuat akun admin bawaan otomatis
        User::create([
            'name' => 'Admin Ramdet',
            'email' => 'admin@ramdet.com',
            'password' => Hash::make('admin123'),
            'phone_number' => '087785115589',
            'address' => 'Bengkel Ramdet',
            'membership_status' => 'platinum', 
            'role' => 'admin', // Ini yang menentukan hak aksesnya
        ]);

        // 2. Memanggil ProductSeeder untuk mengisi data dummy produk
        $this->call([
            ProductSeeder::class,
        ]);
    }
}