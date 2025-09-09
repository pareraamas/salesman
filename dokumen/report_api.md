# Report API

## Get Sales Report
`GET /api/reports/sales`

**Query Parameters:**
- `start_date` (required): Start date (format: YYYY-MM-DD)
- `end_date` (required): End date (format: YYYY-MM-DD)
- `store_id` (optional): Filter by store ID
- `product_id` (optional): Filter by product ID
- `group_by` (optional): Group by (day, week, month, year, product, store)
- `export` (optional): Export format (csv, pdf, xlsx)

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "summary": {
            "total_sales": 50,
            "total_returns": 5,
            "net_quantity": 45,
            "total_amount": 1500000,
            "average_daily_sales": 5,
            "top_products": [
                {
                    "product_id": 1,
                    "product_name": "Mie Basah",
                    "quantity_sold": 30,
                    "total_amount": 900000
                }
            ]
        },
        "data": [
            {
                "date": "2025-01-01",
                "total_sales": 10,
                "total_returns": 1,
                "net_quantity": 9,
                "total_amount": 270000
            },
            {
                "date": "2025-01-02",
                "total_sales": 15,
                "total_returns": 2,
                "net_quantity": 13,
                "total_amount": 390000
            }
        ]
    },
    "message": "Laporan penjualan berhasil diambil",
    "code": 200
}
```

## Get Consignment Report
`GET /api/reports/consignments`

**Query Parameters:**
- `status` (optional): Filter by status (active, completed, returned, cancelled)
- `store_id` (optional): Filter by store ID
- `product_id` (optional): Filter by product ID
- `export` (optional): Export format (csv, pdf, xlsx)

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
            "store_name": "Toko Baru",
            "product_name": "Mie Basah",
            "quantity": 100,
            "sold_quantity": 50,
            "returned_quantity": 5,
            "remaining_quantity": 45,
            "status": "active",
            "start_date": "2025-01-01",
            "end_date": "2025-12-31",
            "completion_percentage": 50
        }
    ],
    "message": "Laporan konsinyasi berhasil diambil",
    "code": 200
}
```

## Get Performance Report
`GET /api/reports/performance`

**Query Parameters:**
- `start_date` (required): Start date (format: YYYY-MM-DD)
- `end_date` (required): End date (format: YYYY-MM-DD)
- `user_id` (optional): Filter by user ID (for admin only)
- `export` (optional): Export format (csv, pdf, xlsx)

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "user_id": 1,
        "user_name": "John Doe",
        "period": "January 2025",
        "total_transactions": 50,
        "total_sales": 1000,
        "total_returns": 50,
        "net_sales": 950,
        "total_amount": 28500000,
        "average_transaction_value": 570000,
        "stores_visited": 10,
        "new_stores": 2,
        "achievement_percentage": 85,
        "daily_average": {
            "transactions": 3.3,
            "sales": 33.3,
            "amount": 950000
        },
        "top_stores": [
            {
                "store_id": 1,
                "store_name": "Toko Baru",
                "total_sales": 200,
                "total_amount": 6000000
            }
        ]
    },
    "message": "Laporan kinerja berhasil diambil",
    "code": 200
}
```
