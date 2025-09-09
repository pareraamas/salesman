# Consignment API

## Get All Consignments
`GET /api/consignments`

**Query Parameters:**
- `store_id` (optional): Filter by store ID
- `product_id` (optional): Filter by product ID
- `status` (optional): Filter by status (active, completed, returned, cancelled)
- `per_page` (optional, default: 15): Items per page

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "code": "KONS-20250001",
            "store_id": 1,
            "store_name": "Toko Baru",
            "product_id": 1,
            "product_name": "Mie Basah",
            "quantity": 100,
            "sold_quantity": 50,
            "returned_quantity": 5,
            "remaining_quantity": 45,
            "status": "active",
            "start_date": "2025-01-01",
            "end_date": "2025-12-31",
            "notes": "Konsinyasi awal"
        }
    ],
    "message": "Daftar konsinyasi berhasil diambil",
    "meta": {
        "current_page": 1,
        "last_page": 1,
        "per_page": 15,
        "total": 1
    },
    "code": 200
}
```

## Create New Consignment
`POST /api/consignments`

**Headers:**
- `Authorization: Bearer {token}`
- `Content-Type: multipart/form-data`

**Request Body:**
- `store_id` (required): ID toko
- `product_id` (required): ID produk
- `quantity` (required): Jumlah barang
- `start_date` (required): Tanggal mulai (format: YYYY-MM-DD)
- `end_date` (required): Tanggal berakhir (format: YYYY-MM-DD)
- `notes` (optional): Catatan
- `photo` (optional): Foto barang (format: jpg,jpeg,png|max:2048)

**Success Response (201 Created):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "code": "KONS-20250001",
        "store_id": 1,
        "product_id": 1,
        "quantity": 100,
        "sold_quantity": 0,
        "returned_quantity": 0,
        "status": "active",
        "start_date": "2025-01-01",
        "end_date": "2025-12-31",
        "notes": "Konsinyasi awal",
        "photo_url": "https://example.com/storage/consignments/photo.jpg"
    },
    "message": "Konsinyasi berhasil dibuat",
    "code": 201
}
```

## Get Consignment Transactions
`GET /api/consignments/{id}/transactions`

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "transaction_date": "2025-01-15",
            "type": "sale",
            "quantity": 10,
            "notes": "Penjualan awal",
            "created_at": "2025-01-15T10:00:00.000000Z"
        },
        {
            "id": 2,
            "transaction_date": "2025-01-20",
            "type": "return",
            "quantity": 2,
            "notes": "Retur barang cacat",
            "created_at": "2025-01-20T14:30:00.000000Z"
        }
    ],
    "message": "Daftar transaksi konsinyasi berhasil diambil",
    "code": 200
}
```
