<?php

namespace App\Models;

use App\Models\Product;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Storage;

class ProductItem extends Model
{
    use SoftDeletes;


    protected $fillable = [
        'product_id',
        'consignment_id',
        'transaction_id',
        'name',
        'code',
        'price',
        'description',
        'qty',
        'sales',
        'return'
    ];

    protected $appends = ['photo_url'];

    protected $casts = [
        'price' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];


    /**
     * Get the full URL for the product's photo.
     *
     * @return string|null
     */
    public function getPhotoUrlAttribute()
    {
        return $this->photo_path ? Storage::disk('public')->url($this->photo_path) : null;
    }

    public function consignment()
    {
        return $this->belongsTo(Consignment::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    /**
     * Get the transaction that owns the product item.
     *
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo<\App\Models\Transaction, \App\Models\ProductItem>
     */
    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class);
    }
}
