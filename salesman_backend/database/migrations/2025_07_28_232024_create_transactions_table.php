<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    function up()
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('consignment_id')->constrained()->onDelete('cascade');
            $table->dateTime('transaction_date');
            $table->string('sold_items_photo_path')->nullable();
            $table->string('returned_items_photo_path')->nullable();
            $table->text('notes')->nullable();
            $table->string('status')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    function down()
    {
        Schema::dropIfExists('transactions');
    }
};
