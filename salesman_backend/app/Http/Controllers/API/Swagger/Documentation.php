<?php

namespace App\Http\Controllers\API\Swagger;

/**
 * @OA\Info(
 *     title="Salesman API Documentation",
 *     version="1.0.0",
 *     description="API documentation for Salesman Consignment System",
 *     @OA\Contact(
 *         email="support@example.com",
 *         name="API Support"
 *     ),
 *     @OA\License(
 *         name="MIT",
 *         url="https://opensource.org/licenses/MIT"
 *     )
 * )
 * 
 * @OA\Server(
 *     url=L5_SWAGGER_CONST_HOST,
 *     description="API Server"
 * )
 * 
 * @OA\Tag(
 *     name="Authentication",
 *     description="API Endpoints for User Authentication"
 * )
 * @OA\Tag(
 *     name="Stores",
 *     description="API Endpoints for Managing Stores"
 * )
 * @OA\Tag(
 *     name="Products",
 *     description="API Endpoints for Managing Products"
 * )
 * @OA\Tag(
 *     name="Consignments",
 *     description="API Endpoints for Managing Consignments"
 * )
 * @OA\Tag(
 *     name="Transactions",
 *     description="API Endpoints for Managing Transactions"
 * )
 * 
 * @OA\SecurityScheme(
 *     type="http",
 *     description="Login with email and password to get the authentication token",
 *     name="Token based",
 *     in="header",
 *     scheme="bearer",
 *     bearerFormat="JWT",
 *     securityScheme="bearerAuth"
 * )
 */
class Documentation
{
    // This class is used for Swagger documentation only
}
