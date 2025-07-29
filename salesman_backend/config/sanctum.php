<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Stateful Domains
    |--------------------------------------------------------------------------
    |
    | Requests from these domains/hosts will receive stateful API authentication
    | cookies. These should include your local and production domains which
    | access your API via a frontend SPA.
    |
    */
    'stateful' => array_filter(array_map('trim', [
        'localhost',
        'localhost:3000',
        '127.0.0.1',
        '127.0.0.1:8000',
        '::1',
        'salesman_backend.test',
        'localhost:8000',
        'localhost:5173',
        '127.0.0.1:5173'
    ])),

    /*
    |--------------------------------------------------------------------------
    | Expiration Minutes
    |--------------------------------------------------------------------------
    |
    | This value controls the number of minutes until an issued token will be
    | considered expired. If this value is null, personal access tokens do
    | not expire. This won't affect the lifetime of first-party sessions.
    |
    */
    'expiration' => env('SANCTUM_TOKEN_EXPIRATION', 60 * 24 * 7), // 1 week

    /*
    |--------------------------------------------------------------------------
    | Sanctum Guards
    |--------------------------------------------------------------------------
    |
    | This array contains the authentication guards that will be checked when
    | Sanctum is trying to authenticate a request.
    |
    */
    'guard' => ['web'],

    /*
    |--------------------------------------------------------------------------
    | Middleware
    |--------------------------------------------------------------------------
    |
    | When authenticating your first-party SPA with Sanctum you may need to
    | customize some of the middleware Sanctum uses while processing the
    | request. You may change the middleware listed below as required.
    |
    */
    'middleware' => [
        'verify_csrf_token' => App\Http\Middleware\VerifyCsrfToken::class,
        'encrypt_cookies' => App\Http\Middleware\EncryptCookies::class,
    ],

    'prefix' => 'api',

    'token_prefix' => env('SANCTUM_TOKEN_PREFIX', ''),
];
