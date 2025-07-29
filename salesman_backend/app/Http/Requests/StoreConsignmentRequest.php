<?php

namespace App\Http\Requests;

use App\Models\Consignment;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreConsignmentRequest extends FormRequest
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
            'store_id' => 'required|exists:stores,id',
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'consignment_date' => 'required|date|before_or_equal:today',
            'pickup_date' => 'required|date|after:consignment_date',
            'status' => [
                'required',
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
            'store_id.required' => 'Toko harus dipilih',
            'product_id.required' => 'Produk harus dipilih',
            'quantity.required' => 'Jumlah barang harus diisi',
            'quantity.min' => 'Jumlah barang minimal 1',
            'consignment_date.required' => 'Tanggal penitipan harus diisi',
            'consignment_date.before_or_equal' => 'Tanggal penitipan tidak boleh melebihi tanggal hari ini',
            'pickup_date.required' => 'Tanggal pengambilan harus diisi',
            'pickup_date.after' => 'Tanggal pengambilan harus setelah tanggal penitipan',
            'status.required' => 'Status harus diisi',
            'status.in' => 'Status tidak valid',
            'photo.image' => 'File harus berupa gambar',
            'photo.mimes' => 'Format gambar yang didukung: jpeg, png, jpg, gif',
            'photo.max' => 'Ukuran gambar maksimal 2MB',
        ];
    }
}
