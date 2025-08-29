<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TransactionResource\Pages;
use Illuminate\Database\Eloquent\Builder;
use App\Filament\Resources\TransactionResource\RelationManagers;
use App\Models\ProductItem;
use App\Models\Transaction;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class TransactionResource extends Resource
{
    protected static ?string $model = Transaction::class;

    protected static ?string $navigationIcon = 'heroicon-o-currency-dollar';

    protected static ?string $modelLabel = 'Transaksi';

    protected static ?string $navigationLabel = 'Data Transaksi';

    protected static ?string $navigationGroup = 'Transaksi';

    protected static ?string $recordTitleAttribute = 'code';

    protected static ?string $slug = 'transactions';

    public static function form(Form $form): Form
    {
        $operation = $form->getOperation();

        return $form
            ->schema([
                Forms\Components\Hidden::make('operation')
                    ->default($operation),
                Forms\Components\Section::make('Informasi Transaksi')
                    ->schema([
                        Forms\Components\Select::make('consignment_id')
                            ->label('Konsinyasi')
                            ->relationship(
                                name: 'consignment',
                                titleAttribute: 'code',
                                modifyQueryUsing: fn (Builder $query) => $query->where('status', 'active')
                            )
                            ->searchable()
                            ->preload()
                            ->required()
                            ->live()
                            ->afterStateUpdated(function ($state, Forms\Set $set, Forms\Get $get, $operation) {
                                if ($operation === 'edit') {
                                    return;
                                }

                                if (!$state) {
                                    $set('items', []);
                                    return;
                                }

                                $items = ProductItem::where('consignment_id', $state)
                                    ->get()
                                    ->map(function ($item) {
                                        return [
                                            'id' => $item->id,
                                            'product_id' => $item->product_id,
                                            'consignment_id' => $item->consignment_id,
                                            'name' => $item->product->name,
                                            'code' => $item->code,
                                            'price' => $item->price,
                                            'qty' => $item->qty,
                                            'sales' => 0,
                                            'return' => 0,
                                            'subtotal' => 0
                                        ];
                                    })
                                    ->toArray();

                                $set('items', $items);
                            })
                            ->disabled(fn($operation) => $operation === 'edit'),

                        Forms\Components\DatePicker::make('transaction_date')
                            ->label('Tanggal Transaksi')
                            ->default(now())
                            ->required(),

                        Forms\Components\Repeater::make('items')
                            ->reorderable(false)
                            ->addable(false)
                            ->deletable(false)
                            ->defaultItems(0)
                            ->schema([
                                Forms\Components\Hidden::make('id'),
                                Forms\Components\Hidden::make('product_id'),
                                Forms\Components\Hidden::make('consignment_id'),
                                Forms\Components\TextInput::make('name')
                                    ->disabled()
                                    ->columnSpan(2)
                                    ->dehydrated(),
                                Forms\Components\TextInput::make('code')
                                    ->disabled()
                                    ->dehydrated(),
                                Forms\Components\TextInput::make('qty')
                                    ->label('Jumlah')
                                    ->disabled()
                                    ->dehydrated(),
                                Forms\Components\TextInput::make('sales')
                                    ->label('Jml. Terjual')
                                    ->numeric()
                                    ->default(0)
                                    ->minValue(0)
                                    ->required()
                                    ->live()
                                    ->afterStateUpdated(function (Forms\Get $get, Forms\Set $set) {
                                        self::updateSubtotalStatic($get, $set);
                                    }),


                                Forms\Components\TextInput::make('return')
                                    ->label('Jumlah Dikembalikan')
                                    ->numeric()
                                    ->default(0)
                                    ->minValue(0)
                                    ->required()
                                    ->live()
                                    ->afterStateUpdated(function (Forms\Get $get, Forms\Set $set) {
                                        self::updateSubtotalStatic($get, $set);
                                    }),


                                Forms\Components\TextInput::make('price')
                                    ->label('Harga Satuan')
                                    ->numeric()
                                    ->prefix('Rp')
                                    ->disabled()
                                    ->dehydrated()
                                    ->default(0)
                                    ->afterStateUpdated(function (Forms\Get $get, Forms\Set $set) {
                                        self::updateSubtotalStatic($get, $set);
                                    }),

                                Forms\Components\TextInput::make('subtotal')
                                    ->label('Subtotal')
                                    ->numeric()
                                    ->prefix('Rp')
                                    ->readOnly()
                                    ->dehydrated()
                                    ->default(0)
                            ])
                            ->columns(4),

                        Forms\Components\FileUpload::make('sold_items_photo_path')
                            ->label('Foto Barang Terjual')
                            ->image()
                            ->directory('transactions/sold')
                            ->columnSpanFull(),

                        Forms\Components\FileUpload::make('returned_items_photo_path')
                            ->label('Foto Barang Dikembalikan')
                            ->image()
                            ->directory('transactions/returned')
                            ->columnSpanFull(),

                        Forms\Components\Textarea::make('notes')
                            ->label('Catatan')
                            ->columnSpanFull(),
                    ])
            ]);
    }


    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('consignment.code')
                    ->label('Kode Konsinyasi')
                    ->searchable()
                    ->sortable()
                    ->url(fn($record) => route('filament.admin.resources.konsinyasi.view', $record->consignment_id)),

                Tables\Columns\TextColumn::make('consignment.store.name')
                    ->label('Toko')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('items_count')
                    ->label('Jumlah Item')
                    ->counts('items')
                    ->sortable(),

                Tables\Columns\TextColumn::make('total_sold')
                    ->label('Total Terjual')
                    ->numeric()
                    ->sortable()
                    ->color('success')
                    ->badge(),

                Tables\Columns\TextColumn::make('total_returned')
                    ->label('Total Dikembalikan')
                    ->numeric()
                    ->sortable()
                    ->color('warning')
                    ->badge(),

                Tables\Columns\TextColumn::make('total_amount')
                    ->label('Total Nilai')
                    ->numeric(
                        decimalPlaces: 0,
                        decimalSeparator: '.',
                        thousandsSeparator: '.',
                    )
                    ->prefix('Rp')
                    ->sortable(),

                Tables\Columns\TextColumn::make('transaction_date')
                    ->label('Tanggal')
                    ->dateTime('d M Y H:i')
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime('d M Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Diperbarui')
                    ->dateTime('d M Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('consignment')
                    ->relationship('consignment', 'code')
                    ->searchable()
                    ->preload()
                    ->label('Konsinyasi'),

                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\ForceDeleteBulkAction::make(),
                    Tables\Actions\RestoreBulkAction::make(),
                ]),
            ])
            ->emptyStateActions([
                Tables\Actions\CreateAction::make(),
            ]);
    }

    public static function getNavigationBadge(): ?string
    {
        return (string) static::getModel()::count();
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'primary';
    }

    protected static function updateSubtotalStatic(Forms\Get $get, Forms\Set $set): void
    {
        $productItemId = $get('id');
        if (!$productItemId) {
            return;
        }

        $productItem = \App\Models\ProductItem::find($productItemId);
        if (!$productItem) {
            return;
        }

        $sold = (int) ($get('sales') ?? 0);
        $price = (float) $productItem->price;

        // Calculate subtotal for this item
        $subtotal = ($sold) * $price;

        // Update the price and subtotal fields
        $set('price', $price);
        $set('subtotal', number_format($subtotal, 0, '.', ''));

        // Calculate total amount for all items
        $items = $get('../../items');
        $total = 0;

        if (is_array($items)) {
            foreach ($items as $item) {
                if (isset($item['id'])) {
                    $itemProduct = \App\Models\ProductItem::find($item['id']);
                    if ($itemProduct) {
                        $itemSold = (int) ($item['sales'] ?? 0);
                        $total += ($itemSold) * $itemProduct->price;
                    }
                }
            }
        }
        // Update the total amount
        $set('../../total_amount', number_format($total, 0, '.', ''));
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTransactions::route('/'),
            'create' => Pages\CreateTransaction::route('/create'),
            'view' => Pages\ViewTransaction::route('/{record}'),
            'edit' => Pages\EditTransaction::route('/{record}/edit'),
        ];
    }
}
