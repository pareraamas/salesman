<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Store;

class StoreSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Store::create([
            'id'         => 1,
            'name'       => 'Toko madura',
            'address'    => 'jombang',
            'phone'      => '0876857858',
            'owner_name' => 'Julianto',
            'latitude'   => -7.546839,
            'longitude'  => 12.23307,
            'photo_path' => 'stores/01K3MTM3ER1KDAEP358VWEY0SR.webp',
            'created_at' => '2025-08-27 03:54:52',
            'updated_at' => '2025-08-27 03:54:52',
        ]);
    }
}
