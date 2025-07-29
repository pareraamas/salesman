<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TransactionResource\Pages;
use App\Filament\Resources\TransactionResource\RelationManagers;
use App\Models\Transaction;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

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
        return $form
            ->schema([
                Forms\Components\Section::make('Informasi Transaksi')
                    ->schema([
                        Forms\Components\Select::make('consignment_id')
                            ->label('Konsinyasi')
                            ->relationship('consignment', 'code')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->disabled(fn ($operation) => $operation === 'edit')
                            ->createOptionForm([
                                Forms\Components\Select::make('store_id')
                                    ->label('Toko')
                                    ->relationship('store', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Forms\Components\Select::make('product_id')
                                    ->label('Produk')
                                    ->relationship('product', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Forms\Components\TextInput::make('quantity')
                                    ->label('Jumlah')
                                    ->numeric()
                                    ->minValue(1)
                                    ->required(),
                                Forms\Components\DatePicker::make('consignment_date')
                                    ->label('Tanggal Konsinyasi')
                                    ->default(now())
                                    ->required(),
                                Forms\Components\DatePicker::make('pickup_date')
                                    ->label('Tanggal Pengambilan')
                                    ->default(now()->addWeek())
                                    ->required(),
                            ])
                            ->createOptionAction(function (Forms\Components\Actions\Action $action) {
                                return $action
                                    ->modalHeading('Buat Konsinyasi Baru')
                                    ->modalButton('Buat Konsinyasi')
                                    ->modalWidth('2xl');
                            })
                            ->afterStateUpdated(function ($state, Forms\Set $set) {
                                $consignment = \App\Models\Consignment::find($state);
                                if ($consignment) {
                                    $set('sold_quantity', $consignment->quantity);
                                }
                            }),
                        Forms\Components\DatePicker::make('transaction_date')
                            ->label('Tanggal Transaksi')
                            ->default(now())
                            ->required(),
                        Forms\Components\TextInput::make('sold_quantity')
                            ->label('Jumlah Terjual')
                            ->numeric()
                            ->minValue(0)
                            ->default(0)
                            ->required(),
                        Forms\Components\FileUpload::make('sold_items_photo_path')
                            ->label('Foto Barang Terjual')
                            ->image()
                            ->directory('transactions/sold')
                            ->columnSpanFull(),
                        Forms\Components\TextInput::make('returned_quantity')
                            ->label('Jumlah Dikembalikan')
                            ->numeric()
                            ->minValue(0)
                            ->default(0)
                            ->required(),
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
                Tables\Columns\TextColumn::make('code')
                    ->label('Kode')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('consignment.code')
                    ->label('Kode Konsinyasi')
                    ->searchable()
                    ->sortable()
                    ->url(fn ($record) => route('filament.admin.resources.konsinyasi/' . $record->consignment_id, ['record' => $record->consignment_id])),
                Tables\Columns\TextColumn::make('consignment.store.name')
                    ->label('Toko')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('consignment.product.name')
                    ->label('Produk')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('sold_quantity')
                    ->label('Terjual')
                    ->numeric()
                    ->sortable()
                    ->color('success')
                    ->formatStateUsing(fn ($state) => $state > 0 ? $state : '-')
                    ->badge(fn ($state) => $state > 0),
                Tables\Columns\TextColumn::make('returned_quantity')
                    ->label('Dikembalikan')
                    ->numeric()
                    ->sortable()
                    ->color('warning')
                    ->formatStateUsing(fn ($state) => $state > 0 ? $state : '-')
                    ->badge(fn ($state) => $state > 0),
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
