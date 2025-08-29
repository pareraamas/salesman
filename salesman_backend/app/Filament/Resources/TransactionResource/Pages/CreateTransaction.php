<?php

namespace App\Filament\Resources\TransactionResource\Pages;

use App\Models\ProductItem;
use App\Filament\Resources\TransactionResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateTransaction extends CreateRecord
{
    protected static string $resource = TransactionResource::class;

    protected array $items = [];

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Store the items data before creation
        $this->items = $data['items'] ?? [];
        unset($data['items']);

        return $data;
    }

    protected function afterCreate(): void
    {
        $record = $this->getRecord();

        // Update consignment status to done
        $consignment = $record->consignment;
        $consignment->status = 'done';
        $consignment->save();


        if (isset($this->items) && is_array($this->items)) {
            foreach ($this->items as $itemData) {
                $productItem = ProductItem::find($itemData['id'] ?? null);

                if ($productItem) {
                    // Calculate new quantity
                    // Update the existing product item
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
