<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTransactionRequest;
use App\Http\Requests\UpdateTransactionRequest;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class TransactionController extends BaseController
{
    /**
     * @OA\Get(
     *     path="/api/transactions",
     *     operationId="getTransactionsList",
     *     tags={"Transactions"},
     *     summary="Get list of transactions with optional filters",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="consignment_id",
     *         in="query",
     *         description="Filter by consignment ID",
     *         required=false,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Parameter(
     *         name="store_id",
     *         in="query",
     *         description="Filter by store ID",
     *         required=false,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Parameter(
     *         name="product_id",
     *         in="query",
     *         description="Filter by product ID",
     *         required=false,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Parameter(
     *         name="from_date",
     *         in="query",
     *         description="Filter by transaction date from (YYYY-MM-DD)",
     *         required=false,
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="to_date",
     *         in="query",
     *         description="Filter by transaction date to (YYYY-MM-DD)",
     *         required=false,
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="per_page",
     *         in="query",
     *         description="Items per page",
     *         required=false,
     *         @OA\Schema(type="integer", default=15)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array",
     *                 @OA\Items(ref="#/components/schemas/Transaction")
     *             ),
     *             @OA\Property(property="message", type="string", example="Transactions retrieved successfully")
     *         )
     *     )
     * )
     */
    public function index(Request $request)
    {
        $query = Transaction::with(['consignment.store', 'consignment.product']);

        // Apply filters
        if ($request->has('consignment_id')) {
            $query->where('consignment_id', $request->consignment_id);
        }

        if ($request->has('store_id')) {
            $query->whereHas('consignment', function($q) use ($request) {
                $q->where('store_id', $request->store_id);
            });
        }

        if ($request->has('product_id')) {
            $query->whereHas('consignment', function($q) use ($request) {
                $q->where('product_id', $request->product_id);
            });
        }

        if ($request->has('from_date')) {
            $query->whereDate('transaction_date', '>=', $request->from_date);
        }

        if ($request->has('to_date')) {
            $query->whereDate('transaction_date', '<=', $request->to_date);
        }

        $perPage = $request->input('per_page', 15);
        $transactions = $query->latest('transaction_date')->paginate($perPage);

        return $this->sendResponse($transactions, 'Transactions retrieved successfully');
    }

    /**
     * @OA\Post(
     *     path="/api/transactions",
     *     operationId="storeTransaction",
     *     tags={"Transactions"},
     *     summary="Create a new transaction",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/TransactionInput")
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Transaction created successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Transaction"),
     *             @OA\Property(property="message", type="string", example="Transaction created successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error"
     *     )
     * )
     */
    public function store(StoreTransactionRequest $request)
    {
        $data = $request->validated();
        
        // Handle photo uploads
        if ($request->hasFile('sold_items_photo')) {
            $data['sold_items_photo_path'] = $request->file('sold_items_photo')
                ->store('transactions/sold', 'public');
        }
        
        if ($request->hasFile('returned_items_photo')) {
            $data['returned_items_photo_path'] = $request->file('returned_items_photo')
                ->store('transactions/returned', 'public');
        }

        $transaction = Transaction::create($data);
        $transaction->load(['consignment.store', 'consignment.product']);

        // Update consignment status if all items are sold or returned
        $this->updateConsignmentStatus($transaction->consignment);

        return $this->sendResponse($transaction, 'Transaction created successfully', 201);
    }

    /**
     * @OA\Get(
     *     path="/api/transactions/{id}",
     *     operationId="getTransactionById",
     *     tags={"Transactions"},
     *     summary="Get transaction details",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="Transaction ID",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Transaction retrieved successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Transaction"),
     *             @OA\Property(property="message", type="string", example="Transaction retrieved successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Transaction not found"
     *     )
     * )
     */
    public function show(Transaction $transaction)
    {
        $transaction->load(['consignment.store', 'consignment.product']);
        return $this->sendResponse($transaction, 'Transaction retrieved successfully');
    }

    /**
     * @OA\Put(
     *     path="/api/transactions/{id}",
     *     operationId="updateTransaction",
     *     tags={"Transactions"},
     *     summary="Update transaction details",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="Transaction ID",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/TransactionInput")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Transaction updated successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Transaction"),
     *             @OA\Property(property="message", type="string", example="Transaction updated successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Transaction not found"
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error"
     *     )
     * )
     */
    public function update(UpdateTransactionRequest $request, Transaction $transaction)
    {
        $data = $request->validated();
        
        // Handle photo uploads
        if ($request->hasFile('sold_items_photo')) {
            // Delete old photo if exists
            if ($transaction->sold_items_photo_path) {
                Storage::disk('public')->delete($transaction->sold_items_photo_path);
            }
            $data['sold_items_photo_path'] = $request->file('sold_items_photo')
                ->store('transactions/sold', 'public');
        }
        
        if ($request->hasFile('returned_items_photo')) {
            // Delete old photo if exists
            if ($transaction->returned_items_photo_path) {
                Storage::disk('public')->delete($transaction->returned_items_photo_path);
            }
            $data['returned_items_photo_path'] = $request->file('returned_items_photo')
                ->store('transactions/returned', 'public');
        }

        $transaction->update($data);
        $transaction->load(['consignment.store', 'consignment.product']);

        // Update consignment status if all items are sold or returned
        $this->updateConsignmentStatus($transaction->consignment);

        return $this->sendResponse($transaction, 'Transaction updated successfully');
    }

    /**
     * @OA\Delete(
     *     path="/api/transactions/{id}",
     *     operationId="deleteTransaction",
     *     tags={"Transactions"},
     *     summary="Delete a transaction",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="Transaction ID",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Transaction deleted successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Transaction deleted successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Transaction not found"
     *     )
     * )
     */
    public function destroy(Transaction $transaction)
    {
        $consignment = $transaction->consignment;
        
        // Delete photos if they exist
        if ($transaction->sold_items_photo_path) {
            Storage::disk('public')->delete($transaction->sold_items_photo_path);
        }
        if ($transaction->returned_items_photo_path) {
            Storage::disk('public')->delete($transaction->returned_items_photo_path);
        }

        $transaction->delete();

        // Update consignment status after deletion
        if ($consignment) {
            $this->updateConsignmentStatus($consignment);
        }

        return $this->sendResponse([], 'Transaction deleted successfully');
    }

    /**
     * Update consignment status based on transactions.
     *
     * @param  \App\Models\Consignment  $consignment
     * @return void
     */
    protected function updateConsignmentStatus($consignment)
    {
        $totalSold = $consignment->transactions()->sum('sold_quantity');
        $totalReturned = $consignment->transactions()->sum('returned_quantity');
        $totalProcessed = $totalSold + $totalReturned;
        
        if ($totalProcessed >= $consignment->quantity) {
            // All items are either sold or returned
            $status = $totalSold > 0 ? Consignment::STATUS_SOLD : Consignment::STATUS_RETURNED;
            $consignment->update(['status' => $status]);
        } else if ($totalProcessed > 0) {
            // Some items are processed, but not all
            $consignment->update(['status' => Consignment::STATUS_ACTIVE]);
        }
        // If no items processed, keep the original status
    }
}
