<?php

namespace App\Filament\Widgets;

use App\Models\Transaction;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;

class RecentTransactions extends BaseWidget
{
    protected int | string | array $columnSpan = 'full';

    protected static ?string $heading = 'Transaksi Terbaru';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Transaction::query()
                    ->with(['consignment.store', 'consignment.product'])
                    ->latest()
                    ->limit(5)
            )
            ->columns([
                Tables\Columns\TextColumn::make('code')
                    ->label('Kode')
                    ->searchable()
                    ->sortable(),
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
                    ->badge()
                    ->color('success')
                    ->formatStateUsing(fn ($state) => $state > 0 ? $state : '-')
                    ->sortable(),
                Tables\Columns\TextColumn::make('returned_quantity')
                    ->label('Dikembalikan')
                    ->badge()
                    ->color('warning')
                    ->formatStateUsing(fn ($state) => $state > 0 ? $state : '-')
                    ->sortable(),
                Tables\Columns\TextColumn::make('transaction_date')
                    ->label('Tanggal')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->url(fn (Transaction $record): string => route('filament.admin.resources.transactions.view', $record->id)),
            ])
            ->emptyStateHeading('Belum ada data transaksi')
            ->emptyStateDescription('Buat transaksi baru untuk memulai');
    }

    public static function canView(): bool
    {
        return auth()->user()->can('viewAny', Transaction::class);
    }
}
