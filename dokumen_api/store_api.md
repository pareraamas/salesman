# Store API

## Get All Stores
`GET /api/stores`

**Query Parameters:**
- `search` (optional): Search stores by name or address
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
            "name": "Toko Baru",
            "code": "TB-001",
            "address": "Jl. Contoh No. 123",
            "phone": "081234567890",
            "owner_name": "John Doe",
            "status": "active"
        }
    ],
    "message": "Daftar toko berhasil diambil",
    "meta": {
        "current_page": 1,
        "last_page": 1,
        "per_page": 15,
        "total": 1
    },
    "code": 200
}
```

## Get Store Detail
`GET /api/stores/{id}`

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "Toko Baru",
        "code": "TB-001",
        "address": "Jl. Contoh No. 123",
        "phone": "081234567890",
        "owner_name": "John Doe",
        "status": "active",
        "latitude": "-6.2088",
        "longitude": "106.8456",
        "created_at": "2025-01-01T00:00:00.000000Z",
        "updated_at": "2025-01-01T00:00:00.000000Z"
    },
    "message": "Data toko berhasil diambil",
    "code": 200
}
```

## Get Nearest Stores
`GET /api/stores/nearest`

**Query Parameters:**
- `lat`: Latitude of current location
- `lng`: Longitude of current location
- `radius` (optional, default: 10): Radius in kilometers

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "Toko Terdekat",
            "address": "Jl. Terdekat No. 1",
            "distance": 0.5,
            "unit": "km"
        }
    ],
    "message": "Daftar toko terdekat berhasil diambil",
    "code": 200
}
```
