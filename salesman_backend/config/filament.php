<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Default Panel
    |--------------------------------------------------------------------------
    |
    | This is the panel that will be shown by default when visiting the
    | application's root URL. You may specify a different panel by passing
    | the panel name as a query parameter to the URL.
    |
    */

    'default' => 'admin',

    /*
    |--------------------------------------------------------------------------
    | Panels
    |--------------------------------------------------------------------------
    |
    | Here you may define all of the panels that your application supports.
    | Each panel has its own theme, middleware, and other configuration.
    |
    */

    'panels' => [
        'admin' => [
            'path' => 'admin',
            'domain' => env('FILAMENT_DOMAIN', null),
            'auth' => [
                'guard' => env('FILAMENT_AUTH_GUARD', 'web'),
                'pages' => [
                    'login' => \Filament\Http\Livewire\Auth\Login::class,
                ],
            ],
            'pages' => [
                'dashboard' => \App\Filament\Pages\Dashboard::class,
            ],
            'widgets' => [
                'account' => \Filament\Widgets\AccountWidget::class,
                'filament_info' => \Filament\Widgets\FilamentInfoWidget::class,
                'stores_overview' => \App\Filament\Widgets\StoresOverview::class,
                'consignment_stats' => \App\Filament\Widgets\ConsignmentStats::class,
                'recent_consignments' => \App\Filament\Widgets\RecentConsignments::class,
                'recent_transactions' => \App\Filament\Widgets\RecentTransactions::class,
            ],
            'resources' => [
                'filament/resources',
                'app/Filament/Resources',
            ],
            'navigation' => [
                'filament/pages',
                'filament/resources',
                'app/Filament/Resources',
            ],
            'middleware' => [
                'web',
                'auth:sanctum',
                'verified',
            ],
            'auth' => [
                'guard' => 'web',
                'pages' => [
                    'login' => '\Filament\Http\Livewire\Auth\Login',
                ],
            ],
            'database_notifications' => [
                'enabled' => true,
                'polling_interval' => '30s',
            ],
            'dark_mode' => true,
            'sidebar' => [
                'is_collapsible_on_desktop' => true,
                'collapsed_width' => 0,
                'collapsed_sidebar_width' => 0,
                'width' => null,
                'collapsed' => false,
            ],
            'max_content_width' => '7xl',
            'notifications' => [
                'database' => true,
                'mail' => true,
                'slack' => false,
                'discord' => false,
            ],
            'plugins' => [
                //
            ],
            'theme' => 'default',
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Broadcasting
    |--------------------------------------------------------------------------
    |
    | By uncommenting the Laravel Echo configuration, you may connect Filament
    | to any Pusher-compatible websockets server.
    |
    | This will allow your users to receive real-time notifications.
    |
    */

    'broadcasting' => [
        // 'echo' => [
        //     'broadcaster' => 'pusher',
        //     'key' => env('VITE_PUSHER_APP_KEY'),
        //     'cluster' => env('VITE_PUSHER_APP_CLUSTER'),
        //     'wsHost' => env('VITE_PUSHER_HOST'),
        //     'wsPort' => env('VITE_PUSHER_PORT'),
        //     'wssPort' => env('VITE_PUSHER_PORT'),
        //     'authEndpoint' => '/broadcasting/auth',
        //     'disableStats' => true,
        //     'encrypted' => true,
        //     'forceTLS' => true,
        // ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Default Filesystem Disk
    |--------------------------------------------------------------------------
    |
    | This is the storage disk Filament will use to store files. You may use
    | any of the disks defined in the `config/filesystems.php`.
    |
    */

    'default_filesystem_disk' => env('FILAMENT_FILESYSTEM_DISK', 'public'),

    /*
    |--------------------------------------------------------------------------
    | Assets Path
    |--------------------------------------------------------------------------
    |
    | This is the directory where Filament's assets will be published to. It
    | is relative to the `public` directory of your Laravel application.
    |
    | After changing the path, you should run `php artisan filament:assets`.
    |
    */

    'assets_path' => null,

    /*
    |--------------------------------------------------------------------------
    | Cache Path
    |--------------------------------------------------------------------------
    |
    | This is the directory that Filament will use to store cache files that
    | are used to optimize the registration of components.
    |
    | After changing the path, you should run `php artisan filament:cache-components`.
    |
    */

    'cache_path' => base_path('bootstrap/cache/filament'),

    /*
    |--------------------------------------------------------------------------
    | Livewire Loading Delay
    |--------------------------------------------------------------------------
    |
    | This sets the delay before loading indicators appear.
    |
    | Setting this to 'none' makes indicators appear immediately, which can be
    | desirable for high-latency connections. Setting it to 'default' applies
    | Livewire's standard 200ms delay.
    |
    */

    'livewire_loading_delay' => 'default',

    /*
    |--------------------------------------------------------------------------
    | System Route Prefix
    |--------------------------------------------------------------------------
    |
    | This is the prefix used for the system routes that Filament registers,
    | such as the routes for downloading exports and failed import rows.
    |
    */

    'system_route_prefix' => 'filament',

];
