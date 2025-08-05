<?php

namespace App\Filament\Widgets;

use App\Models\Consignment;
use Carbon\Carbon;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;

class RecentConsignments extends BaseWidget
{
    protected int | string | array $columnSpan = 'full';

    protected static ?string $heading = 'Konsinyasi Terbaru';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Consignment::query()
                    ->with(['store', 'product'])
                    ->latest()
                    ->limit(5)
            )
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
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->url(fn(Consignment $record): string => route('filament.admin.resources.konsinyasi.view', $record->id)),
            ])
            ->emptyStateHeading('Belum ada data konsinyasi')
            ->emptyStateDescription('Buat konsinyasi baru untuk memulai');
    }

    // public static function canView(): bool
    // {
    //     return auth()->user()->can('viewAny', Consignment::class);
    // }
}
