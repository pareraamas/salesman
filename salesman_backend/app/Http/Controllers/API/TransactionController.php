<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTransactionRequest;
use App\Http\Requests\UpdateTransactionRequest;
use App\Models\Consignment;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response as HttpResponse;

class TransactionController extends BaseController
{
    /**
     * @OA\Get(
     *     path="/api/transactions",
     *     operationId="getTransactionsList",
     *     tags={"Transaksi"},
     *     summary="Mendapatkan daftar transaksi dengan filter opsional",
     *     description="Mengambil daftar transaksi dengan berbagai filter yang tersedia. Mendukung paginasi.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="consignment_id",
     *         in="query",
     *         description="Filter berdasarkan ID konsinyasi",
     *         required=false,
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Parameter(
     *         name="store_id",
     *         in="query",
     *         description="Filter berdasarkan ID toko",
     *         required=false,
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Parameter(
     *         name="product_id",
     *         in="query",
     *         description="Filter berdasarkan ID produk",
     *         required=false,
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Parameter(
     *         name="from_date",
     *         in="query",
     *         description="Filter berdasarkan tanggal transaksi dari (format: YYYY-MM-DD)",
     *         required=false,
     *         @OA\Schema(type="string", format="date", example="2025-01-01")
     *     ),
     *     @OA\Parameter(
     *         name="to_date",
     *         in="query",
     *         description="Filter berdasarkan tanggal transaksi sampai (format: YYYY-MM-DD)",
     *         required=false,
     *         @OA\Schema(type="string", format="date", example="2025-12-31")
     *     ),
     *     @OA\Parameter(
     *         name="per_page",
     *         in="query",
     *         description="Jumlah item per halaman",
     *         required=false,
     *         @OA\Schema(type="integer", default=15, example=15)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Berhasil mengambil daftar transaksi",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="current_page", type="integer", example=1),
     *                 @OA\Property(property="data", type="array",
     *                     @OA\Items(type="object",
     *                         @OA\Property(property="id", type="integer", example=1, description="ID transaksi"),
     *                         @OA\Property(property="consignment_id", type="integer", example=1, description="ID konsinyasi"),
     *                         @OA\Property(property="transaction_date", type="string", format="date-time", description="Tanggal transaksi"),
     *                         @OA\Property(property="sold_quantity", type="integer", example=5, description="Jumlah terjual"),
     *                         @OA\Property(property="returned_quantity", type="integer", example=0, description="Jumlah dikembalikan"),
     *                         @OA\Property(property="notes", type="string", nullable=true, example="Catatan transaksi"),
     *                         @OA\Property(property="sold_items_photo_path", type="string", nullable=true, example="transactions/sold/abc123.jpg"),
     *                         @OA\Property(property="returned_items_photo_path", type="string", nullable=true, example="transactions/returned/def456.jpg"),
     *                         @OA\Property(property="created_at", type="string", format="date-time"),
     *                         @OA\Property(property="updated_at", type="string", format="date-time"),
     *                         @OA\Property(property="consignment", type="object",
     *                             @OA\Property(property="id", type="integer", example=1),
     *                             @OA\Property(property="store", type="object",
     *                                 @OA\Property(property="id", type="integer", example=1),
     *                                 @OA\Property(property="name", type="string", example="Toko Baru")
     *                             ),
     *                             @OA\Property(property="product", type="object",
     *                                 @OA\Property(property="id", type="integer", example=1),
     *                                 @OA\Property(property="name", type="string", example="Produk A")
     *                             )
     *                         )
     *                     )
     *                 ),
     *                 @OA\Property(property="first_page_url", type="string", example="http://localhost/api/transactions?page=1"),
     *                 @OA\Property(property="from", type="integer", example=1),
     *                 @OA\Property(property="last_page", type="integer", example=1),
     *                 @OA\Property(property="last_page_url", type="string", example="http://localhost/api/transactions?page=1"),
     *                 @OA\Property(property="links", type="array",
     *                     @OA\Items(type="object",
     *                         @OA\Property(property="url", type="string", nullable=true, example=null),
     *                         @OA\Property(property="label", type="string", example="&laquo; Previous"),
     *                         @OA\Property(property="active", type="boolean", example=false)
     *                     )
     *                 ),
     *                 @OA\Property(property="next_page_url", type="string", nullable=true, example=null),
     *                 @OA\Property(property="path", type="string", example="http://localhost/api/transactions"),
     *                 @OA\Property(property="per_page", type="integer", example=15),
     *                 @OA\Property(property="prev_page_url", type="string", nullable=true, example=null),
     *                 @OA\Property(property="to", type="integer", example=10),
     *                 @OA\Property(property="total", type="integer", example=10)
     *             ),
     *             @OA\Property(property="message", type="string", example="Daftar transaksi berhasil diambil"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=200)
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Tidak terautentikasi",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Tidak terautentikasi"),
     *             @OA\Property(property="code", type="integer", example=401)
     *         )
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="Tidak diizinkan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk mengakses daftar transaksi"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat mengambil daftar transaksi"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    /**
     * @OA\Get(
     *     path="/api/transactions/summary",
     *     operationId="getTransactionsSummary",
     *     tags={"Laporan"},
     *     summary="Mendapatkan ringkasan transaksi untuk laporan",
     *     description="Mengambil ringkasan statistik transaksi termasuk total transaksi, total terjual, total dikembalikan, dan ringkasan per toko.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Ringkasan transaksi berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="total_transactions", type="integer", example=100, description="Total jumlah transaksi"),
     *                 @OA\Property(property="total_sold", type="integer", example=500, description="Total barang terjual"),
     *                 @OA\Property(property="total_returned", type="integer", example=50, description="Total barang dikembalikan"),
     *                 @OA\Property(property="stores_summary", type="array",
     *                     description="Ringkasan statistik per toko",
     *                     @OA\Items(
     *                         @OA\Property(property="store_id", type="integer", example=1, description="ID toko"),
     *                         @OA\Property(property="store_name", type="string", example="Toko Baru", description="Nama toko"),
     *                         @OA\Property(property="total_transactions", type="integer", example=10, description="Jumlah transaksi di toko ini"),
     *                         @OA\Property(property="total_sold", type="integer", example=50, description="Total barang terjual di toko ini"),
     *                         @OA\Property(property="total_returned", type="integer", example=5, description="Total barang dikembalikan di toko ini")
     *                     )
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string", example="Ringkasan transaksi berhasil diambil"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=200)
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Tidak terautentikasi",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Tidak terautentikasi"),
     *             @OA\Property(property="code", type="integer", example=401)
     *         )
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="Tidak diizinkan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk mengakses ringkasan transaksi"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat mengambil ringkasan transaksi"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function summary()
    {
        $summary = [
            'total_transactions' => Transaction::count(),
            'total_sold' => Transaction::sum('sold_quantity'),
            'total_returned' => Transaction::sum('returned_quantity'),
            'stores_summary' => []
        ];

        // Get summary by store
        $stores = Consignment::with('store')
            ->select('store_id')
            ->distinct()
            ->get()
            ->map(function($consignment) {
                $storeId = $consignment->store_id;
                $transactions = Transaction::whereHas('consignment', function($q) use ($storeId) {
                    $q->where('store_id', $storeId);
                });

                return [
                    'store_id' => $storeId,
                    'store_name' => $consignment->store->name,
                    'total_transactions' => $transactions->count(),
                    'total_sold' => $transactions->sum('sold_quantity'),
                    'total_returned' => $transactions->sum('returned_quantity')
                ];
            });

        $summary['stores_summary'] = $stores;

        return $this->sendResponse($summary, 'Transactions summary retrieved successfully');
    }

    public function index(Request $request)
    {
        try {
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
            $transactions = $query->with('items')->latest('transaction_date')->paginate($perPage);

            return $this->sendResponse(
                $transactions->through(function ($transaction) {
                    return [
                        'id' => $transaction->id,
                        'consignment_id' => $transaction->consignment_id,
                        'transaction_date' => $transaction->transaction_date,
                        'total_sold' => $transaction->total_sold,
                        'total_returned' => $transaction->total_returned,
                        'net_quantity' => $transaction->net_quantity,
                        'total_amount' => $transaction->total_amount,
                        'notes' => $transaction->notes,
                        'sold_items_photo_path' => $transaction->sold_items_photo_path,
                        'returned_items_photo_path' => $transaction->returned_items_photo_path,
                        'created_at' => $transaction->created_at,
                        'updated_at' => $transaction->updated_at,
                        'items' => $transaction->items->map(function ($item) {
                            return [
                                'id' => $item->id,
                                'product_id' => $item->product_id,
                                'name' => $item->name,
                                'code' => $item->code,
                                'price' => $item->price,
                                'qty' => $item->qty,
                                'sold' => $item->sales,
                                'returned' => $item->return,
                            ];
                        }),
                        'consignment' => $transaction->consignment ? [
                            'id' => $transaction->consignment->id,
                            'store' => $transaction->consignment->store ? [
                                'id' => $transaction->consignment->store->id,
                                'name' => $transaction->consignment->store->name,
                            ] : null,
                        ] : null,
                    ];
                }),
                'Daftar transaksi berhasil diambil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error getting transactions: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil daftar transaksi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Post(
     *     path="/api/transactions",
     *     operationId="storeTransaction",
     *     tags={"Transaksi"},
     *     summary="Membuat transaksi baru",
     *     description="Membuat transaksi baru untuk konsinyasi yang sudah ada. Mendukung unggahan foto barang terjual dan dikembalikan.",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         description="Data transaksi yang akan dibuat",
     *         @OA\MediaType(
     *             mediaType="multipart/form-data",
     *             @OA\Schema(
     *                 required={"consignment_id", "transaction_date", "sold_quantity"},
     *                 @OA\Property(property="consignment_id", type="integer", example=1, description="ID konsinyasi yang terkait"),
     *                 @OA\Property(property="transaction_date", type="string", format="date", example="2025-01-01", description="Tanggal transaksi (format: YYYY-MM-DD)"),
     *                 @OA\Property(property="sold_quantity", type="integer", example=5, description="Jumlah barang yang terjual"),
     *                 @OA\Property(property="returned_quantity", type="integer", example=0, description="Jumlah barang yang dikembalikan (opsional)"),
     *                 @OA\Property(property="notes", type="string", example="Catatan transaksi", nullable=true, description="Catatan tambahan (opsional)"),
     *                 @OA\Property(property="sold_items_photo", type="string", format="binary", description="Foto barang yang terjual (format: jpg,jpeg,png|max:2048)"),
     *                 @OA\Property(property="returned_items_photo", type="string", format="binary", description="Foto barang yang dikembalikan (format: jpg,jpeg,png|max:2048)")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Transaksi berhasil dibuat",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1, description="ID transaksi"),
     *                 @OA\Property(property="consignment_id", type="integer", example=1, description="ID konsinyasi"),
     *                 @OA\Property(property="transaction_date", type="string", format="date-time", description="Tanggal transaksi"),
     *                 @OA\Property(property="sold_quantity", type="integer", example=5, description="Jumlah terjual"),
     *                 @OA\Property(property="returned_quantity", type="integer", example=0, description="Jumlah dikembalikan"),
     *                 @OA\Property(property="notes", type="string", nullable=true, example="Catatan transaksi"),
     *                 @OA\Property(property="sold_items_photo_path", type="string", nullable=true, example="transactions/sold/abc123.jpg"),
     *                 @OA\Property(property="returned_items_photo_path", type="string", nullable=true, example="transactions/returned/def456.jpg"),
     *                 @OA\Property(property="created_at", type="string", format="date-time"),
     *                 @OA\Property(property="updated_at", type="string", format="date-time"),
     *                 @OA\Property(property="consignment", type="object",
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="store", type="object",
     *                         @OA\Property(property="id", type="integer", example=1),
     *                         @OA\Property(property="name", type="string", example="Toko Baru")
     *                     ),
     *                     @OA\Property(property="product", type="object",
     *                         @OA\Property(property="id", type="integer", example=1),
     *                         @OA\Property(property="name", type="string", example="Produk A")
     *                     )
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string", example="Transaksi berhasil dibuat"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=201)
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Permintaan tidak valid",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Data tidak valid"),
     *             @OA\Property(property="code", type="integer", example=400)
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Tidak terautentikasi",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Tidak terautentikasi"),
     *             @OA\Property(property="code", type="integer", example=401)
     *         )
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="Tidak diizinkan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk membuat transaksi"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Konsinyasi tidak ditemukan"),
     *             @OA\Property(property="code", type="integer", example=404)
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validasi gagal",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Validasi gagal"),
     *             @OA\Property(property="errors", type="object",
     *                 @OA\Property(property="consignment_id", type="array",
     *                     @OA\Items(type="string", example="Konsinyasi tidak valid")
     *                 ),
     *                 @OA\Property(property="sold_quantity", type="array",
     *                     @OA\Items(type="string", example="Jumlah terjual harus diisi")
     *                 )
     *             ),
     *             @OA\Property(property="code", type="integer", example=422)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat membuat transaksi"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function store(StoreTransactionRequest $request)
    {
        try {
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

            // Create transaction
            $transaction = Transaction::create($data);
            $transaction->load(['consignment.store', 'consignment.product', 'items']);

            // Attach items to transaction by updating ProductItem rows
            foreach (($data['items'] ?? []) as $item) {
                $pi = \App\Models\ProductItem::find($item['product_item_id']);
                if (!$pi) continue;
                $pi->transaction_id = $transaction->id;
                $pi->sales = (int) ($item['sold'] ?? 0);
                $pi->return = (int) ($item['returned'] ?? 0);
                if (isset($item['price'])) {
                    $pi->price = $item['price'];
                }
                $pi->save();
            }

            // Update consignment status based on items
            $this->updateConsignmentStatus($transaction->consignment);

            $transaction->load('items');

            return $this->sendResponse(
                $transaction,
                'Transaksi berhasil dibuat',
                HttpResponse::HTTP_CREATED
            );
        } catch (\Exception $e) {
            Log::error('Error creating transaction: ' . $e->getMessage());
            return $this->sendError(
                'Gagal membuat transaksi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Get(
     *     path="/api/transactions/{id}",
     *     operationId="getTransactionById",
     *     tags={"Transaksi"},
     *     summary="Mendapatkan detail transaksi",
     *     description="Mengambil detail transaksi berdasarkan ID",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID transaksi",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Detail transaksi berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1, description="ID transaksi"),
     *                 @OA\Property(property="consignment_id", type="integer", example=1, description="ID konsinyasi"),
     *                 @OA\Property(property="transaction_date", type="string", format="date-time", description="Tanggal transaksi"),
     *                 @OA\Property(property="sold_quantity", type="integer", example=5, description="Jumlah terjual"),
     *                 @OA\Property(property="returned_quantity", type="integer", example=0, description="Jumlah dikembalikan"),
     *                 @OA\Property(property="notes", type="string", nullable=true, example="Catatan transaksi"),
     *                 @OA\Property(property="sold_items_photo_path", type="string", nullable=true, example="transactions/sold/abc123.jpg"),
     *                 @OA\Property(property="returned_items_photo_path", type="string", nullable=true, example="transactions/returned/def456.jpg"),
     *                 @OA\Property(property="created_at", type="string", format="date-time"),
     *                 @OA\Property(property="updated_at", type="string", format="date-time"),
     *                 @OA\Property(property="consignment", type="object",
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="store", type="object",
     *                         @OA\Property(property="id", type="integer", example=1),
     *                         @OA\Property(property="name", type="string", example="Toko Baru")
     *                     ),
     *                     @OA\Property(property="product", type="object",
     *                         @OA\Property(property="id", type="integer", example=1),
     *                         @OA\Property(property="name", type="string", example="Produk A")
     *                     )
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string", example="Detail transaksi berhasil diambil"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=200)
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Tidak terautentikasi",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Tidak terautentikasi"),
     *             @OA\Property(property="code", type="integer", example=401)
     *         )
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="Tidak diizinkan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk melihat transaksi ini"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Transaksi tidak ditemukan"),
     *             @OA\Property(property="code", type="integer", example=404)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat mengambil detail transaksi"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function show(Transaction $transaction)
    {
        try {
            $transaction->load(['consignment.store', 'consignment.product']);
            
            return $this->sendResponse(
                [
                    'id' => $transaction->id,
                    'consignment_id' => $transaction->consignment_id,
                    'transaction_date' => $transaction->transaction_date,
                    'total_sold' => $transaction->total_sold,
                    'total_returned' => $transaction->total_returned,
                    'net_quantity' => $transaction->net_quantity,
                    'total_amount' => $transaction->total_amount,
                    'notes' => $transaction->notes,
                    'sold_items_photo_path' => $transaction->sold_items_photo_path,
                    'returned_items_photo_path' => $transaction->returned_items_photo_path,
                    'created_at' => $transaction->created_at,
                    'updated_at' => $transaction->updated_at,
                    'items' => $transaction->items->map(function ($item) {
                        return [
                            'id' => $item->id,
                            'product_id' => $item->product_id,
                            'name' => $item->name,
                            'code' => $item->code,
                            'price' => $item->price,
                            'qty' => $item->qty,
                            'sold' => $item->sales,
                            'returned' => $item->return,
                        ];
                    }),
                    'consignment' => $transaction->consignment ? [
                        'id' => $transaction->consignment->id,
                        'store' => $transaction->consignment->store ? [
                            'id' => $transaction->consignment->store->id,
                            'name' => $transaction->consignment->store->name,
                            'address' => $transaction->consignment->store->address,
                            'phone' => $transaction->consignment->store->phone,
                        ] : null,
                        'status' => $transaction->consignment->status,
                        'notes' => $transaction->consignment->notes,
                    ] : null,
                ],
                'Data transaksi berhasil diambil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error getting transaction: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil data transaksi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Put(
     *     path="/api/transactions/{id}",
     *     operationId="updateTransaction",
     *     tags={"Transaksi"},
     *     summary="Memperbarui data transaksi",
     *     description="Memperbarui data transaksi yang sudah ada berdasarkan ID. Mendukung pembaruan foto barang terjual dan dikembalikan.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID transaksi yang akan diperbarui",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         description="Data transaksi yang akan diperbarui",
     *         @OA\MediaType(
     *             mediaType="multipart/form-data",
     *             @OA\Schema(
     *                 @OA\Property(property="consignment_id", type="integer", example=1, description="ID konsinyasi yang terkait"),
     *                 @OA\Property(property="transaction_date", type="string", format="date", example="2025-01-01", description="Tanggal transaksi (format: YYYY-MM-DD)"),
     *                 @OA\Property(property="sold_quantity", type="integer", example=5, description="Jumlah barang yang terjual"),
     *                 @OA\Property(property="returned_quantity", type="integer", example=0, description="Jumlah barang yang dikembalikan (opsional)"),
     *                 @OA\Property(property="notes", type="string", example="Catatan transaksi", nullable=true, description="Catatan tambahan (opsional)"),
     *                 @OA\Property(property="sold_items_photo", type="string", format="binary", description="Foto barang yang terjual (format: jpg,jpeg,png|max:2048)"),
     *                 @OA\Property(property="returned_items_photo", type="string", format="binary", description="Foto barang yang dikembalikan (format: jpg,jpeg,png|max:2048)")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Transaksi berhasil diperbarui",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1, description="ID transaksi"),
     *                 @OA\Property(property="consignment_id", type="integer", example=1, description="ID konsinyasi"),
     *                 @OA\Property(property="transaction_date", type="string", format="date-time", description="Tanggal transaksi"),
     *                 @OA\Property(property="sold_quantity", type="integer", example=5, description="Jumlah terjual"),
     *                 @OA\Property(property="returned_quantity", type="integer", example=0, description="Jumlah dikembalikan"),
     *                 @OA\Property(property="notes", type="string", nullable=true, example="Catatan transaksi"),
     *                 @OA\Property(property="sold_items_photo_path", type="string", nullable=true, example="transactions/sold/abc123.jpg"),
     *                 @OA\Property(property="returned_items_photo_path", type="string", nullable=true, example="transactions/returned/def456.jpg"),
     *                 @OA\Property(property="created_at", type="string", format="date-time"),
     *                 @OA\Property(property="updated_at", type="string", format="date-time"),
     *                 @OA\Property(property="consignment", type="object",
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="store", type="object",
     *                         @OA\Property(property="id", type="integer", example=1),
     *                         @OA\Property(property="name", type="string", example="Toko Baru")
     *                     ),
     *                     @OA\Property(property="product", type="object",
     *                         @OA\Property(property="id", type="integer", example=1),
     *                         @OA\Property(property="name", type="string", example="Produk A")
     *                     )
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string", example="Transaksi berhasil diperbarui"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=200)
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Permintaan tidak valid",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Data tidak valid"),
     *             @OA\Property(property="code", type="integer", example=400)
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Tidak terautentikasi",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Tidak terautentikasi"),
     *             @OA\Property(property="code", type="integer", example=401)
     *         )
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="Tidak diizinkan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk memperbarui transaksi ini"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Transaksi tidak ditemukan"),
     *             @OA\Property(property="code", type="integer", example=404)
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validasi gagal",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Validasi gagal"),
     *             @OA\Property(property="errors", type="object",
     *                 @OA\Property(property="consignment_id", type="array",
     *                     @OA\Items(type="string", example="Konsinyasi tidak valid")
     *                 ),
     *                 @OA\Property(property="sold_quantity", type="array",
     *                     @OA\Items(type="string", example="Jumlah terjual harus diisi")
     *                 )
     *             ),
     *             @OA\Property(property="code", type="integer", example=422)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat memperbarui transaksi"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function update(UpdateTransactionRequest $request, Transaction $transaction)
    {
        try {
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

            // If items provided, update ProductItem rows linked to this transaction
            if (isset($data['items']) && is_array($data['items'])) {
                foreach ($data['items'] as $item) {
                    $pi = \App\Models\ProductItem::find($item['product_item_id'] ?? null);
                    if (!$pi) continue;
                    if ($pi->transaction_id !== $transaction->id) {
                        // do not hijack items from other transactions
                        continue;
                    }
                    if (array_key_exists('sold', $item)) {
                        $pi->sales = (int) $item['sold'];
                    }
                    if (array_key_exists('returned', $item)) {
                        $pi->return = (int) $item['returned'];
                    }
                    if (array_key_exists('price', $item)) {
                        $pi->price = $item['price'];
                    }
                    $pi->save();
                }
            }

            // Update consignment status based on items
            $this->updateConsignmentStatus($transaction->consignment);

            $transaction->load('items');

            return $this->sendResponse(
                $transaction,
                'Transaksi berhasil diperbarui',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error updating transaction: ' . $e->getMessage());
            return $this->sendError(
                'Gagal memperbarui transaksi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
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
    /**
     * @OA\Delete(
     *     path="/api/transactions/{id}",
     *     operationId="deleteTransaction",
     *     tags={"Transaksi"},
     *     summary="Menghapus transaksi",
     *     description="Menghapus data transaksi berdasarkan ID. Jika transaksi memiliki foto terkait, foto tersebut juga akan dihapus dari penyimpanan.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID transaksi yang akan dihapus",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Transaksi berhasil dihapus",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object", example=null),
     *             @OA\Property(property="message", type="string", example="Transaksi berhasil dihapus"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=200)
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Tidak dapat menghapus transaksi",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Tidak dapat menghapus transaksi karena terkait dengan data lain"),
     *             @OA\Property(property="code", type="integer", example=400)
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Tidak terautentikasi",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Tidak terautentikasi"),
     *             @OA\Property(property="code", type="integer", example=401)
     *         )
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="Tidak diizinkan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk menghapus transaksi ini"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Transaksi tidak ditemukan"),
     *             @OA\Property(property="code", type="integer", example=404)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat menghapus transaksi"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function destroy(Transaction $transaction)
    {
        try {
            // Check if transaction has any related records that would prevent deletion
            // Add any additional checks here if needed in the future
            
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
            
            return $this->sendResponse(
                null,
                'Transaksi berhasil dihapus',
                HttpResponse::HTTP_OK
            );
            
        } catch (\Exception $e) {
            Log::error('Error deleting transaction: ' . $e->getMessage());
            return $this->sendError(
                'Gagal menghapus transaksi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
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
