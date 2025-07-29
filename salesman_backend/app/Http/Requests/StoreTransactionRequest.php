<?php

namespace App\Http\Requests;

use App\Models\Consignment;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreTransactionRequest extends FormRequest
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
            'consignment_id' => [
                'required',
                'exists:consignments,id',
                function ($attribute, $value, $fail) {
                    $consignment = Consignment::find($value);
                    if ($consignment && $consignment->status !== Consignment::STATUS_ACTIVE) {
                        $fail('Transaksi hanya dapat ditambahkan untuk konsinyasi dengan status aktif.');
                    }
                },
            ],
            'sold_quantity' => 'required|integer|min:0',
            'returned_quantity' => 'required|integer|min:0',
            'transaction_date' => 'nullable|date|before_or_equal:today',
            'sold_items_photo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'returned_items_photo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'notes' => 'nullable|string|max:1000',
        ];
    }

    /**
     * Configure the validator instance.
     *
     * @param  \Illuminate\Validation\Validator  $validator
     * @return void
     */
    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            $data = $validator->getData();
            $consignment = Consignment::find($data['consignment_id'] ?? null);
            
            if (!$consignment) {
                return;
            }

            // Calculate remaining quantity
            $remaining = $consignment->quantity - 
                        $consignment->transactions()->sum('sold_quantity') - 
                        $consignment->transactions()->sum('returned_quantity');
            
            // For new transaction, add the current quantities being processed
            $sold = $data['sold_quantity'] ?? 0;
            $returned = $data['returned_quantity'] ?? 0;
            $total = $sold + $returned;
            
            if ($total > $remaining) {
                $validator->errors()->add(
                    'quantity', 
                    "Total jumlah terjual dan dikembalikan ({$total}) melebihi sisa stok yang tersedia ({$remaining})."
                );
            }
        });
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'consignment_id.required' => 'Konsinyasi harus dipilih',
            'consignment_id.exists' => 'Konsinyasi tidak ditemukan',
            'sold_quantity.required' => 'Jumlah terjual harus diisi',
            'sold_quantity.integer' => 'Jumlah terjual harus berupa angka',
            'sold_quantity.min' => 'Jumlah terjual minimal 0',
            'returned_quantity.required' => 'Jumlah dikembalikan harus diisi',
            'returned_quantity.integer' => 'Jumlah dikembalikan harus berupa angka',
            'returned_quantity.min' => 'Jumlah dikembalikan minimal 0',
            'transaction_date.date' => 'Format tanggal transaksi tidak valid',
            'transaction_date.before_or_equal' => 'Tanggal transaksi tidak boleh melebihi hari ini',
            'sold_items_photo.image' => 'Foto barang terjual harus berupa gambar',
            'sold_items_photo.mimes' => 'Format gambar yang didukung: jpeg, png, jpg, gif',
            'sold_items_photo.max' => 'Ukuran gambar maksimal 2MB',
            'returned_items_photo.image' => 'Foto barang dikembalikan harus berupa gambar',
            'returned_items_photo.mimes' => 'Format gambar yang didukung: jpeg, png, jpg, gif',
            'returned_items_photo.max' => 'Ukuran gambar maksimal 2MB',
            'notes.max' => 'Catatan maksimal 1000 karakter',
        ];
    }
}
