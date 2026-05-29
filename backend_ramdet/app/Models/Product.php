<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'title',
        'description',
        'image_url',
        'price',
        'category',
    ];

    // Relasi: Product ini dimiliki oleh User
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}