<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Product;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Product::insert([
            [
                'id'          => 1,
                'name'        => 'Mie Basah',
                'code'        => 'SK-001',
                'price'       => 2000,
                'description' => null,
                'photo_path'  => 'products/01K3MTMPFMPHFFWCWB08P78V0S.png',
                'created_at'  => '2025-08-27 03:55:12',
                'updated_at'  => '2025-08-27 03:55:12',
            ],
            [
                'id'          => 2,
                'name'        => 'Es Teh',
                'code'        => 'SK-002',
                'price'       => 3000,
                'description' => null,
                'photo_path'  => 'products/01K3MTNGNFY0BR2Z89BYD2CC3P.jpg',
                'created_at'  => '2025-08-27 03:55:39',
                'updated_at'  => '2025-08-27 03:55:39',
            ],
        ]);
    }
}
