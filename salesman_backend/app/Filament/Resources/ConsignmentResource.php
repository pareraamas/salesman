<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ConsignmentResource\Pages;
use App\Filament\Resources\ConsignmentResource\RelationManagers;
use App\Models\Consignment;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

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
                            ->required()
                            ->createOptionForm([
                                Forms\Components\TextInput::make('name')
                                    ->label('Nama Toko')
                                    ->required(),
                                Forms\Components\TextInput::make('owner_name')
                                    ->label('Pemilik')
                                    ->required(),
                                Forms\Components\TextInput::make('phone')
                                    ->label('Telepon')
                                    ->tel()
                                    ->required(),
                            ])
                            ->createOptionAction(function (Forms\Components\Actions\Action $action) {
                                return $action
                                    ->modalHeading('Buat Toko Baru')
                                    ->modalButton('Buat Toko')
                                    ->modalWidth('md');
                            }),
                        Forms\Components\Select::make('product_id')
                            ->label('Produk')
                            ->relationship('product', 'name')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->createOptionForm([
                                Forms\Components\TextInput::make('name')
                                    ->label('Nama Produk')
                                    ->required(),
                                Forms\Components\TextInput::make('code')
                                    ->label('Kode Produk')
                                    ->required(),
                                Forms\Components\TextInput::make('price')
                                    ->label('Harga')
                                    ->numeric()
                                    ->required(),
                            ])
                            ->createOptionAction(function (Forms\Components\Actions\Action $action) {
                                return $action
                                    ->modalHeading('Buat Produk Baru')
                                    ->modalButton('Buat Produk')
                                    ->modalWidth('md');
                            }),
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
                        Forms\Components\Select::make('status')
                            ->label('Status')
                            ->options([
                                'active' => 'Aktif',
                                'returned' => 'Dikembalikan',
                                'sold' => 'Terjual',
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
                Tables\Columns\TextColumn::make('product.name')
                    ->label('Produk')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('quantity')
                    ->label('Jumlah')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('consignment_date')
                    ->label('Tgl Konsinyasi')
                    ->date('d M Y')
                    ->sortable(),
                Tables\Columns\TextColumn::make('pickup_date')
                    ->label('Tgl Ambil')
                    ->date('d M Y')
                    ->sortable()
                    ->color(fn ($record) => $record->pickup_date < now() ? 'danger' : null)
                    ->description(fn ($record) => $record->pickup_date->diffForHumans()),
                Tables\Columns\TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'returned' => 'warning',
                        'sold' => 'primary',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
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
