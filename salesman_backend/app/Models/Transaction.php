<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class Transaction extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'consignment_id',
        'sold_quantity',
        'returned_quantity',
        'transaction_date',
        'sold_items_photo_path',
        'returned_items_photo_path',
        'notes'
    ];

    protected $appends = ['sold_items_photo_url', 'returned_items_photo_url'];

    protected $casts = [
        'transaction_date' => 'date:Y-m-d',
        'sold_quantity' => 'integer',
        'returned_quantity' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected static function booted()
    {
        static::creating(function ($transaction) {
            if (empty($transaction->transaction_date)) {
                $transaction->transaction_date = now();
            }
        });
    }

    /**
     * Get the consignment that owns the transaction.
     */
    public function consignment(): BelongsTo
    {
        return $this->belongsTo(Consignment::class);
    }

    /**
     * Get the full URL for the sold items photo.
     *
     * @return string|null
     */
    public function getSoldItemsPhotoUrlAttribute()
    {
        return $this->sold_items_photo_path ? Storage::disk('public')->url($this->sold_items_photo_path) : null;
    }

    /**
     * Get the full URL for the returned items photo.
     *
     * @return string|null
     */
    public function getReturnedItemsPhotoUrlAttribute()
    {
        return $this->returned_items_photo_path ? Storage::disk('public')->url($this->returned_items_photo_path) : null;
    }

    /**
     * Scope a query to only include transactions for a specific consignment.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @param  int  $consignmentId
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeForConsignment($query, $consignmentId)
    {
        return $query->where('consignment_id', $consignmentId);
    }

    /**
     * Scope a query to only include transactions within a date range.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @param  string|null  $fromDate
     * @param  string|null  $toDate
     * @return \Illuminate\Database\Eloquent\Builder
     */
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
}
