<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\ResourceCollection;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\Response as HttpResponse;

class BaseController extends Controller
{
    /**
     * Send success response
     *
     * @param mixed $data Response data
     * @param string $message Success message
     * @param int $code HTTP status code (default: 200)
     * @return \Illuminate\Http\JsonResponse
     */
    protected function sendResponse(
        $data = null, 
        string $message = 'Operation successful', 
        int $code = HttpResponse::HTTP_OK
    ): JsonResponse {
        $response = [
            'success' => true,
            'code' => $code,
            'message' => $message,
            'data' => $data,
            'meta' => null,
            'errors' => null,
        ];

        // Handle pagination
        if ($data instanceof ResourceCollection || $data instanceof LengthAwarePaginator) {
            $response['data'] = $data->items();
            $response['meta'] = [
                'current_page' => $data->currentPage(),
                'from' => $data->firstItem(),
                'last_page' => $data->lastPage(),
                'per_page' => (int) $data->perPage(),
                'to' => $data->lastItem(),
                'total' => $data->total(),
                'path' => $data->path(),
                'first_page_url' => $data->url(1),
                'last_page_url' => $data->url($data->lastPage()),
                'next_page_url' => $data->nextPageUrl(),
                'prev_page_url' => $data->previousPageUrl(),
            ];
        } elseif ($data !== null) {
            $response['data'] = $data;
        } else {
            unset($response['data']);
        }

        return response()->json($response, $code);
    }

    /**
     * Send error response
     *
     * @param string $message Error message
     * @param mixed $errors Array of errors or error details
     * @param int $code HTTP status code (default: 400)
     * @return \Illuminate\Http\JsonResponse
     */
    protected function sendError(
        string $message = 'An error occurred', 
        $errors = null, 
        int $code = HttpResponse::HTTP_BAD_REQUEST
    ): JsonResponse {
        $response = [
            'success' => false,
            'code' => $code,
            'message' => $message,
            'data' => null,
            'meta' => null,
            'errors' => $errors,
        ];

        return response()->json($response, $code);
    }

    /**
     * Send not found response
     *
     * @param string $message Error message
     * @return \Illuminate\Http\JsonResponse
     */
    protected function sendNotFound(string $message = 'Resource not found'): JsonResponse
    {
        return $this->sendError($message, null, HttpResponse::HTTP_NOT_FOUND);
    }

    /**
     * Send unauthorized response
     *
     * @param string $message Error message
     * @return \Illuminate\Http\JsonResponse
     */
    protected function sendUnauthorized(string $message = 'Unauthorized'): JsonResponse
    {
        return $this->sendError($message, null, HttpResponse::HTTP_UNAUTHORIZED);
    }

    /**
     * Send forbidden response
     *
     * @param string $message Error message
     * @return \Illuminate\Http\JsonResponse
     */
    protected function sendForbidden(string $message = 'Forbidden'): JsonResponse
    {
        return $this->sendError($message, null, HttpResponse::HTTP_FORBIDDEN);
    }

    /**
     * Send validation error response
     *
     * @param \Illuminate\Contracts\Validation\Validator|array $validator Validator instance or errors array
     * @param string $message Error message
     * @return \Illuminate\Http\JsonResponse
     */
    protected function sendValidationError($validator, string $message = 'Validation failed'): JsonResponse
    {
        $errors = $validator instanceof \Illuminate\Contracts\Validation\Validator
            ? $validator->errors()->toArray()
            : $validator;

        return $this->sendError(
            $message,
            ['validation' => $errors],
            HttpResponse::HTTP_UNPROCESSABLE_ENTITY
        );
    }

    /**
     * Handle API exceptions
     *
     * @param \Throwable $e
     * @return \Illuminate\Http\JsonResponse
     */
    protected function handleException(\Throwable $e): JsonResponse
    {
        Log::error('API Exception:', [
            'message' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'trace' => $e->getTraceAsString(),
        ]);

        if ($e instanceof ValidationException) {
            return $this->sendValidationError($e->validator, 'Validasi gagal');
        }

        // Handle different types of exceptions
        $statusCode = HttpResponse::HTTP_INTERNAL_SERVER_ERROR;
        $message = $e->getMessage() ?: 'Terjadi kesalahan pada server';

        // Handle common HTTP exceptions
        if ($e instanceof \Symfony\Component\HttpKernel\Exception\HttpException) {
            $statusCode = $e->getStatusCode();
        } elseif ($e instanceof \Illuminate\Database\Eloquent\ModelNotFoundException) {
            $statusCode = HttpResponse::HTTP_NOT_FOUND;
            $message = 'Data tidak ditemukan';
        } elseif ($e instanceof \Illuminate\Database\QueryException) {
            $message = 'Terjadi kesalahan pada database';
        } elseif ($e instanceof \Illuminate\Auth\AuthenticationException) {
            $statusCode = HttpResponse::HTTP_UNAUTHORIZED;
            $message = 'Tidak terautentikasi';
        } elseif ($e instanceof \Illuminate\Auth\Access\AuthorizationException) {
            $statusCode = HttpResponse::HTTP_FORBIDDEN;
            $message = 'Tidak memiliki izin';
        }

        // In production, don't expose detailed error messages
        if (app()->environment('production') && $statusCode >= 500) {
            $message = 'Terjadi kesalahan pada server';
        }

        return $this->sendError($message, null, $statusCode);
    }
}
