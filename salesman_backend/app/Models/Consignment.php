<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Storage;

class Consignment extends Model
{
    use SoftDeletes;

    public const STATUS_ACTIVE = 'active';
    public const STATUS_SOLD = 'sold';
    public const STATUS_RETURNED = 'returned';

    protected $fillable = [
        'code',
        'store_id',
        'quantity',
        'consignment_date',
        'pickup_date',
        'status',
        'photo_path',
        'notes'
    ];

    /**
     * The "booting" method of the model.
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($consignment) {
            if (empty($consignment->code)) {
                $count = static::withTrashed()->count() + 1;
                $consignment->code = 'CONS-' . str_pad($count, 5, '0', STR_PAD_LEFT);

                // Ensure the code is unique
                while (static::where('code', $consignment->code)->withTrashed()->exists()) {
                    $count++;
                    $consignment->code = 'CONS-' . str_pad($count, 5, '0', STR_PAD_LEFT);
                }
            }
        });
    }

    protected $appends = ['photo_url', 'sold_quantity', 'returned_quantity', 'remaining_quantity'];

    protected $casts = [
        'consignment_date' => 'date:Y-m-d',
        'pickup_date' => 'date:Y-m-d',
        'quantity' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    /**
     * Get the store that owns the consignment.
     */
    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }

    /**
     * Get the product that owns the consignment.
     */
    public function products(): BelongsToMany
    {
        return $this->belongsToMany(ProductItem::class);
    }

    /**
     * Get the transactions for the consignment.
     */
    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class);
    }

    /**
     * Get the full URL for the consignment's photo.
     *
     * @return string|null
     */
    public function getPhotoUrlAttribute()
    {
        return $this->photo_path ? Storage::disk('public')->url($this->photo_path) : null;
    }

    /**
     * Get the total quantity of sold items.
     *
     * @return int
     */
    public function getSoldQuantityAttribute()
    {
        return $this->transactions()->sum('sold_quantity');
    }

    /**
     * Get the total quantity of returned items.
     *
     * @return int
     */
    public function getReturnedQuantityAttribute()
    {
        return $this->transactions()->sum('returned_quantity');
    }

    /**
     * Get the remaining quantity of items.
     *
     * @return int
     */
    public function getRemainingQuantityAttribute()
    {
        return $this->quantity - $this->sold_quantity - $this->returned_quantity;
    }

    /**
     * Scope a query to only include active consignments.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeActive($query)
    {
        return $query->where('status', self::STATUS_ACTIVE);
    }
}
