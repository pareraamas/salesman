<?php

namespace App\Http\Middleware;

use Illuminate\Cookie\Middleware\EncryptCookies as Middleware;

class EncryptCookies extends Middleware
{
    /**
     * The names of the cookies that should not be encrypted.
     *
     * @var array<int, string>
     */
    protected $except = [
        'XSRF-TOKEN',
        'laravel_session',
        'XSRF-TOKEN',
        'filament_session',
        'remember_web_*',
        'XSRF-TOKEN',
    ];
}
