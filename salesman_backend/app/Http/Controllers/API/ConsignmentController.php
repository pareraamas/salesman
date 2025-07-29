<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreConsignmentRequest;
use App\Http\Requests\UpdateConsignmentRequest;
use App\Models\Consignment;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ConsignmentController extends BaseController
{
    /**
     * @OA\Get(
     *     path="/api/consignments",
     *     operationId="getConsignmentsList",
     *     tags={"Consignments"},
     *     summary="Get list of consignments with optional filters",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="store_id",
     *         in="query",
     *         description="Filter by store ID",
     *         required=false,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Parameter(
     *         name="product_id",
     *         in="query",
     *         description="Filter by product ID",
     *         required=false,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Parameter(
     *         name="status",
     *         in="query",
     *         description="Filter by status (active, sold, returned)",
     *         required=false,
     *         @OA\Schema(type="string", enum={"active", "sold", "returned"})
     *     ),
     *     @OA\Parameter(
     *         name="from_date",
     *         in="query",
     *         description="Filter by consignment date from (YYYY-MM-DD)",
     *         required=false,
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="to_date",
     *         in="query",
     *         description="Filter by consignment date to (YYYY-MM-DD)",
     *         required=false,
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="per_page",
     *         in="query",
     *         description="Items per page",
     *         required=false,
     *         @OA\Schema(type="integer", default=15)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array",
     *                 @OA\Items(ref="#/components/schemas/Consignment")
     *             ),
     *             @OA\Property(property="message", type="string", example="Consignments retrieved successfully")
     *         )
     *     )
     * )
     */
    public function index(Request $request)
    {
        $query = Consignment::with(['store', 'product']);

        // Apply filters
        if ($request->has('store_id')) {
            $query->where('store_id', $request->store_id);
        }

        if ($request->has('product_id')) {
            $query->where('product_id', $request->product_id);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('from_date')) {
            $query->whereDate('consignment_date', '>=', $request->from_date);
        }

        if ($request->has('to_date')) {
            $query->whereDate('consignment_date', '<=', $request->to_date);
        }

        $perPage = $request->input('per_page', 15);
        $consignments = $query->latest('consignment_date')->paginate($perPage);

        return $this->sendResponse($consignments, 'Consignments retrieved successfully');
    }

    /**
     * @OA\Post(
     *     path="/api/consignments",
     *     operationId="storeConsignment",
     *     tags={"Consignments"},
     *     summary="Create a new consignment",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/ConsignmentInput")
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Consignment created successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Consignment"),
     *             @OA\Property(property="message", type="string", example="Consignment created successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error"
     *     )
     * )
     */
    public function store(StoreConsignmentRequest $request)
    {
        $data = $request->validated();
        
        // Handle photo upload
        if ($request->hasFile('photo')) {
            $data['photo_path'] = $request->file('photo')->store('consignments', 'public');
        }

        $consignment = Consignment::create($data);
        $consignment->load(['store', 'product']);

        return $this->sendResponse($consignment, 'Consignment created successfully', 201);
    }

    /**
     * @OA\Get(
     *     path="/api/consignments/{id}",
     *     operationId="getConsignmentById",
     *     tags={"Consignments"},
     *     summary="Get consignment details",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="Consignment ID",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Consignment retrieved successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Consignment"),
     *             @OA\Property(property="message", type="string", example="Consignment retrieved successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Consignment not found"
     *     )
     * )
     */
    public function show(Consignment $consignment)
    {
        $consignment->load(['store', 'product', 'transactions']);
        return $this->sendResponse($consignment, 'Consignment retrieved successfully');
    }

    /**
     * @OA\Put(
     *     path="/api/consignments/{id}",
     *     operationId="updateConsignment",
     *     tags={"Consignments"},
     *     summary="Update consignment details",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="Consignment ID",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/ConsignmentInput")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Consignment updated successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Consignment"),
     *             @OA\Property(property="message", type="string", example="Consignment updated successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Consignment not found"
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error"
     *     )
     * )
     */
    public function update(UpdateConsignmentRequest $request, Consignment $consignment)
    {
        $data = $request->validated();
        
        // Handle photo upload
        if ($request->hasFile('photo')) {
            // Delete old photo if exists
            if ($consignment->photo_path) {
                Storage::disk('public')->delete($consignment->photo_path);
            }
            $data['photo_path'] = $request->file('photo')->store('consignments', 'public');
        }

        $consignment->update($data);
        $consignment->load(['store', 'product']);

        return $this->sendResponse($consignment, 'Consignment updated successfully');
    }

    /**
     * @OA\Delete(
     *     path="/api/consignments/{id}",
     *     operationId="deleteConsignment",
     *     tags={"Consignments"},
     *     summary="Delete a consignment",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="Consignment ID",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Consignment deleted successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Consignment deleted successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Consignment not found"
     *     )
     * )
     */
    public function destroy(Consignment $consignment)
    {
        // Delete photo if exists
        if ($consignment->photo_path) {
            Storage::disk('public')->delete($consignment->photo_path);
        }

        $consignment->delete();

        return $this->sendResponse([], 'Consignment deleted successfully');
    }

    /**
     * @OA\Post(
     *     path="/api/consignments/{id}/update-status",
     *     operationId="updateConsignmentStatus",
     *     tags={"Consignments"},
     *     summary="Update consignment status (sold/returned)",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="Consignment ID",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"status", "sold_quantity", "returned_quantity"},
     *             @OA\Property(property="status", type="string", enum={"sold", "returned"}, example="sold"),
     *             @OA\Property(property="sold_quantity", type="integer", minimum=0, example=5),
     *             @OA\Property(property="returned_quantity", type="integer", minimum=0, example=0),
     *             @OA\Property(property="notes", type="string", example="Pembayaran lunas")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Consignment status updated successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Consignment"),
     *             @OA\Property(property="message", type="string", example="Consignment status updated successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Consignment not found"
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error"
     *     )
     * )
     */
    public function updateStatus(Request $request, Consignment $consignment)
    {
        $validated = $request->validate([
            'status' => 'required|in:sold,returned',
            'sold_quantity' => 'required|integer|min:0',
            'returned_quantity' => 'required|integer|min:0',
            'notes' => 'nullable|string|max:1000',
        ]);

        // Check if total sold + returned doesn't exceed the original quantity
        $total = $validated['sold_quantity'] + $validated['returned_quantity'];
        if ($total > $consignment->quantity) {
            return $this->sendError(
                'Total jumlah terjual dan dikembalikan melebihi jumlah awal (' . $consignment->quantity . ')'
            );
        }

        // Update consignment status
        $consignment->update(['status' => $validated['status']]);

        // Create transaction record
        $consignment->transactions()->create([
            'sold_quantity' => $validated['sold_quantity'],
            'returned_quantity' => $validated['returned_quantity'],
            'transaction_date' => now(),
            'notes' => $validated['notes'] ?? null,
        ]);

        // Reload relationships
        $consignment->load(['store', 'product', 'transactions']);

        return $this->sendResponse($consignment, 'Consignment status updated successfully');
    }
}
