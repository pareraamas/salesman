<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ConsignmentResource\Pages;
use App\Models\Consignment;
use App\Models\Product;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use NunoMaduro\Collision\Adapters\Phpunit\State;

class ConsignmentResource extends Resource
{
    protected static ?string $model = Consignment::class;

    protected static ?string $navigationIcon = 'heroicon-o-arrow-up-tray';

    protected static ?string $modelLabel = 'Konsinyasi';

    protected static ?string $navigationLabel = 'Data Konsinyasi';

    protected static ?string $navigationGroup = 'Transaksi';

    protected static ?string $recordTitleAttribute = 'code';

    protected static ?string $slug = 'konsinyasi';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informasi Konsinyasi')
                    ->schema([
                        Forms\Components\Select::make('store_id')
                            ->label('Toko')
                            ->relationship('store', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),
                        Forms\Components\Repeater::make('productItems')
                            ->label('Daftar Produk')
                            ->relationship()
                            ->schema([
                                Forms\Components\Select::make('product_id')
                                    ->label('Produk')
                                    ->options(\App\Models\Product::pluck('name', 'id')->toArray())
                                    ->searchable()
                                    ->preload()
                                    ->required()
                                    ->live()
                                    ->afterStateUpdated(function ($state, Forms\Set $set) {
                                        if ($product = \App\Models\Product::find($state)) {
                                            $set('name', $product->name);
                                            $set('code', $product->code);
                                            $set('price', $product->price);
                                            $set('product_id', $state);
                                        }
                                    }),
                                Forms\Components\Hidden::make('name')
                                    ->label('nama')
                                    ->required(),
                                Forms\Components\TextInput::make('code')
                                    ->label('Kode Produk')
                                    ->required(),
                                Forms\Components\TextInput::make('price')
                                    ->label('Harga')
                                    ->numeric()
                                    ->required(),
                                Forms\Components\TextInput::make('qty')
                                    ->label('Jumlah')
                                    ->numeric()
                                    ->default(1)
                                    ->minValue(1)
                                    ->required(),
                                Forms\Components\Textarea::make('description')
                                    ->label('Deskripsi')
                                    ->columnSpanFull(),
                            ])
                            ->columns(2)
                            ->defaultItems(1)
                            ->reorderable()
                            ->collapsible()
                            ->columnSpanFull(),

                        Forms\Components\DatePicker::make('consignment_date')
                            ->label('Tanggal Konsinyasi')
                            ->default(now())
                            ->required(),
                        Forms\Components\DatePicker::make('pickup_date')
                            ->label('Tanggal Pengambilan')
                            ->default(now()->addWeek())
                            ->required(),
                        Forms\Components\Select::make('status')
                            ->label('Status')
                            ->options([
                                'active' => 'Aktif',
                                'done' => 'Selesai'
                            ])
                            ->default('active')
                            ->required(),
                        Forms\Components\FileUpload::make('photo_path')
                            ->label('Foto Bukti')
                            ->image()
                            ->directory('consignments')
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
                Tables\Columns\TextColumn::make('code')
                    ->label('Kode')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('store.name')
                    ->label('Toko')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('productItems.name')
                    ->label('Produk')
                    ->searchable()
                    ->formatStateUsing(fn($record) => $record->productItems->map(fn($item) => $item->name)->join(', '))
                    ->wrap(),
                Tables\Columns\TextColumn::make('productItems.qty')
                    ->label('Jumlah')
                    ->numeric()
                    ->summarize([
                        Tables\Columns\Summarizers\Sum::make()
                    ])
                    ->formatStateUsing(fn($record) => $record->productItems->sum('qty')),
                Tables\Columns\TextColumn::make('productItems.price')
                    ->label('Harga')
                    ->money('IDR')
                    ->formatStateUsing(fn($record) => $record->productItems->sum(fn($item) => $item->price * $item->qty))
                    ->summarize([
                        Tables\Columns\Summarizers\Sum::make()
                            ->money('IDR')
                    ]),
                Tables\Columns\TextColumn::make('consignment_date')
                    ->label('Tgl Konsinyasi')
                    ->date('d M Y')
                    ->sortable(),
                Tables\Columns\TextColumn::make('pickup_date')
                    ->label('Tgl Ambil')
                    ->date('d M Y')
                    ->sortable()
                    ->color(fn($record) => $record->pickup_date < now() ? 'danger' : null)
                    ->description(fn($record) => $record->pickup_date->diffForHumans()),
                Tables\Columns\TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn(string $state): string => match ($state) {
                        'active' => 'success',
                        'returned' => 'warning',
                        'sold' => 'primary',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn(string $state): string => match ($state) {
                        'active' => 'Aktif',
                        'returned' => 'Dikembalikan',
                        'sold' => 'Terjual',
                        default => $state,
                    }),
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
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'active' => 'Aktif',
                        'returned' => 'Dikembalikan',
                        'sold' => 'Terjual',
                    ])
                    ->label('Status'),
                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
                Tables\Actions\ForceDeleteAction::make(),
                Tables\Actions\RestoreAction::make(),
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

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    protected function handleRecordCreation(array $data): Consignment
    {
        $productItems = $data['productItems'] ?? [];
        unset($data['productItems']);

        /** @var Consignment $consignment */
        $consignment = parent::handleRecordCreation($data);

        // Create product items
        foreach ($productItems as $item) {
            if (isset($item['product_id'])) {
                $consignment->productItems()->create([
                    'product_id' => $item['product_id'],
                    'name' => $item['name'],
                    'code' => $item['code'],
                    'price' => $item['price'],
                    'qty' => $item['qty'],
                    'description' => $item['description'] ?? null,
                    'photo_path' => $item['photo_path'] ?? null,
                ]);
            }
        }

        return $consignment;
    }

    protected function handleRecordUpdate(Consignment $record, array $data): Consignment
    {
        $productItems = $data['productItems'] ?? [];
        unset($data['productItems']);

        /** @var Consignment $record */
        $record = parent::handleRecordUpdate($record, $data);

        // Get existing product item IDs
        $existingIds = $record->productItems()->pluck('id')->toArray();
        $updatedIds = [];

        // Update or create product items
        foreach ($productItems as $item) {
            if (isset($item['product_id'])) {
                $productItem = $record->productItems()->updateOrCreate(
                    ['id' => $item['id'] ?? null],
                    [
                        'product_id' => $item['product_id'],
                        'name' => $item['name'],
                        'code' => $item['code'],
                        'price' => $item['price'],
                        'qty' => $item['qty'],
                        'description' => $item['description'] ?? null,
                        'photo_path' => $item['photo_path'] ?? null,
                    ]
                );
                $updatedIds[] = $productItem->id;
            }
        }

        // Delete removed product items
        $record->productItems()->whereNotIn('id', $updatedIds)->delete();

        return $record;
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListConsignments::route('/'),
            'create' => Pages\CreateConsignment::route('/create'),
            'view' => Pages\ViewConsignment::route('/{record}'),
            'edit' => Pages\EditConsignment::route('/{record}/edit'),
        ];
    }
}
