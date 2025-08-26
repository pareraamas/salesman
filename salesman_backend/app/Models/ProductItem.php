<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Storage;

class ProductItem extends Model
{
    use SoftDeletes;


    protected $fillable = [
        'product_id',
        'consignment_id',
        'name',
        'code',
        'price',
        'description',
        'photo_path',
        'qty',
        'selling',
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
}
