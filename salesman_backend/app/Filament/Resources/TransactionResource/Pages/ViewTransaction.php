<?php

namespace App\Filament\Resources\TransactionResource\Pages;

use App\Filament\Resources\TransactionResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists\Components;
use Filament\Infolists\Infolist;
use Filament\Infolists\Component\TextEntry;
use Filament\Infolists\Component\Section as InfoSection;

class ViewTransaction extends ViewRecord
{
    protected static string $resource = TransactionResource::class;

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
                Components\Section::make('Informasi Transaksi')
                    ->schema([
                        Components\Split::make([
                            Components\Grid::make(2)
                                ->schema([
                                    Components\Group::make([
                                        Components\TextEntry::make('code')
                                            ->label('Kode Transaksi')
                                            ->size(TextEntry\TextEntrySize::Large)
                                            ->weight('font-bold'),
                                        Components\TextEntry::make('transaction_date')
                                            ->label('Tanggal Transaksi')
                                            ->dateTime('d M Y H:i'),
                                    ])->columnSpan(1),
                                ]),
                        ]),

                        InfoSection::make('Detail Konsinyasi')
                            ->schema([
                                Components\TextEntry::make('consignment.code')
                                    ->label('Kode Konsinyasi')
                                    ->url(fn ($record) => route('filament.admin.resources.konsinyasi/' . $record->consignment_id, ['record' => $record->consignment_id])),
                                Components\TextEntry::make('consignment.store.name')
                                    ->label('Toko')
                                    ->url(fn ($record) => route('filament.admin.resources.stores/' . $record->consignment->store_id, ['record' => $record->consignment->store_id])),
                                Components\TextEntry::make('consignment.product.name')
                                    ->label('Produk')
                                    ->url(fn ($record) => route('filament.admin.resources.products/' . $record->consignment->product_id, ['record' => $record->consignment->product_id])),
                            ])
                            ->columns(3),

                        InfoSection::make('Detail Transaksi')
                            ->schema([
                                Components\TextEntry::make('sold_quantity')
                                    ->label('Jumlah Terjual')
                                    ->badge()
                                    ->color('success')
                                    ->formatStateUsing(fn ($state) => $state > 0 ? $state : '-'),
                                Components\TextEntry::make('returned_quantity')
                                    ->label('Jumlah Dikembalikan')
                                    ->badge()
                                    ->color('warning')
                                    ->formatStateUsing(fn ($state) => $state > 0 ? $state : '-'),
                            ])
                            ->columns(2),

                        InfoSection::make('Foto Bukti')
                            ->schema([
                                Components\ImageEntry::make('sold_items_photo_path')
                                    ->label('Barang Terjual')
                                    ->visible(fn ($record) => $record->sold_items_photo_path)
                                    ->columnSpan(1),
                                Components\ImageEntry::make('returned_items_photo_path')
                                    ->label('Barang Dikembalikan')
                                    ->visible(fn ($record) => $record->returned_items_photo_path)
                                    ->columnSpan(1),
                            ])
                            ->columns(2)
                            ->visible(fn ($record) => $record->sold_items_photo_path || $record->returned_items_photo_path),

                        InfoSection::make('Catatan')
                            ->schema([
                                Components\TextEntry::make('notes')
                                    ->label('')
                                    ->columnSpanFull()
                                    ->markdown()
                                    ->hidden(fn ($record) => !$record->notes),
                            ])
                            ->hidden(fn ($record) => !$record->notes),
                    ]),

                Components\Section::make('Informasi Sistem')
                    ->schema([
                        Components\TextEntry::make('created_at')
                            ->label('Dibuat')
                            ->dateTime('d M Y H:i'),
                        Components\TextEntry::make('updated_at')
                            ->label('Diperbarui')
                            ->dateTime('d M Y H:i'),
                    ])
                    ->columns(2)
                    ->collapsible(),
            ]);
    }
}
