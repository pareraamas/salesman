<?php

namespace App\Http\Controllers;

use App\Models\Transaction;
use Illuminate\Http\Request;

class TransactionPrintController extends Controller
{
    public function __invoke(Transaction $transaction)
    {
        $transaction->load([
            'items.product',
            'consignment.store',
            'consignment.salesman'
        ]);

        return view('transactions.print', compact('transaction'));
    }
}
