<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Global Middleware
        $middleware->trustProxies(at: '*');
        
        // API Middleware Group
        $middleware->api([
            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
            \Illuminate\Routing\Middleware\ThrottleRequests::class.':api',
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ]);
        
        // Web Middleware Group
        $middleware->web([
            \App\Http\Middleware\EncryptCookies::class,
            \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
            \Illuminate\Session\Middleware\StartSession::class,
            \Illuminate\View\Middleware\ShareErrorsFromSession::class,
            \App\Http\Middleware\VerifyCsrfToken::class,
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ]);
        
        // Middleware Aliases
        $middleware->alias([
            'auth' => \App\Http\Middleware\Authenticate::class,
            'auth.basic' => \Illuminate\Auth\Middleware\AuthenticateWithBasicAuth::class,
            'auth.session' => \Illuminate\Session\Middleware\AuthenticateSession::class,
            'cache.headers' => \Illuminate\Http\Middleware\SetCacheHeaders::class,
            'can' => \Illuminate\Auth\Middleware\Authorize::class,
            'guest' => \App\Http\Middleware\RedirectIfAuthenticated::class,
            'password.confirm' => \Illuminate\Auth\Middleware\RequirePassword::class,
            'signed' => \Illuminate\Routing\Middleware\ValidateSignature::class,
            'throttle' => \Illuminate\Routing\Middleware\ThrottleRequests::class,
            'verified' => \Illuminate\Auth\Middleware\EnsureEmailIsVerified::class,
        ]);
        
        // Prioritize CORS
        $middleware->prependToGroup('api', \Illuminate\Http\Middleware\HandleCors::class);
        $middleware->prependToGroup('web', \Illuminate\Http\Middleware\HandleCors::class);
        
        // CSRF Token Validation Exceptions
        $middleware->validateCsrfTokens(except: [
            'api/*',
            'admin/*',
            'admin-api/*',
            'filament/*',
            'admin/filament/*',
            'admin-api/filament/*',
            'sanctum/csrf-cookie',
            'login',
            'logout',
            'api/logout',
            'api/user',
        ]);
        
        // Ensure session is started for web routes
        $middleware->web(\Illuminate\Session\Middleware\StartSession::class);
        $middleware->web(\Illuminate\View\Middleware\ShareErrorsFromSession::class);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
