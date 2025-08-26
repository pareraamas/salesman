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
            $table->int('product_id');
            $table->foreignId('consignment_id')->references('consignments');
            $table->string('name');
            $table->string('code')->unique();
            $table->decimal('price', 12, 2);
            $table->text('description')->nullable();
            $table->string('photo_path')->nullable();
            $table->integer('qty')->default(0);
            $table->integer('sales')->default(0);
            $table->integer('qty')->default(0);
            $table->integer('return')->default(0);
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
