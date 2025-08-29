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
                    ->with(['consignment.store', 'items'])
                    ->latest()
                    ->limit(5)
            )
            ->columns([
                Tables\Columns\TextColumn::make('code')
                    ->label('Kode')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('transaction_date')
                    ->label('Tanggal')
                    ->date('d M Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('consignment.store.name')
                    ->label('Toko')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('items_count')
                    ->label('Jumlah Item')
                    ->counts('items')
                    ->badge()
                    ->color('primary'),
                Tables\Columns\TextColumn::make('total_sold')
                    ->label('Total Terjual')
                    ->state(fn ($record) => $record->items->sum('sales'))
                    ->badge()
                    ->color('success')
                    ->sortable(),
                Tables\Columns\TextColumn::make('total_returned')
                    ->label('Total Dikembalikan')
                    ->state(fn ($record) => $record->items->sum('return'))
                    ->badge()
                    ->color('warning')
                    ->sortable(),
                Tables\Columns\TextColumn::make('total_amount')
                    ->label('Total')
                    ->money('IDR')
                    ->state(fn ($record) => $record->items->sum(fn($item) => $item->price * $item->sales))
                    ->sortable(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->url(fn(Transaction $record): string => route('filament.admin.resources.transactions.view', $record->id)),
            ])
            ->emptyStateHeading('Belum ada data transaksi')
            ->emptyStateDescription('Buat transaksi baru untuk memulai');
    }

    // public static function canView(): bool
    // {
    //     return auth()->user()->can('viewAny', Transaction::class);
    // }
}
