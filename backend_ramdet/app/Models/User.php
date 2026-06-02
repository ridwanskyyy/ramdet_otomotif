<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    // REVISI: Menyelaraskan properti yang boleh diisi massal dengan database baru
    protected $fillable = [
        'name',
        'email',
        'password',
        'phone_number',
        'address',             // Sesuai DB baru
        'profile_photo_path',  // Sesuai DB baru
        'membership_status',   // Sesuai DB baru
        'role',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'password' => 'hashed',
    ];
}