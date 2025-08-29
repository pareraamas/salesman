<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('product_items', function (Blueprint $table) {
            $table->id();

            // Relasi ke product
            $table->foreignId('product_id')
                ->constrained('products')
                ->cascadeOnDelete();

            // Relasi ke consignment
            $table->foreignId('consignment_id')
                ->constrained('consignments')
                ->cascadeOnDelete();

            // Relasi ke transaction
            $table->foreignId('transaction_id')
                ->nullable()
                ->constrained('transactions')
                ->cascadeOnDelete();

            $table->string('name');
            $table->string('code');
            $table->decimal('price', 12, 2);
            $table->text('description')->nullable();
            $table->integer('qty')->default(0);
            $table->integer('sales')->default(0);
            $table->integer('return')->default(0); // ganti nama kolom biar aman
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down()
    {
        Schema::dropIfExists('product_items');
    }
};
