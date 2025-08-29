<?php

namespace App\Filament\Resources\ConsignmentResource\Pages;

use App\Filament\Resources\ConsignmentResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditConsignment extends EditRecord
{
    protected static string $resource = ConsignmentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
    
    protected function mutateFormDataBeforeFill(array $data): array
    {
        $data['productItems'] = $this->record->productItems->map(function ($item) {
            return [
                'id' => $item->id,
                'product_id' => $item->product_id,
                'name' => $item->name,
                'code' => $item->code,
                'price' => $item->price,
                'qty' => $item->qty,
                'description' => $item->description,
                'photo_path' => $item->photo_path,
            ];
        })->toArray();
        
        return $data;
    }
}
