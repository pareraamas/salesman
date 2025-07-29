<?php

return [
    'paths' => [
        'api/*',
        'login',
        'logout',
        'sanctum/csrf-cookie',
        'admin/*',
        'admin-api/*',
        'filament/*',
        'admin/filament/*',
        'admin-api/filament/*',
    ],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [
        'Content-Disposition'
    ],
    'max_age' => 0,
    'supports_credentials' => true,
    'allowed_headers' => ['*'],
];
