# Product API

## Get All Products
`GET /api/products`

**Query Parameters:**
- `search` (optional): Search products by name or code
- `category_id` (optional): Filter by category ID
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
            "name": "Mie Basah",
            "code": "MB-001",
            "category_id": 1,
            "category_name": "Makanan",
            "price": 20000,
            "stock": 100,
            "unit": "pcs",
            "image_url": "https://example.com/images/mie-basah.jpg"
        }
    ],
    "message": "Daftar produk berhasil diambil",
    "meta": {
        "current_page": 1,
        "last_page": 1,
        "per_page": 15,
        "total": 1
    },
    "code": 200
}
```

## Get Product Detail
`GET /api/products/{id}`

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "Mie Basah",
        "code": "MB-001",
        "description": "Mie basah kualitas premium",
        "category_id": 1,
        "category_name": "Makanan",
        "price": 20000,
        "stock": 100,
        "min_stock": 10,
        "unit": "pcs",
        "weight": 250,
        "weight_unit": "gram",
        "image_url": "https://example.com/images/mie-basah.jpg",
        "created_at": "2025-01-01T00:00:00.000000Z",
        "updated_at": "2025-01-01T00:00:00.000000Z"
    },
    "message": "Data produk berhasil diambil",
    "code": 200
}
```

## Get Product Categories
`GET /api/product-categories`

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "Makanan",
            "description": "Produk makanan"
        },
        {
            "id": 2,
            "name": "Minuman",
            "description": "Produk minuman"
        }
    ],
    "message": "Daftar kategori produk berhasil diambil",
    "code": 200
}
```
