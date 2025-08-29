<?php

namespace App\Filament\Resources\ConsignmentResource\Pages;

use App\Filament\Resources\ConsignmentResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists\Components;
use Filament\Infolists\Infolist;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Components\Section as InfoSection;
use App\Filament\Resources\ProductResource;


class ViewConsignment extends ViewRecord
{
    protected static string $resource = ConsignmentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
            Actions\DeleteAction::make(),
            Actions\ForceDeleteAction::make(),
            Actions\RestoreAction::make(),
        ];
    }

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Components\Section::make('Informasi Konsinyasi')
                    ->schema([
                        Components\Split::make([
                            Components\Grid::make(2)
                                ->schema([
                                    Components\Group::make([
                                        Components\ImageEntry::make('photo_path')
                                            ->label('')
                                            ->grow(false)
                                            ->circular()
                                            ->defaultImageUrl(fn($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->code) . '&color=FFFFFF&background=111827&size=256')
                                            ->columnSpan(1),
                                    ]),
                                    Components\Group::make([
                                        Components\TextEntry::make('code')
                                            ->label('Kode Konsinyasi')
                                            ->size(TextEntry\TextEntrySize::Large)
                                            ->weight('font-bold'),
                                        Components\TextEntry::make('status')
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
                                                'done' => 'Selesai',
                                                default => $state,
                                            }),
                                    ])->columnSpan(1),
                                ]),
                        ]),

                        InfoSection::make('Detail Konsinyasi')
                            ->schema([
                                Components\TextEntry::make('store.name')
                                    ->label('Toko')
                                    ->url(fn($record) => route('filament.admin.resources.stores.edit', $record->store_id)),
                                Components\RepeatableEntry::make('productItems')
                                    ->label('Daftar Produk')
                                    ->schema([
                                        Components\TextEntry::make('product.name')
                                            ->label('Produk')
                                            ->url(fn($record) => ProductResource::getUrl('edit', ['record' => $record->product_id])),
                                        Components\TextEntry::make('qty')
                                            ->label('Jumlah')
                                            ->suffix(' pcs'),
                                        Components\TextEntry::make('price')
                                            ->label('Harga')
                                            ->money('IDR'),
                                        Components\TextEntry::make('subtotal')
                                            ->label('Subtotal')
                                            ->money('IDR')
                                            ->state(fn($record) => $record->price * $record->qty),
                                    ])
                                    ->columns(4)
                                    ->columnSpanFull(),
                                Components\TextEntry::make('total')
                                    ->label('Total')
                                    ->money('IDR')
                                    ->state(fn($record) => $record->productItems->sum(fn($item) => $item->price * $item->qty))
                                    ->weight('font-bold')
                                    ->size(TextEntry\TextEntrySize::Large)
                                    ->columnSpanFull()
                                    ->alignEnd(),
                                Components\TextEntry::make('consignment_date')
                                    ->label('Tanggal Konsinyasi')
                                    ->dateTime('d M Y'),
                                Components\TextEntry::make('pickup_date')
                                    ->label('Tanggal Pengambilan')
                                    ->dateTime('d M Y')
                                    ->color(fn($record) => $record->pickup_date < now() ? 'danger' : null)
                                // ->description(fn($record) => $record->pickup_date->diffForHumans()),
                            ])
                            ->columns(2),

                        InfoSection::make('Catatan')
                            ->schema([
                                Components\TextEntry::make('notes')
                                    ->label('')
                                    ->columnSpanFull()
                                    ->markdown()
                                    ->hidden(fn($record) => !$record->notes),
                            ]),

                        InfoSection::make('Foto Bukti')
                            ->schema([
                                Components\ImageEntry::make('photo_path')
                                    ->label('')
                                    ->columnSpanFull()
                                    ->hidden(fn($record) => !$record->photo_path),
                            ])
                            ->hidden(fn($record) => !$record->photo_path),
                    ]),

                Components\Section::make('Riwayat Transaksi')
                    ->schema([
                        \Filament\Infolists\Components\Actions::make([
                            \Filament\Infolists\Components\Actions\Action::make('createTransaction')
                                ->label('Tambah Transaksi')
                                ->url(fn($record) => \App\Filament\Resources\TransactionResource::getUrl('create', [
                                    'consignment' => $record->id,
                                ]))
                                ->icon('heroicon-o-plus')
                                ->button(),
                        ]),
                        Components\RepeatableEntry::make('transactions')
                            ->label('')
                            ->schema([
                                Components\TextEntry::make('transaction_date')
                                    ->label('Tanggal')
                                    ->dateTime('d M Y H:i'),
                                Components\TextEntry::make('items_summary')
                                    ->label('Item')
                                    ->formatStateUsing(function ($record) {
                                        return $record->items->map(function ($item) {
                                            return "{$item->productItem->product->name} (Jual: {$item->sold_quantity}, Kembali: {$item->returned_quantity})";
                                        })->implode(', ');
                                    })
                                    ->columnSpan(2),
                                Components\TextEntry::make('total_sold')
                                    ->label('Total Terjual')
                                    ->formatStateUsing(fn($record) => $record->items->sum('sold_quantity') ?: '-')
                                    ->badge()
                                    ->color('success'),
                                Components\TextEntry::make('total_returned')
                                    ->label('Total Kembali')
                                    ->formatStateUsing(fn($record) => $record->items->sum('returned_quantity') ?: '-')
                                    ->badge()
                                    ->color('warning'),
                                Components\TextEntry::make('notes')
                                    ->label('Catatan')
                                    ->columnSpanFull()
                                    ->limit(50),
                            ])
                            ->columns(4)
                            ->columnSpanFull(),
                    ])
                    ->hidden(fn($record) => $record->transactions->isEmpty()),
            ]);
    }
}
