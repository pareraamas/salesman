<?php

namespace App\Filament\Resources\ConsignmentResource\Pages;

use App\Filament\Resources\ConsignmentResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists\Components;
use Filament\Infolists\Infolist;
use Filament\Infolists\Component\TextEntry;
use Filament\Infolists\Component\Section as InfoSection;

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
                                            ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->code) . '&color=FFFFFF&background=111827&size=256')
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
                                    ])->columnSpan(1),
                                ]),
                        ]),
                        
                        InfoSection::make('Detail Konsinyasi')
                            ->schema([
                                Components\TextEntry::make('store.name')
                                    ->label('Toko')
                                    ->url(fn ($record) => route('filament.admin.resources.konsinyasi/' . $record->store_id, ['record' => $record->store_id])),
                                Components\TextEntry::make('product.name')
                                    ->label('Produk')
                                    ->url(fn ($record) => route('filament.admin.resources.products/' . $record->product_id, ['record' => $record->product_id])),
                                Components\TextEntry::make('quantity')
                                    ->label('Jumlah')
                                    ->suffix(' pcs'),
                                Components\TextEntry::make('consignment_date')
                                    ->label('Tanggal Konsinyasi')
                                    ->dateTime('d M Y'),
                                Components\TextEntry::make('pickup_date')
                                    ->label('Tanggal Pengambilan')
                                    ->dateTime('d M Y')
                                    ->color(fn ($record) => $record->pickup_date < now() ? 'danger' : null)
                                    ->description(fn ($record) => $record->pickup_date->diffForHumans()),
                            ])
                            ->columns(2),

                        InfoSection::make('Catatan')
                            ->schema([
                                Components\TextEntry::make('notes')
                                    ->label('')
                                    ->columnSpanFull()
                                    ->markdown()
                                    ->hidden(fn ($record) => !$record->notes),
                            ]),

                        InfoSection::make('Foto Bukti')
                            ->schema([
                                Components\ImageEntry::make('photo_path')
                                    ->label('')
                                    ->columnSpanFull()
                                    ->hidden(fn ($record) => !$record->photo_path),
                            ])
                            ->hidden(fn ($record) => !$record->photo_path),
                    ]),

                Components\Section::make('Riwayat Transaksi')
                    ->schema([
                        Components\Infolists\Components\Actions::make([
                            Components\Infolists\Components\Actions\Action::make('createTransaction')
                                ->label('Tambah Transaksi')
                                ->url(fn ($record) => route('filament.admin.resources.konsinyasi/' . $record->id . '/transactions/create'))
                                ->icon('heroicon-o-plus')
                                ->button(),
                        ]),
                        Components\RepeatableEntry::make('transactions')
                            ->label('')
                            ->schema([
                                Components\TextEntry::make('transaction_date')
                                    ->label('Tanggal')
                                    ->dateTime('d M Y H:i'),
                                Components\TextEntry::make('sold_quantity')
                                    ->label('Terjual')
                                    ->formatStateUsing(fn ($state) => $state ?: '-')
                                    ->badge()
                                    ->color('success'),
                                Components\TextEntry::make('returned_quantity')
                                    ->label('Dikembalikan')
                                    ->formatStateUsing(fn ($state) => $state ?: '-')
                                    ->badge()
                                    ->color('warning'),
                                Components\TextEntry::make('notes')
                                    ->label('Catatan')
                                    ->limit(50),
                            ])
                            ->columns(4)
                            ->columnSpanFull(),
                    ])
                    ->hidden(fn ($record) => $record->transactions->isEmpty()),
            ]);
    }
}
