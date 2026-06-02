<?php

namespace Database\Seeders;

use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $products = [
            [
                'name' => 'Velg Racing RCB S1 Flow Forming',
                'description' => 'Velg racing original RCB seri S1 dengan teknologi Flow Forming. Bobot ultra ringan namun memiliki durabilitas tinggi untuk meningkatkan akselerasi motor bebek.',
                'price' => 1650000.00,
                'image' => 'products/velg_rcb_s1.jpg',
                'category' => 'Bebek',
            ],
            [
                'name' => 'Shockbreaker Ohlins Tabung Bawah Premium',
                'description' => 'Suspensi premium Ohlins original dengan sistem tabung bawah. Dilengkapi fitur adjustable klik rebound untuk kenyamanan maksimal di berbagai medan jalan.',
                'price' => 3450000.00,
                'image' => 'products/ohlins_matic.jpg',
                'category' => 'Matic',
            ],
            [
                'name' => 'Knalpot Proliner TR1 R Short Full System',
                'description' => 'Knalpot racing Proliner TR1 R tipe pendek (short). Menghasilkan suara ngebass gahar bulat dan mendongkrak performa power mesin secara instan.',
                'price' => 950000.00,
                'image' => 'products/proliner_tr1.jpg',
                'category' => 'Sport',
            ],
            [
                'name' => 'Ban Pirelli Diablo Rosso Sport',
                'description' => 'Ban motor harian dengan gaya racing (compound medium-soft). Memberikan cengkeraman atau grip maksimal saat cornering, baik kondisi jalan basah maupun kering.',
                'price' => 580000.00,
                'image' => 'products/pirelli_diablo.jpg',
                'category' => 'Matic',
            ],
            [
                'name' => 'Master Rem Brembo RCS 19 Corsa Corta',
                'description' => 'Sistem pengereman depan hidrolik Brembo RCS 19 Corsa Corta. Menggunakan teknologi motoGP untuk kontrol pengereman yang sangat pakem, responsif, dan empuk.',
                'price' => 4250000.00,
                'image' => 'products/brembo_rcs19.jpg',
                'category' => 'Universal',
            ],
        ];

        foreach ($products as $product) {
            Product::create($product);
        }
    }
}