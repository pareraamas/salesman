<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::factory()->create([
            'name' => 'Test Admin',
            'email' => 'admin@gmail.com',
            'password' => 'admin12345',
        ]);

        User::factory()->create(
            [
                'name' => 'Test user',
                'email' => 'user@gmail.com',
                'password' => 'user12345',
            ]
        );

        $this->call([
            StoreSeeder::class,
            ProductSeeder::class
        ]);
    }
}
