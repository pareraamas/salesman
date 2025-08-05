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
        // When modifying APP_NAME in the .env file, ensure to also update this session name: "salesman_session", using all lowercase letters.
        'salesman_session',
        'XSRF-TOKEN',
        'filament_session',
        'remember_web_*',
        'XSRF-TOKEN',
    ];
}
