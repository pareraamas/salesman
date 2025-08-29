<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreProductRequest;
use App\Http\Requests\UpdateProductRequest;
use App\Models\Product;
use App\Models\Consignment;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response as HttpResponse;

class ProductController extends BaseController
{
    /**
     * @OA\Get(
     *     path="/api/products",
     *     operationId="getProductsList",
     *     tags={"Produk"},
     *     summary="Mendapatkan daftar produk",
     *     description="Mengembalikan daftar produk dengan paginasi dan pencarian",
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
     *         description="Daftar produk berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array",
     *                 @OA\Items(ref="#/components/schemas/Product")
     *             ),
     *             @OA\Property(property="message", type="string", example="Daftar produk berhasil diambil"),
     *             @OA\Property(property="meta", type="object",
     *                 @OA\Property(property="current_page", type="integer", example=1),
     *                 @OA\Property(property="total", type="integer", example=100),
     *                 @OA\Property(property="per_page", type="integer", example=15),
     *                 @OA\Property(property="last_page", type="integer", example=7)
     *             ),
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
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat mengambil data produk"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    /**
     * @OA\Get(
     *     path="/api/products/list",
     *     operationId="getProductsListAll",
     *     tags={"Produk"},
     *     summary="Mendapatkan daftar produk untuk dropdown",
     *     description="Mengembalikan daftar produk sederhana (hanya id, nama, dan kode) untuk keperluan dropdown",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Daftar produk berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="id", type="integer", example=1, description="ID produk"),
     *                     @OA\Property(property="name", type="string", example="Nama Produk", description="Nama produk"),
     *                     @OA\Property(property="code", type="string", example="PRD-001", description="Kode produk")
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string", example="Daftar produk berhasil diambil"),
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
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat mengambil daftar produk"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function listAll()
    {
        try {
            $products = Product::select('id', 'name', 'code')
                ->orderBy('name')
                ->get();

            return $this->sendResponse(
                $products,
                'Daftar produk berhasil diambil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error getting product list: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil daftar produk',
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

            $query = Product::query();

            if ($search) {
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                        ->orWhere('code', 'like', "%{$search}%")
                        ->orWhere('description', 'like', "%{$search}%");
                });
            }

            $products = $query->latest()->paginate($perPage);

            return $this->sendResponse(
                $products,
                'Daftar produk berhasil diambil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error getting product list: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil daftar produk',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Post(
     *     path="/api/products",
     *     operationId="storeProduct",
     *     tags={"Produk"},
     *     summary="Membuat produk baru",
     *     description="Membuat data produk baru dengan informasi yang diberikan",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         description="Data produk yang akan dibuat",
     *         @OA\JsonContent(ref="#/components/schemas/ProductInput")
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Produk berhasil dibuat",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Product"),
     *             @OA\Property(property="message", type="string", example="Produk berhasil dibuat"),
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
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk membuat produk"),
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
     *                     @OA\Items(type="string", example="Nama produk wajib diisi")
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
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat membuat produk"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function store(StoreProductRequest $request)
    {
        try {
            $data = $request->validated();

            if ($request->hasFile('photo')) {
                $data['photo_path'] = $request->file('photo')->store('products', 'public');
            }

            $product = Product::create($data);

            return $this->sendResponse(
                $product,
                'Produk berhasil ditambahkan',
                HttpResponse::HTTP_CREATED
            );
        } catch (\Exception $e) {
            Log::error('Error creating product: ' . $e->getMessage());

            // Hapus file yang sudah diupload jika terjadi error
            if (isset($data['photo_path']) && Storage::disk('public')->exists($data['photo_path'])) {
                Storage::disk('public')->delete($data['photo_path']);
            }

            return $this->sendError(
                'Gagal menambahkan produk',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Get(
     *     path="/api/products/{id}",
     *     operationId="getProductById",
     *     tags={"Produk"},
     *     summary="Mendapatkan detail produk",
     *     description="Mengembalikan detail produk berdasarkan ID",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         description="ID produk",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Detail produk berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Product"),
     *             @OA\Property(property="message", type="string", example="Detail produk berhasil diambil"),
     *             @OA\Property(property="code", type="integer", example=200)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Produk tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Produk tidak ditemukan"),
     *             @OA\Property(property="code", type="integer", example=404)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat mengambil detail produk"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function show(Product $product)
    {
        try {
            // Eager load relationships if needed

            return $this->sendResponse($product, 'Detail produk berhasil diambil');
        } catch (\Exception $e) {
            Log::error('Error getting product details: ' . $e->getMessage());
            return $this->sendError(
                'Terjadi kesalahan saat mengambil detail produk',
                [],
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Put(
     *     path="/api/products/{id}",
     *     operationId="updateProduct",
     *     tags={"Produk"},
     *     summary="Memperbarui data produk",
     *     description="Memperbarui data produk yang sudah ada",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID produk yang akan diperbarui",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         description="Data produk yang akan diperbarui",
     *         @OA\JsonContent(ref="#/components/schemas/ProductInput")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Produk berhasil diperbarui",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Product"),
     *             @OA\Property(property="message", type="string", example="Produk berhasil diperbarui"),
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
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk memperbarui produk"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Produk tidak ditemukan"),
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
     *                     @OA\Items(type="string", example="Nama produk wajib diisi")
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
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat memperbarui produk"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function update(UpdateProductRequest $request, Product $product)
    {
        try {
            $data = $request->validated();
            $oldPhotoPath = null;

            if ($request->hasFile('photo')) {
                // Simpan path foto lama untuk dihapus nanti jika update berhasil
                if ($product->photo_path) {
                    $oldPhotoPath = $product->photo_path;
                }
                $data['photo_path'] = $request->file('photo')->store('products', 'public');
            }

            $product->update($data);

            // Hapus foto lama setelah update berhasil
            if ($oldPhotoPath) {
                Storage::disk('public')->delete($oldPhotoPath);
            }

            return $this->sendResponse(
                $product,
                'Produk berhasil diperbarui',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error updating product: ' . $e->getMessage());

            // Hapus foto baru yang sudah diupload jika terjadi error
            if (isset($data['photo_path']) && Storage::disk('public')->exists($data['photo_path'])) {
                Storage::disk('public')->delete($data['photo_path']);
            }

            return $this->sendError(
                'Gagal memperbarui produk',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Delete(
     *     path="/api/products/{id}",
     *     operationId="deleteProduct",
     *     tags={"Produk"},
     *     summary="Menghapus produk",
     *     description="Menghapus data produk berdasarkan ID. Produk tidak dapat dihapus jika memiliki riwayat konsinyasi atau transaksi.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID produk yang akan dihapus",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Produk berhasil dihapus",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="null", example=null),
     *             @OA\Property(property="message", type="string", example="Produk berhasil dihapus"),
     *             @OA\Property(property="meta", type="object", example=null),
     *             @OA\Property(property="code", type="integer", example=200)
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Tidak dapat menghapus produk",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Tidak dapat menghapus produk yang memiliki riwayat transaksi"),
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
     *             @OA\Property(property="message", type="string", example="Anda tidak memiliki izin untuk menghapus produk"),
     *             @OA\Property(property="code", type="integer", example=403)
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Produk tidak ditemukan"),
     *             @OA\Property(property="code", type="integer", example=404)
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Kesalahan server",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Terjadi kesalahan saat menghapus produk"),
     *             @OA\Property(property="code", type="integer", example=500)
     *         )
     *     )
     * )
     */
    public function destroy(Product $product)
    {
        try {
            // Prevent delete if product used in any consignment items or transaction items
            $usedInConsignments = \App\Models\ProductItem::where('product_id', $product->id)
                ->whereNull('transaction_id')
                ->exists();

            $usedInTransactions = \App\Models\ProductItem::where('product_id', $product->id)
                ->whereNotNull('transaction_id')
                ->exists();

            if ($usedInConsignments || $usedInTransactions) {
                return $this->sendError(
                    'Tidak dapat menghapus produk yang telah digunakan pada konsinyasi atau transaksi',
                    null,
                    HttpResponse::HTTP_BAD_REQUEST
                );
            }

            // Delete product photo if exists
            if ($product->photo_path && Storage::disk('public')->exists($product->photo_path)) {
                Storage::disk('public')->delete($product->photo_path);
            }

            $product->delete();

            return $this->sendResponse(
                null,
                'Produk berhasil dihapus',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Error deleting product: ' . $e->getMessage());
            return $this->sendError(
                'Gagal menghapus produk',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}
