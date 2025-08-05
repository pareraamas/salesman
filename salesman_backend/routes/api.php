<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\StoreController;
use App\Http\Controllers\API\ProductController;
use App\Http\Controllers\API\ConsignmentController;
use App\Http\Controllers\API\TransactionController;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// Public routes
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Test route - temporary
Route::get('/test-login', function () {
    $user = User::first();
    
    if (!$user) {
        return response()->json(['error' => 'No users found'], 404);
    }
    
    return response()->json([
        'user' => [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
        ],
        'password_matches' => Hash::check('admin12345', $user->password),
    ]);
});

// Protected routes
Route::middleware(['auth:sanctum', 'api'])->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    
    // Stores
    Route::apiResource('stores', StoreController::class);
    Route::get('/stores/list', [StoreController::class, 'listAll']);
    
    // Products
    Route::apiResource('products', ProductController::class);
    Route::get('/products/list', [ProductController::class, 'listAll']);
    
    // Consignments
    Route::apiResource('consignments', ConsignmentController::class);
    Route::get('/consignments/list', [ConsignmentController::class, 'listAll']);
    Route::get('/consignments/active', [ConsignmentController::class, 'active']);
    Route::get('/consignments/{consignment}/transactions', [ConsignmentController::class, 'transactions']);
    
    // Transactions
    Route::apiResource('transactions', TransactionController::class);
    Route::get('/transactions/summary', [TransactionController::class, 'summary']);
});
