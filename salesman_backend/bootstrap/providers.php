<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Application Service Providers
    |--------------------------------------------------------------------------
    |
    | This array of service provider class names will be automatically loaded
    | on the request to your application. Feel free to add your own services
    | to this array to grant expanded functionality to your applications.
    |
    */

    App\Providers\AppServiceProvider::class,
    App\Providers\AuthServiceProvider::class,
    App\Providers\EventServiceProvider::class,
    App\Providers\RouteServiceProvider::class,

    /*
    |--------------------------------------------------------------------------
    | Package Service Providers...
    |--------------------------------------------------------------------------
    */

    App\Providers\Filament\AdminPanelProvider::class,
];
