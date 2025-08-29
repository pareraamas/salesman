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

            'productItems' => 'sometimes|array|min:1',
            'productItems.*.id' => 'sometimes|exists:product_items,id',
            'productItems.*.product_id' => 'required_without:productItems.*.id|exists:products,id',
            'productItems.*.name' => 'required_without:productItems.*.id|string|max:255',
            'productItems.*.code' => 'required_without:productItems.*.id|string|max:50',
            'productItems.*.price' => 'required_without:productItems.*.id|numeric|min:0',
            'productItems.*.qty' => 'required_without:productItems.*.id|integer|min:1',
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
            'productItems.*.id.exists' => 'Item konsinyasi tidak ditemukan',
            'productItems.*.product_id.exists' => 'Produk tidak ditemukan',
            'productItems.*.qty.integer' => 'Jumlah harus berupa angka',
            'productItems.*.qty.min' => 'Jumlah minimal 1',
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
