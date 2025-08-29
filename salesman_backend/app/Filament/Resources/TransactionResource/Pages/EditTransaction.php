<?php

namespace App\Filament\Resources\TransactionResource\Pages;

use App\Models\ProductItem;
use App\Filament\Resources\TransactionResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\DB;

class EditTransaction extends EditRecord
{
    protected static string $resource = TransactionResource::class;

    protected array $items = [];
    protected array $previousItemIds = [];

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }

    protected function mutateFormDataBeforeFill(array $data): array
    {
        // Load the transaction with its items
        $transaction = $this->getRecord()->load('items');
        
        // Format the items data for the form
        $data['items'] = $transaction->items->map(function ($item) {
            return [
                'id' => $item->id,
                'product_id' => $item->product_id,
                'consignment_id' => $item->consignment_id,
                'name' => $item->product->name,
                'code' => $item->code,
                'price' => $item->price,
                'qty' => $item->qty,
                'sales' => $item->sales,
                'return' => $item->return,
                'subtotal' => $item->sales * $item->price
            ];
        })->toArray();

        // Store the current item IDs for comparison later
        $this->previousItemIds = collect($data['items'])->pluck('id')->toArray();

        return $data;
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Store the items data before saving
        $this->items = $data['items'] ?? [];
        unset($data['items']);

        return $data;
    }

    protected function afterSave(): void
    {
        $record = $this->getRecord();

        // Get current item IDs from the form
        $currentItemIds = collect($this->items)->pluck('id')->toArray();

        // Detach items that were removed from the form
        $removedItemIds = array_diff($this->previousItemIds, $currentItemIds);
        if (!empty($removedItemIds)) {
            ProductItem::whereIn('id', $removedItemIds)
                ->where('transaction_id', $record->id)
                ->update([
                    'transaction_id' => null,
                    'sales' => 0,
                    'return' => 0
                ]);
        }

        // Update or add items
        if (isset($this->items) && is_array($this->items)) {
            foreach ($this->items as $itemData) {
                $productItem = ProductItem::find($itemData['id'] ?? null);

                if ($productItem) {

                    // Update the product item
                    $productItem->update([
                        'transaction_id' => $record->id,
                        'sales' => $itemData['sales'] ?? 0,
                        'return' => $itemData['return'] ?? 0
                    ]);
                }
            }
        }
    }
}
