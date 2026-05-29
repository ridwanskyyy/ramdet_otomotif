<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            
            // Foreign Key yang menghubungkan produk ke pembuatnya (user)
            // onDelete('cascade') artinya jika user dihapus, produk miliknya otomatis ikut terhapus
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            
            $table->string('title');         // Nama velg atau desain modifikasi
            $table->text('description');     // Detail spesifikasi produk
            $table->string('image_url')->nullable(); // Path atau URL foto produk (dibuat nullable agar fleksibel)
            $table->decimal('price', 12, 2); // Harga produk (12 digit total, 2 angka di belakang koma)
            $table->string('category');      // Kategori motor (Sport, Matic, atau Bebek)
            
            $table->timestamps();            // Otomatis membuat kolom created_at dan updated_at
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};