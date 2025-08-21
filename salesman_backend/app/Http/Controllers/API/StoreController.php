<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreStoreRequest;
use App\Http\Requests\UpdateStoreRequest;
use App\Models\Store;
use App\Models\Consignment;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response as HttpResponse;

class StoreController extends BaseController
{
    /**
     * @OA\Get(
     *     path="/api/stores",
     *     operationId="getStoresList",
     *     tags={"Toko"},
     *     summary="Mendapatkan daftar toko",
     *     description="Mengembalikan daftar toko dengan paginasi dan pencarian",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="search",
     *         in="query",
     *         description="Kata kunci pencarian",
     *         required=false,
     *         @OA\Schema(type="string")
     *     ),
     *     @OA\Parameter(
     *         name="per_page",
     *         in="query",
     *         description="Jumlah item per halaman",
     *         required=false,
     *         @OA\Schema(type="integer", default=15, minimum=1, maximum=100)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Daftar toko berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="items", type="array",
     *                     @OA\Items(ref="#/components/schemas/Store")
     *                 ),
     *                 @OA\Property(property="pagination", type="object",
     *                     @OA\Property(property="total", type="integer", example=100),
     *                     @OA\Property(property="per_page", type="integer", example=15),
     *                     @OA\Property(property="current_page", type="integer", example=1),
     *                     @OA\Property(property="last_page", type="integer", example=7),
     *                     @OA\Property(property="from", type="integer", example=1),
     *                     @OA\Property(property="to", type="integer", example=15)
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string", example="Daftar toko berhasil diambil"),
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
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat mengambil daftar toko"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     *
     * @OA\Get(
     *     path="/api/stores/list",
     *     operationId="getStoresListAll",
     *     tags={"Toko"},
     *     summary="Mendapatkan daftar toko untuk dropdown",
     *     description="Mengembalikan daftar toko sederhana (hanya id dan nama) untuk keperluan dropdown",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Daftar toko berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="id", type="integer", example=1, description="ID toko"),
     *                     @OA\Property(property="name", type="string", example="Toko Baru", description="Nama toko")
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string", example="Daftar toko berhasil diambil"),
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
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat mengambil daftar toko"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function listAll()
    {
        try {
            $stores = Store::select('id', 'name')
                ->orderBy('name')
                ->get();
                
            return $this->sendResponse(
                $stores,
                'Daftar toko berhasil diambil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error fetching stores list: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil daftar toko',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    public function index(Request $request)
    {
        try {
            $search = $request->query('search');
            $perPage = $request->query('per_page', 15);

            $query = Store::query();

            if ($search) {
                $query->where(function($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                      ->orWhere('owner_name', 'like', "%{$search}%")
                      ->orWhere('phone', 'like', "%{$search}%");
                });
            }

            $stores = $query->latest()->paginate($perPage);
            
            // Format the paginated response data to match ProductController format
            $meta = [
                'current_page' => $stores->currentPage(),
                'total' => $stores->total(),
                'per_page' => $stores->perPage(),
                'last_page' => $stores->lastPage(),
                'from' => $stores->firstItem(),
                'to' => $stores->lastItem()
            ];

            return $this->sendResponse(
                $stores->items(),
                'Daftar toko berhasil diambil',
                HttpResponse::HTTP_OK,
                $meta
            );
            
        } catch (\Exception $e) {
            Log::error('Error fetching stores: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil daftar toko',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Post(
     *     path="/api/stores",
     *     operationId="storeStore",
     *     tags={"Toko"},
     *     summary="Membuat toko baru",
     *     description="Membuat data toko baru dengan informasi yang diberikan",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         description="Data toko yang akan dibuat",
     *         @OA\JsonContent(
     *             required={"name", "owner_name", "phone", "address"},
     *             @OA\Property(property="name", type="string", example="Toko Baru", description="Nama toko"),
     *             @OA\Property(property="owner_name", type="string", example="Nama Pemilik", description="Nama pemilik toko"),
     *             @OA\Property(property="phone", type="string", example="081234567890", description="Nomor telepon toko"),
     *             @OA\Property(property="address", type="string", example="Alamat lengkap toko", description="Alamat toko"),
     *             @OA\Property(property="photo", type="string", format="binary", description="Foto toko (format: jpg,jpeg,png|max:2048)")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Toko berhasil dibuat",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1, description="ID toko"),
     *                 @OA\Property(property="name", type="string", example="Toko Baru", description="Nama toko"),
     *                 @OA\Property(property="owner_name", type="string", example="Nama Pemilik", description="Nama pemilik toko"),
     *                 @OA\Property(property="phone", type="string", example="081234567890", description="Nomor telepon toko"),
     *                 @OA\Property(property="address", type="string", example="Alamat lengkap toko", description="Alamat toko"),
     *                 @OA\Property(property="photo_path", type="string", example="stores/abc123.jpg", nullable=true, description="Path foto toko"),
     *                 @OA\Property(property="created_at", type="string", format="date-time", description="Waktu dibuat"),
     *                 @OA\Property(property="updated_at", type="string", format="date-time", description="Waktu diperbarui")
     *             ),
     *             @OA\Property(property="message", type="string", example="Toko berhasil dibuat"),
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
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk membuat toko"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validasi gagal",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Validasi gagal"),
     *             @OA\Property(property="errors", type="object",
     *                 @OA\Property(property="name", type="array",
     *                     @OA\Items(type="string", example="Nama toko wajib diisi")
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
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat membuat toko"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     *
     * @OA\Get(
     *     path="/api/stores/{id}",
     *     operationId="getStoreById",
     *     tags={"Toko"},
     *     summary="Mendapatkan detail toko",
     *     description="Mengembalikan detail toko berdasarkan ID",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID toko",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Detail toko berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1, description="ID toko"),
     *                 @OA\Property(property="name", type="string", example="Toko Baru", description="Nama toko"),
     *                 @OA\Property(property="owner_name", type="string", example="Nama Pemilik", description="Nama pemilik toko"),
     *                 @OA\Property(property="phone", type="string", example="081234567890", description="Nomor telepon toko"),
     *                 @OA\Property(property="address", type="string", example="Alamat lengkap toko", description="Alamat toko"),
     *                 @OA\Property(property="photo_path", type="string", example="stores/abc123.jpg", nullable=true, description="Path foto toko"),
     *                 @OA\Property(property="created_at", type="string", format="date-time", description="Waktu dibuat"),
     *                 @OA\Property(property="updated_at", type="string", format="date-time", description="Waktu diperbarui")
     *             ),
     *             @OA\Property(property="message", type="string", example="Detail toko berhasil diambil"),
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
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk melihat detail toko"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Toko tidak ditemukan"),
     *             @OA\Property(property="code", type="integer", example=404)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat mengambil detail toko"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function store(StoreStoreRequest $request)
    {
        try {
            $data = $request->validated();

            if ($request->hasFile('photo')) {
                $data['photo_path'] = $request->file('photo')->store('stores', 'public');
            }

            $store = Store::create($data);
            
            // Format the response data
            $responseData = [
                'id' => $store->id,
                'name' => $store->name,
                'owner_name' => $store->owner_name,
                'phone' => $store->phone,
                'address' => $store->address,
                'photo_path' => $store->photo_path,
                'created_at' => $store->created_at,
                'updated_at' => $store->updated_at
            ];

            return $this->sendResponse(
                $responseData,
                'Toko berhasil dibuat',
                HttpResponse::HTTP_CREATED
            );
            
        } catch (\Exception $e) {
            Log::error('Error creating store: ' . $e->getMessage());
            return $this->sendError(
                'Gagal membuat toko',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Get(
     *     path="/api/stores/{id}",
     *     operationId="getStoreById",
     *     tags={"Stores"},
     *     summary="Get store details",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="Store ID",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Store retrieved successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Store"),
     *             @OA\Property(property="message", type="string", example="Store retrieved successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Store not found"
     *     )
     * )
     */
    public function show(Store $store)
    {
        try {
            // Format the response data
            $responseData = [
                'id' => $store->id,
                'name' => $store->name,
                'owner_name' => $store->owner_name,
                'phone' => $store->phone,
                'address' => $store->address,
                'photo_path' => $store->photo_path,
                'created_at' => $store->created_at,
                'updated_at' => $store->updated_at,
                'consignments_count' => $store->consignments_count ?? null,
                'transactions_count' => $store->transactions_count ?? null
            ];

            return $this->sendResponse(
                $responseData,
                'Detail toko berhasil diambil',
                HttpResponse::HTTP_OK
            );
            
        } catch (\Exception $e) {
            Log::error('Error fetching store details: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil detail toko',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Put(
     *     path="/api/stores/{id}",
     *     operationId="updateStore",
     *     tags={"Toko"},
     *     summary="Memperbarui data toko",
     *     description="Memperbarui data toko yang sudah ada",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID toko yang akan diperbarui",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         description="Data toko yang akan diperbarui",
     *         @OA\JsonContent(
     *             @OA\Property(property="name", type="string", example="Toko Baru", description="Nama toko"),
     *             @OA\Property(property="owner_name", type="string", example="Nama Pemilik", description="Nama pemilik toko"),
     *             @OA\Property(property="phone", type="string", example="081234567890", description="Nomor telepon toko"),
     *             @OA\Property(property="address", type="string", example="Alamat lengkap toko", description="Alamat toko"),
     *             @OA\Property(property="photo", type="string", format="binary", description="Foto toko (format: jpg,jpeg,png|max:2048)")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Toko berhasil diperbarui",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1, description="ID toko"),
     *                 @OA\Property(property="name", type="string", example="Toko Baru", description="Nama toko"),
     *                 @OA\Property(property="owner_name", type="string", example="Nama Pemilik", description="Nama pemilik toko"),
     *                 @OA\Property(property="phone", type="string", example="081234567890", description="Nomor telepon toko"),
     *                 @OA\Property(property="address", type="string", example="Alamat lengkap toko", description="Alamat toko"),
     *                 @OA\Property(property="photo_path", type="string", example="stores/abc123.jpg", nullable=true, description="Path foto toko"),
     *                 @OA\Property(property="created_at", type="string", format="date-time", description="Waktu dibuat"),
     *                 @OA\Property(property="updated_at", type="string", format="date-time", description="Waktu diperbarui")
     *             ),
     *             @OA\Property(property="message", type="string", example="Toko berhasil diperbarui"),
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
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk memperbarui toko"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Toko tidak ditemukan"),
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
     *                 @OA\Property(property="name", type="array",
     *                     @OA\Items(type="string", example="Nama toko wajib diisi")
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
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat memperbarui toko"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function update(UpdateStoreRequest $request, Store $store)
    {
        try {
            $data = $request->validated();

            if ($request->hasFile('photo')) {
                // Delete old photo if exists
                if ($store->photo_path) {
                    Storage::disk('public')->delete($store->photo_path);
                }
                $data['photo_path'] = $request->file('photo')->store('stores', 'public');
            }

            $store->update($data);
            
            // Format the response data
            $responseData = [
                'id' => $store->id,
                'name' => $store->name,
                'owner_name' => $store->owner_name,
                'phone' => $store->phone,
                'address' => $store->address,
                'photo_path' => $store->photo_path,
                'created_at' => $store->created_at,
                'updated_at' => $store->updated_at
            ];

            return $this->sendResponse(
                $responseData,
                'Toko berhasil diperbarui',
                HttpResponse::HTTP_OK
            );
            
        } catch (\Exception $e) {
            Log::error('Error updating store: ' . $e->getMessage());
            return $this->sendError(
                'Gagal memperbarui toko',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Delete(
     *     path="/api/stores/{id}",
     *     operationId="deleteStore",
     *     tags={"Toko"},
     *     summary="Menghapus toko",
     *     description="Menghapus data toko berdasarkan ID. Toko tidak dapat dihapus jika memiliki riwayat konsinyasi atau transaksi.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID toko yang akan dihapus",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Toko berhasil dihapus",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="null", example=null, description="Data selalu null saat penghapusan berhasil"),
     *             @OA\Property(property="message", type="string", example="Toko berhasil dihapus"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=200)
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Tidak dapat menghapus toko",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Tidak dapat menghapus toko yang memiliki riwayat transaksi"),
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
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk menghapus toko"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Toko tidak ditemukan"),
     *             @OA\Property(property="code", type="integer", example=404)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat menghapus toko"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function destroy(Store $store)
    {
        try {
            // Check if store has related consignments
            $hasConsignments = Consignment::where('store_id', $store->id)->exists();
            if ($hasConsignments) {
                return $this->sendError(
                    'Tidak dapat menghapus toko yang memiliki riwayat konsinyasi',
                    null,
                    HttpResponse::HTTP_BAD_REQUEST
                );
            }

            // Check if store has related transactions
            $hasTransactions = Transaction::whereHas('consignment', function($q) use ($store) {
                $q->where('store_id', $store->id);
            })->exists();

            if ($hasTransactions) {
                return $this->sendError(
                    'Tidak dapat menghapus toko yang memiliki riwayat transaksi',
                    null,
                    HttpResponse::HTTP_BAD_REQUEST
                );
            }

            // Delete store photo if exists
            if ($store->photo_path) {
                Storage::disk('public')->delete($store->photo_path);
            }

            $store->delete();

            return $this->sendResponse(
                null,
                'Toko berhasil dihapus',
                HttpResponse::HTTP_OK
            );
            
        } catch (\Exception $e) {
            Log::error('Error deleting store: ' . $e->getMessage());
            return $this->sendError(
                'Gagal menghapus toko',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}
