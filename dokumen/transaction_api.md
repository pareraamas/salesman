# Transaction API

## Create New Transaction
`POST /api/transactions`

**Headers:**
- `Authorization: Bearer {token}`
- `Content-Type: multipart/form-data`

**Request Body:**
- `consignment_id` (required): ID konsinyasi
- `transaction_date` (required): Tanggal transaksi (format: YYYY-MM-DD)
- `items` (required): Array of items
  - `product_item_id` (required): ID item produk
  - `sold` (required): Jumlah terjual
  - `returned` (required): Jumlah dikembalikan
  - `price` (optional): Harga per item
- `notes` (optional): Catatan
- `sold_items_photo` (optional): Foto barang terjual (format: jpg,jpeg,png|max:2048)
- `returned_items_photo` (optional): Foto barang dikembalikan (format: jpg,jpeg,png|max:2048)

**Success Response (201 Created):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "consignment_id": 1,
        "transaction_date": "2025-01-15",
        "total_sold": 10,
        "total_returned": 2,
        "net_quantity": 8,
        "total_amount": 160000,
        "notes": "Penjualan pertama",
        "sold_items_photo_url": "https://example.com/storage/transactions/sold/photo1.jpg",
        "returned_items_photo_url": "https://example.com/storage/transactions/returned/photo2.jpg",
        "items": [
            {
                "id": 1,
                "product_id": 1,
                "name": "Mie Basah",
                "code": "MB-001",
                "price": 20000,
                "sold": 10,
                "returned": 2,
                "subtotal": 160000
            }
        ]
    },
    "message": "Transaksi berhasil dibuat",
    "code": 201
}
```

## Get Transaction List
`GET /api/transactions`

**Query Parameters:**
- `consignment_id` (optional): Filter by consignment ID
- `store_id` (optional): Filter by store ID
- `product_id` (optional): Filter by product ID
- `from_date` (optional): Filter from date (format: YYYY-MM-DD)
- `to_date` (optional): Filter to date (format: YYYY-MM-DD)
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
            "consignment_id": 1,
            "transaction_date": "2025-01-15",
            "total_sold": 10,
            "total_returned": 2,
            "net_quantity": 8,
            "total_amount": 160000,
            "notes": "Penjualan pertama",
            "created_at": "2025-01-15T10:00:00.000000Z"
        }
    ],
    "message": "Daftar transaksi berhasil diambil",
    "meta": {
        "current_page": 1,
        "last_page": 1,
        "per_page": 15,
        "total": 1
    },
    "code": 200
}
```

## Get Transaction Detail
`GET /api/transactions/{id}`

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "consignment_id": 1,
        "transaction_date": "2025-01-15",
        "total_sold": 10,
        "total_returned": 2,
        "net_quantity": 8,
        "total_amount": 160000,
        "notes": "Penjualan pertama",
        "sold_items_photo_url": "https://example.com/storage/transactions/sold/photo1.jpg",
        "returned_items_photo_url": "https://example.com/storage/transactions/returned/photo2.jpg",
        "created_at": "2025-01-15T10:00:00.000000Z",
        "updated_at": "2025-01-15T10:00:00.000000Z",
        "items": [
            {
                "id": 1,
                "product_id": 1,
                "name": "Mie Basah",
                "code": "MB-001",
                "price": 20000,
                "sold": 10,
                "returned": 2,
                "subtotal": 160000
            }
        ],
        "consignment": {
            "id": 1,
            "code": "KONS-20250001",
            "store": {
                "id": 1,
                "name": "Toko Baru"
            },
            "product": {
                "id": 1,
                "name": "Mie Basah"
            }
        }
    },
    "message": "Data transaksi berhasil diambil",
    "code": 200
}
```

## Get Transaction Summary
`GET /api/transactions/summary`

**Query Parameters:**
- `start_date` (optional): Start date (format: YYYY-MM-DD)
- `end_date` (optional): End date (format: YYYY-MM-DD)
- `store_id` (optional): Filter by store ID
- `product_id` (optional): Filter by product ID
- `status` (optional): Filter by consignment status (active, completed, returned, cancelled)

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "total_transactions": 10,
        "total_sold": 50,
        "total_returned": 5,
        "net_quantity": 45,
        "total_amount": 1500000,
        "stores_summary": [
            {
                "store_id": 1,
                "store_name": "Toko Baru",
                "total_transactions": 5,
                "total_sold": 30,
                "total_returned": 2
            }
        ]
    },
    "message": "Ringkasan transaksi berhasil diambil",
    "code": 200
}
```
