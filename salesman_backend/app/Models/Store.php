<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Storage;
use App\Models\Consignment;

class Store extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'name',
        'address',
        'phone',
        'owner_name',
        'latitude',
        'longitude',
        'photo_path'
    ];

    protected $appends = ['photo_url'];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    /**
     * Get the consignments for the store.
     */
    public function consignments(): HasMany
    {
        return $this->hasMany(Consignment::class);
    }

    /**
     * Get the active consignments for the store.
     */
    public function activeConsignments(): HasMany
    {
        return $this->hasMany(Consignment::class)->where('status', 'active');
    }

    /**
     * Get the full URL for the store's photo.
     *
     * @return string|null
     */
    // public function getPhotoUrlAttribute()
    // {
    //     return $this->photo_path ? Storage::disk('public')->url($this->photo_path) : null;
    // }
}
