<?php

namespace App\Filament\Resources\TransactionResource\RelationManagers;

use App\Models\ProductItem;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class ItemsRelationManager extends RelationManager
{
    protected static string $relationship = 'items';

    protected static ?string $recordTitleAttribute = 'productItem.name';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('product_item_id')
                    ->label('Produk')
                    ->options(function () {
                        $consignmentId = $this->getOwnerRecord()->consignment_id;
                        return ProductItem::where('consignment_id', $consignmentId)
                            ->where('qty', '>', 0)
                            ->pluck('name', 'id');
                    })
                    ->required()
                    ->searchable()
                    ->live()
                    ->afterStateUpdated(function ($state, Forms\Set $set) {
                        if ($item = ProductItem::find($state)) {
                            $set('price_per_unit', $item->price);
                        }
                    }),
                
                Forms\Components\TextInput::make('price_per_unit')
                    ->label('Harga Satuan')
                    ->numeric()
                    ->prefix('Rp')
                    ->required(),
                
                Forms\Components\TextInput::make('sold_quantity')
                    ->label('Terjual')
                    ->numeric()
                    ->minValue(0)
                    ->default(0)
                    ->required(),
                
                Forms\Components\TextInput::make('returned_quantity')
                    ->label('Dikembalikan')
                    ->numeric()
                    ->minValue(0)
                    ->default(0)
                    ->required(),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('productItem.name')
            ->columns([
                Tables\Columns\TextColumn::make('productItem.name')
                    ->label('Produk')
                    ->searchable()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('price_per_unit')
                    ->label('Harga Satuan')
                    ->numeric(
                        decimalPlaces: 0,
                        decimalSeparator: '.',
                        thousandsSeparator: '.',
                    )
                    ->prefix('Rp')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('sold_quantity')
                    ->label('Terjual')
                    ->numeric()
                    ->sortable()
                    ->color('success')
                    ->badge(),
                
                Tables\Columns\TextColumn::make('returned_quantity')
                    ->label('Dikembalikan')
                    ->numeric()
                    ->sortable()
                    ->color('warning')
                    ->badge(),
                
                Tables\Columns\TextColumn::make('subtotal')
                    ->label('Subtotal')
                    ->numeric(
                        decimalPlaces: 0,
                        decimalSeparator: '.',
                        thousandsSeparator: '.',
                    )
                    ->prefix('Rp')
                    ->state(fn (Model $record) => 
                        ($record->sold_quantity - $record->returned_quantity) * $record->price_per_unit
                    ),
            ])
            ->filters([
                //
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make()
                    ->mutateFormDataUsing(function (array $data): array {
                        $data['transaction_id'] = $this->getOwnerRecord()->id;
                        return $data;
                    }),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }
}
