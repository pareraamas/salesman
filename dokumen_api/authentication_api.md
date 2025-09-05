# Authentication API

## Login
`POST /api/login`

**Request Body:**
```json
{
    "email": "user@example.com",
    "password": "password"
}
```

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "token": "{access_token}",
        "user": {
            "id": 1,
            "name": "User Name",
            "email": "user@example.com",
            "role": "sales"
        }
    },
    "message": "Login berhasil",
    "code": 200
}
```

## Get User Profile
`GET /api/user`

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "User Name",
        "email": "user@example.com",
        "role": "sales"
    },
    "message": "Data user berhasil diambil",
    "code": 200
}
```

## Logout
`POST /api/logout`

**Headers:**
- `Authorization: Bearer {token}`

**Success Response (200 OK):**
```json
{
    "success": true,
    "message": "Logout berhasil",
    "code": 200
}
```
