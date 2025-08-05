<?php

namespace App\Http\Controllers\API;

use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response as HttpResponse;
use Illuminate\Support\Facades\Log;

class AuthController extends BaseController
{
    /**
     * @OA\Post(
     *     path="/api/login",
     *     tags={"Authentication"},
     *     summary="Login user and create token",
     *     operationId="login",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"email", "password"},
     *             @OA\Property(property="email", type="string", format="email", example="admin@example.com"),
     *             @OA\Property(property="password", type="string", format="password", example="password")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Login successful",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="token", type="string", example="1|abcdefghijklmnopqrstuvwxyz"),
     *                 @OA\Property(property="user", type="object",
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="name", type="string", example="Admin User"),
     *                     @OA\Property(property="email", type="string", example="admin@example.com")
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string", example="Login successful")
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Unauthorized",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Unauthorized")
     *         )
     *     )
     * )
     */
    public function login(LoginRequest $request)
    {
        try {
            $credentials = $request->only('email', 'password');

            if (!Auth::attempt($credentials)) {
                return $this->sendError(
                    'Login gagal',
                    ['email' => ['Email atau password salah']],
                    HttpResponse::HTTP_UNAUTHORIZED
                );
            }

            $user = Auth::user();
            $token = $user->createToken('auth_token')->plainTextToken;

            return $this->sendResponse(
                [
                    'token' => $token,
                    'token_type' => 'Bearer',
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'created_at' => $user->created_at,
                    ]
                ],
                'Login berhasil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Login error: ' . $e->getMessage());
            return $this->sendError(
                'Terjadi kesalahan saat login',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Post(
     *     path="/api/logout",
     *     tags={"Authentication"},
     *     summary="Logout user (Revoke token)",
     *     operationId="logout",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Successfully logged out",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Successfully logged out")
     *         )
     *     )
     * )
     */
    public function logout(Request $request)
    {
        try {
            $request->user()->currentAccessToken()->delete();
            return $this->sendResponse(
                null,
                'Logout berhasil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Logout error: ' . $e->getMessage());
            return $this->sendError(
                'Gagal logout',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Get(
     *     path="/api/user",
     *     tags={"Authentication"},
     *     summary="Get authenticated user details",
     *     operationId="getUser",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="User retrieved successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="name", type="string", example="Admin User"),
     *                 @OA\Property(property="email", type="string", example="admin@example.com")
     *             ),
     *             @OA\Property(property="message", type="string", example="User retrieved successfully")
     *         )
     *     )
     * )
     */
    public function user(Request $request)
    {
        try {
            $user = $request->user();
            
            return $this->sendResponse(
                [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'created_at' => $user->created_at,
                ],
                'Data user berhasil diambil',
                HttpResponse::HTTP_OK
            );
        } catch (\Exception $e) {
            Log::error('Get user error: ' . $e->getMessage());
            return $this->sendError(
                'Gagal mengambil data user',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * @OA\Post(
     *     path="/api/register",
     *     tags={"Authentication"},
     *     summary="Register a new user",
     *     operationId="register",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"name","email","password","password_confirmation"},
     *             @OA\Property(property="name", type="string", example="John Doe"),
     *             @OA\Property(property="email", type="string", format="email", example="user@example.com"),
     *             @OA\Property(property="password", type="string", format="password", example="password"),
     *             @OA\Property(property="password_confirmation", type="string", format="password", example="password")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="User registered successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="token", type="string", example="1|abcdefghijklmnopqrstuvwxyz"),
     *                 @OA\Property(property="token_type", type="string", example="Bearer"),
     *                 @OA\Property(property="user", type="object",
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="name", type="string", example="John Doe"),
     *                     @OA\Property(property="email", type="string", example="user@example.com"),
     *                     @OA\Property(property="created_at", type="string", format="date-time")
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string", example="User registered successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="The given data was invalid."),
     *             @OA\Property(property="errors", type="object")
     *         )
     *     )
     * )
     */
    public function register(RegisterRequest $request)
    {
        try {
            $validated = $request->validated();
            
            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'email_verified_at' => now(),
                'remember_token' => Str::random(10),
            ]);

            $token = $user->createToken('auth_token')->plainTextToken;

            return $this->sendResponse(
                [
                    'token' => $token,
                    'token_type' => 'Bearer',
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'created_at' => $user->created_at,
                    ]
                ],
                'Registrasi berhasil',
                HttpResponse::HTTP_CREATED
            );
        } catch (\Exception $e) {
            Log::error('Registration error: ' . $e->getMessage());
            return $this->sendError(
                'Gagal melakukan registrasi',
                null,
                HttpResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}
