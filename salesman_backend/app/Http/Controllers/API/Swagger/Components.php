<?php

namespace App\Http\Controllers\API\Swagger;

/**
 * @OA\Components(
 *     @OA\Schema(
 *         schema="Pagination",
 *         @OA\Property(property="current_page", type="integer", example=1),
 *         @OA\Property(property="data", type="array", @OA\Items(type="object")),
 *         @OA\Property(property="first_page_url", type="string", example="http://example.com?page=1"),
 *         @OA\Property(property="from", type="integer", example=1),
 *         @OA\Property(property="last_page", type="integer", example=1),
 *         @OA\Property(property="last_page_url", type="string", example="http://example.com?page=1"),
 *         @OA\Property(property="links", type="array", @OA\Items(type="object")),
 *         @OA\Property(property="next_page_url", type="string", nullable=true, example=null),
 *         @OA\Property(property="path", type="string", example="http://example.com"),
 *         @OA\Property(property="per_page", type="integer", example=15),
 *         @OA\Property(property="prev_page_url", type="string", nullable=true, example=null),
 *         @OA\Property(property="to", type="integer", example=10),
 *         @OA\Property(property="total", type="integer", example=10)
 *     ),
 *     @OA\Schema(
 *         schema="SuccessResponse",
 *         @OA\Property(property="success", type="boolean", example=true),
 *         @OA\Property(property="data", type="object"),
 *         @OA\Property(property="message", type="string", example="Operation completed successfully")
 *     ),
 *     @OA\Schema(
 *         schema="ErrorResponse",
 *         @OA\Property(property="success", type="boolean", example=false),
 *         @OA\Property(property="message", type="string", example="Error message"),
 *         @OA\Property(
 *             property="errors", 
 *             type="object",
 *             @OA\Property(
 *                 property="field",
 *                 type="array",
 *                 @OA\Items(type="string", example="Error message")
 *             )
 *         )
 *     ),
 *     @OA\Schema(
 *         schema="Store",
 *         @OA\Property(property="id", type="integer", example=1),
 *         @OA\Property(property="name", type="string", example="Toko Maju Jaya"),
 *         @OA\Property(property="address", type="string", example="Jl. Contoh No. 123"),
 *         @OA\Property(property="phone", type="string", example="081234567890"),
 *         @OA\Property(property="owner_name", type="string", example="Budi Santoso"),
 *         @OA\Property(property="latitude", type="number", format="float", example=-6.200000),
 *         @OA\Property(property="longitude", type="number", format="float", example=106.816666),
 *         @OA\Property(property="photo_path", type="string", example="stores/photo.jpg"),
 *         @OA\Property(property="photo_url", type="string", example="http://example.com/storage/stores/photo.jpg"),
 *         @OA\Property(property="created_at", type="string", format="date-time"),
 *         @OA\Property(property="updated_at", type="string", format="date-time")
 *     ),
 *     @OA\Schema(
 *         schema="StoreInput",
 *         required={"name", "address", "phone", "owner_name"},
 *         @OA\Property(property="name", type="string", example="Toko Maju Jaya", maxLength=255),
 *         @OA\Property(property="address", type="string", example="Jl. Contoh No. 123"),
 *         @OA\Property(property="phone", type="string", example="081234567890", maxLength=20),
 *         @OA\Property(property="owner_name", type="string", example="Budi Santoso", maxLength=255),
 *         @OA\Property(property="latitude", type="number", format="float", nullable=true, example=-6.200000),
 *         @OA\Property(property="longitude", type="number", format="float", nullable=true, example=106.816666),
 *         @OA\Property(property="photo", type="string", format="binary", description="Store photo file")
 *     ),
 *     @OA\Schema(
 *         schema="Product",
 *         @OA\Property(property="id", type="integer", example=1),
 *         @OA\Property(property="name", type="string", example="Produk A"),
 *         @OA\Property(property="code", type="string", example="PRD-001"),
 *         @OA\Property(property="price", type="number", format="float", example=100000.00),
 *         @OA\Property(property="description", type="string", example="Deskripsi produk A"),
 *         @OA\Property(property="photo_path", type="string", example="products/photo.jpg"),
 *         @OA\Property(property="photo_url", type="string", example="http://example.com/storage/products/photo.jpg"),
 *         @OA\Property(property="created_at", type="string", format="date-time"),
 *         @OA\Property(property="updated_at", type="string", format="date-time")
 *     ),
 *     @OA\Schema(
 *         schema="ProductInput",
 *         required={"name", "code", "price"},
 *         @OA\Property(property="name", type="string", example="Produk A", maxLength=255),
 *         @OA\Property(property="code", type="string", example="PRD-001", maxLength=50),
 *         @OA\Property(property="price", type="number", format="float", example=100000.00, minimum=0),
 *         @OA\Property(property="description", type="string", example="Deskripsi produk A", nullable=true),
 *         @OA\Property(property="photo", type="string", format="binary", description="Product photo file")
 *     ),
 *     @OA\Schema(
 *         schema="Consignment",
 *         @OA\Property(property="id", type="integer", example=1),
 *         @OA\Property(property="code", type="string", example="CONS-00001"),
 *         @OA\Property(property="store_id", type="integer", example=1),
 *         @OA\Property(property="consignment_date", type="string", format="date", example="2025-07-29"),
 *         @OA\Property(property="pickup_date", type="string", format="date", example="2025-08-05"),
 *         @OA\Property(property="status", type="string", enum={"active", "sold", "returned"}, example="active"),
 *         @OA\Property(property="photo_path", type="string", example="consignments/photo.jpg"),
 *         @OA\Property(property="photo_url", type="string", example="http://example.com/storage/consignments/photo.jpg"),
 *         @OA\Property(property="notes", type="string", example="Catatan tambahan"),
 *         @OA\Property(property="sold_quantity", type="integer", example=5),
 *         @OA\Property(property="returned_quantity", type="integer", example=2),
 *         @OA\Property(property="remaining_quantity", type="integer", example=3),
 *         @OA\Property(property="created_at", type="string", format="date-time"),
 *         @OA\Property(property="updated_at", type="string", format="date-time"),
 *         @OA\Property(property="store", ref="#/components/schemas/Store"),
 *         @OA\Property(property="productItems", type="array",
 *             @OA\Items(type="object",
 *                 @OA\Property(property="id", type="integer", example=1),
 *                 @OA\Property(property="product_id", type="integer", example=1),
 *                 @OA\Property(property="name", type="string", example="Produk A"),
 *                 @OA\Property(property="code", type="string", example="PRD-001"),
 *                 @OA\Property(property="price", type="number", format="float", example=100000),
 *                 @OA\Property(property="qty", type="integer", example=10),
 *                 @OA\Property(property="sales", type="integer", example=0),
 *                 @OA\Property(property="return", type="integer", example=0)
 *             )
 *         )
 *     ),
 *     @OA\Schema(
 *         schema="ConsignmentInput",
 *         required={"store_id", "consignment_date", "pickup_date", "status"},
 *         @OA\Property(property="store_id", type="integer", example=1, description="ID of the store"),
 *         @OA\Property(property="consignment_date", type="string", format="date", example="2025-07-29", description="Date when items were consigned"),
 *         @OA\Property(property="pickup_date", type="string", format="date", example="2025-08-05", description="Scheduled pickup date"),
 *         @OA\Property(property="status", type="string", enum={"active", "sold", "returned"}, example="active", description="Current status of consignment"),
 *         @OA\Property(property="photo", type="string", format="binary", description="Consignment photo file"),
 *         @OA\Property(property="notes", type="string", maxLength=1000, example="Catatan tambahan", nullable=true),
 *         @OA\Property(property="productItems", type="array",
 *             @OA\Items(type="object",
 *                 required={"product_id","name","code","price","qty"},
 *                 @OA\Property(property="product_id", type="integer", example=1),
 *                 @OA\Property(property="name", type="string", example="Produk A"),
 *                 @OA\Property(property="code", type="string", example="PRD-001"),
 *                 @OA\Property(property="price", type="number", format="float", example=100000),
 *                 @OA\Property(property="qty", type="integer", example=10)
 *             )
 *         )
 *     ),
 *     @OA\Schema(
 *         schema="Transaction",
 *         @OA\Property(property="id", type="integer", example=1),
 *         @OA\Property(property="consignment_id", type="integer", example=1),
 *         @OA\Property(property="transaction_date", type="string", format="date", example="2025-08-01"),
 *         @OA\Property(property="sold_items_photo_path", type="string", example="transactions/sold/photo.jpg"),
 *         @OA\Property(property="sold_items_photo_url", type="string", example="http://example.com/storage/transactions/sold/photo.jpg"),
 *         @OA\Property(property="returned_items_photo_path", type="string", example="transactions/returned/photo.jpg"),
 *         @OA\Property(property="returned_items_photo_url", type="string", example="http://example.com/storage/transactions/returned/photo.jpg"),
 *         @OA\Property(property="notes", type="string", example="Pembayaran lunas"),
 *         @OA\Property(property="items", type="array",
 *             @OA\Items(type="object",
 *                 @OA\Property(property="product_item_id", type="integer", example=10),
 *                 @OA\Property(property="sold", type="integer", example=3),
 *                 @OA\Property(property="returned", type="integer", example=0),
 *                 @OA\Property(property="price", type="number", format="float", example=100000)
 *             )
 *         ),
 *         @OA\Property(property="created_at", type="string", format="date-time"),
 *         @OA\Property(property="updated_at", type="string", format="date-time"),
 *         @OA\Property(property="consignment", ref="#/components/schemas/Consignment")
 *     ),
 *     @OA\Schema(
 *         schema="TransactionInput",
 *         required={"consignment_id", "items"},
 *         @OA\Property(property="consignment_id", type="integer", example=1, description="ID of the consignment"),
 *         @OA\Property(property="transaction_date", type="string", format="date", example="2025-08-01", description="Date of the transaction"),
 *         @OA\Property(property="sold_items_photo", type="string", format="binary", description="Photo of sold items", nullable=true),
 *         @OA\Property(property="returned_items_photo", type="string", format="binary", description="Photo of returned items", nullable=true),
 *         @OA\Property(property="notes", type="string", maxLength=1000, example="Pembayaran lunas", nullable=true),
 *         @OA\Property(property="items", type="array",
 *             @OA\Items(type="object",
 *                 required={"product_item_id","sold","returned"},
 *                 @OA\Property(property="product_item_id", type="integer", example=10),
 *                 @OA\Property(property="sold", type="integer", example=3),
 *                 @OA\Property(property="returned", type="integer", example=0),
 *                 @OA\Property(property="price", type="number", format="float", example=100000)
 *             )
 *         )
 *     ),
 *     @OA\Schema(
 *         schema="LoginRequest",
 *         required={"email", "password"},
 *         @OA\Property(property="email", type="string", format="email", example="user@example.com"),
 *         @OA\Property(property="password", type="string", format="password", example="password")
 *     ),
 *     @OA\Schema(
 *         schema="LoginResponse",
 *         @OA\Property(property="success", type="boolean", example=true),
 *         @OA\Property(property="data", type="object",
 *             @OA\Property(property="token", type="string", example="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9..."),
 *             @OA\Property(property="user", type="object",
 *                 @OA\Property(property="id", type="integer", example=1),
 *                 @OA\Property(property="name", type="string", example="Admin User"),
 *                 @OA\Property(property="email", type="string", format="email", example="admin@example.com")
 *             )
 *         ),
 *         @OA\Property(property="message", type="string", example="Login successful")
 *     )
 * )
 */
class Components
{
    // This class is used for Swagger documentation only
}
