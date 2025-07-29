<?php

namespace App\Http\Requests;

use App\Models\Consignment;
use App\Models\Transaction;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateTransactionRequest extends FormRequest
{
    /**
     * The transaction instance being updated.
     *
     * @var \App\Models\Transaction
     */
    protected $transaction;

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
        $this->transaction = $this->route('transaction');
        
        return [
            'sold_quantity' => 'sometimes|required|integer|min:0',
            'returned_quantity' => 'sometimes|required|integer|min:0',
            'transaction_date' => 'sometimes|required|date|before_or_equal:today',
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
            if (!$this->transaction) {
                return;
            }

            $consignment = $this->transaction->consignment;
            if (!$consignment) {
                return;
            }

            // Get current transaction quantities
            $currentSold = $this->transaction->sold_quantity;
            $currentReturned = $this->transaction->returned_quantity;
            
            // Get new quantities from request or use current values
            $newSold = $this->input('sold_quantity', $currentSold);
            $newReturned = $this->input('returned_quantity', $currentReturned);
            
            // Calculate the difference
            $soldDiff = $newSold - $currentSold;
            $returnedDiff = $newReturned - $currentReturned;
            
            // Calculate remaining quantity in consignment
            $remaining = $consignment->quantity - 
                        ($consignment->transactions()->sum('sold_quantity') + $soldDiff) - 
                        ($consignment->transactions()->sum('returned_quantity') + $returnedDiff);
            
            if ($remaining < 0) {
                $totalChange = $soldDiff + $returnedDiff;
                $validator->errors()->add(
                    'quantity', 
                    "Perubahan jumlah (${totalChange}) melebihi sisa stok yang tersedia (${remaining})."
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
            'sold_quantity.required' => 'Jumlah terjual harus diisi',
            'sold_quantity.integer' => 'Jumlah terjual harus berupa angka',
            'sold_quantity.min' => 'Jumlah terjual minimal 0',
            'returned_quantity.required' => 'Jumlah dikembalikan harus diisi',
            'returned_quantity.integer' => 'Jumlah dikembalikan harus berupa angka',
            'returned_quantity.min' => 'Jumlah dikembalikan minimal 0',
            'transaction_date.required' => 'Tanggal transaksi harus diisi',
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
