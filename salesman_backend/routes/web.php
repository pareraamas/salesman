<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\TransactionPrintController;

Route::get('/', function () {
    return redirect('/admin');
});

Route::get('/transactions/{transaction}/print', TransactionPrintController::class)
    ->name('transactions.print');
