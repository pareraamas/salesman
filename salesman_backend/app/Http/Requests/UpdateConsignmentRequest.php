<?php

namespace App\Http\Requests;

use App\Models\Consignment;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateConsignmentRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'store_id' => 'sometimes|exists:stores,id',
            'product_id' => 'sometimes|exists:products,id',
            'quantity' => 'sometimes|integer|min:1',
            'consignment_date' => 'sometimes|date',
            'pickup_date' => 'sometimes|date|after:consignment_date',
            'status' => [
                'sometimes',
                Rule::in([
                    Consignment::STATUS_ACTIVE,
                    Consignment::STATUS_SOLD,
                    Consignment::STATUS_RETURNED,
                ]),
            ],
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'notes' => 'nullable|string|max:1000',
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'store_id.exists' => 'Toko tidak ditemukan',
            'product_id.exists' => 'Produk tidak ditemukan',
            'quantity.integer' => 'Jumlah harus berupa angka',
            'quantity.min' => 'Jumlah minimal 1',
            'consignment_date.date' => 'Format tanggal penitipan tidak valid',
            'pickup_date.date' => 'Format tanggal pengambilan tidak valid',
            'pickup_date.after' => 'Tanggal pengambilan harus setelah tanggal penitipan',
            'status.in' => 'Status tidak valid',
            'photo.image' => 'File harus berupa gambar',
            'photo.mimes' => 'Format gambar yang didukung: jpeg, png, jpg, gif',
            'photo.max' => 'Ukuran gambar maksimal 2MB',
        ];
    }
}
