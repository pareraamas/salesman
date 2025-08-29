<?php

namespace App\Models;

use Illuminate\Support\Facades\Log;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;
use Carbon\Carbon;

class Transaction extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'consignment_id',
        'transaction_date',
        'sold_items_photo_path',
        'returned_items_photo_path',
        'notes',
        'status',
    ];

    protected $casts = [
        'transaction_date' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected $appends = [
        'total_sold',
        'total_returned',
        'net_quantity',
        'total_amount',
    ];

    public function consignment(): BelongsTo
    {
        return $this->belongsTo(Consignment::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(ProductItem::class, 'transaction_id');
    }

    public function getTotalSoldAttribute(): int
    {
        if (!$this->relationLoaded('items')) {
            return $this->items()->sum('sales');
        }
        return $this->items->sum('sales');
    }

    public function getTotalReturnedAttribute(): int
    {
        if (!$this->relationLoaded('items')) {
            return $this->items()->sum('return');
        }
        return $this->items->sum('return');
    }

    public function getNetQuantityAttribute(): int
    {
        return $this->total_sold - $this->total_returned;
    }

    public function getTotalAmountAttribute(): float
    {
        if (!$this->relationLoaded('items')) {
            return $this->items()
                ->selectRaw('SUM(sales * price) as total')
                ->value('total') ?? 0;
        }

        return $this->items->sum(function ($item) {
            return $item->sales * $item->price;
        });
    }

    protected function getFileUrl($path)
    {
        if (!$path) {
            return null;
        }

        // Handle absolute URLs
        if (filter_var($path, FILTER_VALIDATE_URL)) {
            return $path;
        }

        // Handle storage paths
        if (str_starts_with($path, 'public/')) {
            $path = str_replace('public/', '', $path);
        }

        // Generate URL based on storage configuration
        if (config('filesystems.default') === 'local') {
            return asset('storage/' . ltrim($path, '/'));
        }

        // For cloud storage
        try {
            $disk = Storage::disk(config('filesystems.default'));
            if (method_exists($disk, 'url')) {
                return $disk->url($path);
            }
            return asset('storage/' . ltrim($path, '/'));
        } catch (\Exception $e) {
            \Log::error('Failed to generate file URL: ' . $e->getMessage());
            return null;
        }
    }

    public function getSoldItemsPhotoUrlAttribute()
    {
        return $this->getFileUrl($this->sold_items_photo_path);
    }

    public function getReturnedItemsPhotoUrlAttribute()
    {
        return $this->getFileUrl($this->returned_items_photo_path);
    }

    public function scopeForConsignment($query, $consignmentId)
    {
        return $query->where('consignment_id', $consignmentId);
    }

    public function scopeDateRange($query, $fromDate = null, $toDate = null)
    {
        if ($fromDate) {
            $query->whereDate('transaction_date', '>=', $fromDate);
        }

        if ($toDate) {
            $query->whereDate('transaction_date', '<=', $toDate);
        }

        return $query;
    }

    protected static function booted()
    {
        static::creating(function ($transaction) {
            if (empty($transaction->transaction_date)) {
                $transaction->transaction_date = now();
            }
        });

        static::saved(function ($transaction) {
            $consignment = $transaction->consignment()->with('productItems')->first();
            if (!$consignment) return;

            $totalSold = $consignment->transactions()->with('items')->get()->sum('total_sold');
            $totalItems = $consignment->productItems->sum('qty');

            if ($totalSold >= $totalItems) {
                $consignment->status = 'done';
                $consignment->save();
            }
        });
    }
}
