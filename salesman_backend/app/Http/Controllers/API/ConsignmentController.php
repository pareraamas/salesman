<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreConsignmentRequest;
use App\Http\Requests\UpdateConsignmentRequest;
use App\Models\Consignment;
use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response as HttpResponse;

class ConsignmentController extends BaseController
{
    /**
     * @OA\Get(
     *     path="/api/consignments",
     *     operationId="getConsignmentsList",
     *     tags={"Konsinyasi"},
     *     summary="Mendapatkan daftar konsinyasi dengan filter opsional",
     *     description="Mengembalikan daftar konsinyasi dengan paginasi dan filter yang tersedia",
     *     security={{"bearerAuth":{}}},
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
     *         name="status",
     *         in="query",
     *         description="Filter berdasarkan status (active, sold, returned)",
     *         required=false,
     *         @OA\Schema(type="string", enum={"active", "sold", "returned"}, example="active")
     *     ),
     *     @OA\Parameter(
     *         name="from_date",
     *         in="query",
     *         description="Filter dari tanggal konsinyasi (format: YYYY-MM-DD)",
     *         required=false,
     *         @OA\Schema(type="string", format="date", example="2025-01-01")
     *     ),
     *     @OA\Parameter(
     *         name="to_date",
     *         in="query",
     *         description="Filter sampai tanggal konsinyasi (format: YYYY-MM-DD)",
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
     *         description="Sukses mendapatkan daftar konsinyasi",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array",
     *                 @OA\Items(ref="#/components/schemas/Consignment")
     *             ),
     *             @OA\Property(property="meta", type="object",
     *                 @OA\Property(property="current_page", type="integer", example=1),
     *                 @OA\Property(property="from", type="integer", example=1),
     *                 @OA\Property(property="last_page", type="integer", example=1),
     *                 @OA\Property(property="path", type="string", example="http://localhost/api/consignments"),
     *                 @OA\Property(property="per_page", type="integer", example=15),
     *                 @OA\Property(property="to", type="integer", example=10),
     *                 @OA\Property(property="total", type="integer", example=10)
     *             ),
     *             @OA\Property(property="message", type="string", example="Daftar konsinyasi berhasil diambil"),
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
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan server"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    /**
     * @OA\Get(
     *     path="/api/consignments/list",
     *     operationId="getConsignmentsListAll",
     *     tags={"Konsinyasi"},
     *     summary="Mendapatkan daftar semua konsinyasi untuk dropdown",
     *     description="Mengembalikan daftar konsinyasi dalam format yang sesuai untuk dropdown",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Sukses mendapatkan daftar konsinyasi",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="code", type="string", example="CNS-001"),
     *                     @OA\Property(property="store_name", type="string", example="Toko Baru"),
     *                     @OA\Property(property="product_name", type="string", example="Nama Produk")
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string", example="Daftar konsinyasi berhasil diambil"),
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
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan server"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function listAll()
    {
        try {
            $consignments = Consignment::select('id', 'code', 'store_id')
                ->with(['store:id,name', 'productItems.product:id,name'])
                ->orderBy('code')
                ->get()
                ->map(function ($consignment) {
                    $productNames = $consignment->productItems
                        ->pluck('product.name')
                        ->filter()
                        ->unique()
                        ->values()
                        ->join(', ');

                    return [
                        'id' => $consignment->id,
                        'code' => $consignment->code,
                        'store_name' => optional($consignment->store)->name,
                        'products' => $productNames,
                    ];
                });

            return $this->sendResponse(
                $consignments,
                'Daftar konsinyasi berhasil diambil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error retrieving consignments list: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil daftar konsinyasi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    public function index(Request $request)
    {
        try {
            $query = Consignment::with(['store', 'productItems.product']);

            // Apply filters
            if ($request->has('store_id')) {
                $query->where('store_id', $request->store_id);
            }

            // Removed product_id direct filter; filter via related product items instead
            if ($request->has('product_id')) {
                $productId = $request->product_id;
                $query->whereHas('productItems', function ($q) use ($productId) {
                    $q->where('product_id', $productId);
                });
            }

            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            if ($request->has('from_date')) {
                $query->whereDate('consignment_date', '>=', $request->from_date);
            }

            if ($request->has('to_date')) {
                $query->whereDate('consignment_date', '<=', $request->to_date);
            }

            $perPage = $request->input('per_page', 15);
            $consignments = $query->latest('consignment_date')->paginate($perPage);

            return $this->sendResponse(
                $consignments,
                'Daftar konsinyasi berhasil diambil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error retrieving consignments: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil daftar konsinyasi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Get(
     *     path="/api/consignments/active",
     *     tags={"Konsinyasi"},
     *     summary="Daftar konsinyasi aktif",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="OK")
     * )
     */
    public function active(Request $request)
    {
        try {
            $perPage = $request->input('per_page', 15);
            $data = Consignment::active()
                ->with(['store', 'productItems.product'])
                ->latest('consignment_date')
                ->paginate($perPage);

            return $this->sendResponse($data, 'Daftar konsinyasi aktif berhasil diambil');
        } catch (\Exception $e) {
            Log::error('Error retrieving active consignments: ' . $e->getMessage());
            return $this->sendError('Gagal mengambil konsinyasi aktif', null, HttpResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * @OA\Get(
     *     path="/api/consignments/{id}/transactions",
     *     tags={"Konsinyasi"},
     *     summary="Daftar transaksi untuk konsinyasi tertentu",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="OK")
     * )
     */
    public function transactions(Request $request, Consignment $consignment)
    {
        try {
            $perPage = $request->input('per_page', 15);
            $transactions = $consignment->transactions()
                ->with('items')
                ->latest('transaction_date')
                ->paginate($perPage);

            return $this->sendResponse($transactions, 'Daftar transaksi konsinyasi berhasil diambil');
        } catch (\Exception $e) {
            Log::error('Error retrieving consignment transactions: ' . $e->getMessage());
            return $this->sendError('Gagal mengambil daftar transaksi', null, HttpResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * @OA\Post(
     *     path="/api/consignments",
     *     operationId="storeConsignment",
     *     tags={"Konsinyasi"},
     *     summary="Membuat data konsinyasi baru",
     *     description="Membuat data konsinyasi baru dengan data yang diberikan",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         description="Data konsinyasi yang akan dibuat",
     *         @OA\JsonContent(ref="#/components/schemas/ConsignmentInput")
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Data konsinyasi berhasil dibuat",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Consignment"),
     *             @OA\Property(property="message", type="string", example="Data konsinyasi berhasil dibuat"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=201)
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
     *         response=422,
     *         description="Validasi gagal",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Validasi gagal"),
     *             @OA\Property(property="errors", type="object",
     *                 @OA\Property(property="store_id", type="array",
     *                     @OA\Items(type="string", example="The store id field is required.")
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
     *             @OA\Property(property="message", type="string", example="Gagal menyimpan data konsinyasi"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function store(StoreConsignmentRequest $request)
    {
        try {
            $data = $request->validated();

            // Handle photo upload
            if ($request->hasFile('photo')) {
                try {
                    $data['photo_path'] = $request->file('photo')->store('consignments', 'public');
                } catch (\Exception $e) {
                    Log::error('Error uploading consignment photo: ' . $e->getMessage());
                    return $this->sendError(
                        'Gagal mengunggah foto konsinyasi',
                        null,
                        HttpResponse::HTTP_INTERNAL_SERVER_ERROR
                    );
                }
            }

            $productItemsPayload = $data['productItems'] ?? [];
            unset($data['productItems']);

            $consignment = Consignment::create($data);

            // Create product items
            foreach ($productItemsPayload as $item) {
                \App\Models\ProductItem::create([
                    'product_id' => $item['product_id'],
                    'consignment_id' => $consignment->id,
                    'name' => $item['name'],
                    'code' => $item['code'],
                    'price' => $item['price'],
                    'qty' => $item['qty'],
                    'description' => $item['description'] ?? null,
                    'sales' => 0,
                    'return' => 0,
                ]);
            }

            $consignment->load(['store', 'productItems.product']);

            return $this->sendResponse(
                $consignment,
                'Konsinyasi berhasil dibuat',
                HttpResponse::HTTP_CREATED
            );
        } catch (\Exception $e) {
            Log::error('Error creating consignment: ' . $e->getMessage());

            // Hapus foto yang sudah diupload jika terjadi error
            if (isset($data['photo_path']) && Storage::disk('public')->exists($data['photo_path'])) {
                Storage::disk('public')->delete($data['photo_path']);
            }

            return $this->sendError(
                'Gagal membuat konsinyasi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Get(
     *     path="/api/consignments/{id}",
     *     operationId="getConsignmentById",
     *     tags={"Konsinyasi"},
     *     summary="Mendapatkan detail konsinyasi",
     *     description="Mengembalikan detail konsinyasi berdasarkan ID",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID konsinyasi",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Sukses mendapatkan detail konsinyasi",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Consignment"),
     *             @OA\Property(property="message", type="string", example="Detail konsinyasi berhasil diambil"),
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
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Data konsinyasi tidak ditemukan"),
     *             @OA\Property(property="code", type="integer", example=404)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan server"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function show(Consignment $consignment)
    {
        try {
            $consignment->load(['store', 'product', 'transactions']);
            return $this->sendResponse(
                $consignment,
                'Detail konsinyasi berhasil diambil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error retrieving consignment details: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil detail konsinyasi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Put(
     *     path="/api/consignments/{id}",
     *     operationId="updateConsignment",
     *     tags={"Konsinyasi"},
     *     summary="Memperbarui data konsinyasi",
     *     description="Memperbarui data konsinyasi berdasarkan ID dengan data yang diberikan",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID konsinyasi yang akan diperbarui",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         description="Data konsinyasi yang akan diperbarui",
     *         @OA\JsonContent(ref="#/components/schemas/ConsignmentInput")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Data konsinyasi berhasil diperbarui",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Consignment"),
     *             @OA\Property(property="message", type="string", example="Data konsinyasi berhasil diperbarui"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=200)
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Permintaan tidak valid",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Permintaan tidak valid"),
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
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Data konsinyasi tidak ditemukan"),
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
     *                 @OA\Property(property="store_id", type="array",
     *                     @OA\Items(type="string", example="The store id field is required.")
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
     *             @OA\Property(property="message", type="string", example="Gagal memperbarui data konsinyasi"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function update(UpdateConsignmentRequest $request, Consignment $consignment)
    {
        try {
            $data = $request->validated();
            $productItemsPayload = $data['productItems'] ?? null;
            unset($data['productItems']);
            $oldPhotoPath = null;

            // Handle photo upload
            if ($request->hasFile('photo')) {
                try {
                    // Simpan path foto lama untuk dihapus nanti jika update berhasil
                    if ($consignment->photo_path) {
                        $oldPhotoPath = $consignment->photo_path;
                    }
                    $data['photo_path'] = $request->file('photo')->store('consignments', 'public');
                } catch (\Exception $e) {
                    Log::error('Error updating consignment photo: ' . $e->getMessage());
                    return $this->sendError(
                        'Gagal mengunggah foto konsinyasi',
                        null,
                        HttpResponse::HTTP_INTERNAL_SERVER_ERROR
                    );
                }
            }

            $consignment->update($data);

            // Upsert product items if provided
            if (is_array($productItemsPayload)) {
                foreach ($productItemsPayload as $item) {
                    if (!empty($item['id'])) {
                        $pi = \App\Models\ProductItem::where('id', $item['id'])
                            ->where('consignment_id', $consignment->id)
                            ->first();
                        if ($pi) {
                            $pi->update([
                                'product_id' => $item['product_id'] ?? $pi->product_id,
                                'name' => $item['name'] ?? $pi->name,
                                'code' => $item['code'] ?? $pi->code,
                                'price' => $item['price'] ?? $pi->price,
                                'qty' => $item['qty'] ?? $pi->qty,
                                'description' => $item['description'] ?? $pi->description,
                            ]);
                        }
                    } else {
                        \App\Models\ProductItem::create([
                            'product_id' => $item['product_id'],
                            'consignment_id' => $consignment->id,
                            'name' => $item['name'],
                            'code' => $item['code'],
                            'price' => $item['price'],
                            'qty' => $item['qty'],
                            'description' => $item['description'] ?? null,
                            'sales' => 0,
                            'return' => 0,
                        ]);
                    }
                }
            }

            $consignment->load(['store', 'productItems.product']);

            // Hapus foto lama setelah update berhasil
            if ($oldPhotoPath) {
                Storage::disk('public')->delete($oldPhotoPath);
            }

            return $this->sendResponse(
                $consignment,
                'Data konsinyasi berhasil diperbarui',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error updating consignment: ' . $e->getMessage());

            // Hapus foto baru yang sudah diupload jika terjadi error
            if (isset($data['photo_path']) && Storage::disk('public')->exists($data['photo_path'])) {
                Storage::disk('public')->delete($data['photo_path']);
            }

            return $this->sendError(
                'Gagal memperbarui data konsinyasi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
    
    /**
     * @OA\Delete(
     *     path="/api/consignments/{id}",
     *     operationId="deleteConsignment",
     *     tags={"Konsinyasi"},
     *     summary="Menghapus data konsinyasi",
     *     description="Menghapus data konsinyasi berdasarkan ID",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID konsinyasi yang akan dihapus",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Data konsinyasi berhasil dihapus",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object", example=null),
     *             @OA\Property(property="message", type="string", example="Data konsinyasi berhasil dihapus"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=200)
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Tidak dapat menghapus data",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Tidak dapat menghapus data konsinyasi karena sudah memiliki transaksi terkait"),
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
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk menghapus data ini"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Data konsinyasi tidak ditemukan"),
     *             @OA\Property(property="code", type="integer", example=404)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Gagal menghapus data konsinyasi"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function destroy(Consignment $consignment)
    {
        try {
            // Check if consignment has related transactions
            $hasTransactions = $consignment->transactions()->exists();

            if ($hasTransactions) {
                return $this->sendError(
                    'Tidak dapat menghapus konsinyasi yang memiliki riwayat transaksi',
                    null,
                    HttpResponse::HTTP_BAD_REQUEST
                );
            }

            // Delete photo if exists
            if ($consignment->photo_path && Storage::disk('public')->exists($consignment->photo_path)) {
                try {
                    Storage::disk('public')->delete($consignment->photo_path);
                } catch (\Exception $e) {
                    Log::error('Error deleting consignment photo: ' . $e->getMessage());
                    // Continue with deletion even if photo deletion fails
                }
            }

            $consignment->delete();

            return $this->sendResponse(
                null,
                'Konsinyasi berhasil dihapus',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error deleting consignment: ' . $e->getMessage());
            return $this->sendError(
                'Gagal menghapus konsinyasi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Post(
     *     path="/api/consignments/{id}/update-status",
     *     operationId="updateConsignmentStatus",
     *     tags={"Konsinyasi"},
     *     summary="Memperbarui status konsinyasi (terjual/dikembalikan)",
     *     description="Memperbarui status konsinyasi menjadi terjual atau dikembalikan dengan kuantitas yang ditentukan",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID konsinyasi yang akan diperbarui statusnya",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         description="Data pembaruan status konsinyasi",
     *         @OA\JsonContent(
     *             required={"status", "sold_quantity", "returned_quantity"},
     *             @OA\Property(property="status", type="string", enum={"sold", "returned"}, example="sold", description="Status baru konsinyasi (sold/returned)"),
     *             @OA\Property(property="sold_quantity", type="integer", minimum=0, example=5, description="Jumlah barang yang terjual"),
     *             @OA\Property(property="returned_quantity", type="integer", minimum=0, example=0, description="Jumlah barang yang dikembalikan"),
     *             @OA\Property(property="notes", type="string", example="Pembayaran lunas", nullable=true, description="Catatan tambahan")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Status konsinyasi berhasil diperbarui",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Consignment"),
     *             @OA\Property(property="message", type="string", example="Status konsinyasi berhasil diperbarui"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=200)
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Permintaan tidak valid",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Jumlah terjual melebihi stok yang tersedia"),
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
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk memperbarui status konsinyasi ini"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Data konsinyasi tidak ditemukan"),
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
     *                 @OA\Property(property="status", type="array",
     *                     @OA\Items(type="string", example="The selected status is invalid.")
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
     *             @OA\Property(property="message", type="string", example="Gagal memperbarui status konsinyasi"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    /**
     * @OA\Get(
     *     path="/api/consignments/{id}/product-items",
     *     operationId="getConsignmentProductItems",
     *     tags={"Konsinyasi"},
     *     summary="Mendapatkan daftar item produk untuk konsinyasi",
     *     description="Mengembalikan daftar item produk yang tersedia untuk konsinyasi tertentu",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID konsinyasi",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Sukses mendapatkan daftar item produk",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="product_id", type="integer", example=1),
     *                     @OA\Property(property="product_name", type="string", example="Nama Produk"),
     *                     @OA\Property(property="code", type="string", example="PRD-001"),
     *                     @OA\Property(property="price", type="number", format="float", example=100000),
     *                     @OA\Property(property="status", type="string", example="available"),
     *                     @OA\Property(property="created_at", type="string", format="date-time"),
     *                     @OA\Property(property="updated_at", type="string", format="date-time")
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string", example="Daftar item produk berhasil diambil"),
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
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Data konsinyasi tidak ditemukan"),
     *             @OA\Property(property="code", type="integer", example=404)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Gagal mengambil daftar item produk"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function productItems(Consignment $consignment)
    {
        try {
            $items = $consignment->productItems()
                ->with(['product'])
                ->whereNull('transaction_id') // Only get items that haven't been transacted yet
                ->get()
                ->map(function ($item) {
                    return [
                        'id' => $item->id,
                        'product_id' => $item->product_id,
                        'product_name' => $item->product ? $item->product->name : null,
                        'code' => $item->code,
                        'price' => $item->price,
                        'status' => $item->status,
                        'created_at' => $item->created_at,
                        'updated_at' => $item->updated_at,
                    ];
                });

            return $this->sendResponse(
                $items,
                'Daftar item produk berhasil diambil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error getting consignment product items: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil daftar item produk',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    public function updateStatus(Request $request, Consignment $consignment)
    {
        try {
            $validated = $request->validate([
                'status' => 'required|in:sold,returned',
                'sold_quantity' => 'required|integer|min:0',
                'returned_quantity' => 'required|integer|min:0',
                'notes' => 'nullable|string|max:1000',
            ]);

            // Check if total sold + returned doesn't exceed the original quantity
            $total = $validated['sold_quantity'] + $validated['returned_quantity'];
            if ($total > $consignment->quantity) {
                return $this->sendError(
                    'Total jumlah terjual dan dikembalikan melebihi jumlah awal (' . $consignment->quantity . ')',
                    null,
                    HttpResponse::HTTP_BAD_REQUEST
                );
            }

            // Start database transaction
            DB::beginTransaction();

            try {
                // Update consignment status
                $consignment->update(['status' => $validated['status']]);

                // Create transaction record
                $consignment->transactions()->create([
                    'sold_quantity' => $validated['sold_quantity'],
                    'returned_quantity' => $validated['returned_quantity'],
                    'transaction_date' => now(),
                    'notes' => $validated['notes'] ?? null,
                ]);

                // Reload relationships
                $consignment->load(['store', 'product', 'transactions']);

                DB::commit();

                return $this->sendResponse(
                    $consignment,
                    'Status konsinyasi berhasil diperbarui',
                    HttpResponse::HTTP_OK
                );
            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }
        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::error('Validation error updating consignment status: ' . $e->getMessage());
            return $this->sendError(
                'Validasi gagal: ' . $e->getMessage(),
                $e->errors(),
                HttpResponse::HTTP_UNPROCESSABLE_ENTITY
            );
        } catch (\Exception $e) {
            Log::error('Error updating consignment status: ' . $e->getMessage());
            return $this->sendError(
                'Gagal memperbarui status konsinyasi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}
