<?php

namespace App\Filament\Resources\TransactionResource\Pages;

use App\Filament\Resources\TransactionResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists\Components;
use Filament\Infolists\Infolist;
use Filament\Support\Enums\FontWeight;
use Filament\Support\Enums\FontFamily;
use Illuminate\Support\Facades\DB;
use App\Models\ProductItem;

class ViewTransaction extends ViewRecord
{
    protected static string $resource = TransactionResource::class;

    public function mount($record): void
    {
        parent::mount($record);
        $this->record->load('items');
    }

    protected function getHeaderActions(): array
    {
        $actions = [
            Actions\EditAction::make(),
            Actions\Action::make('print')
                ->label('Cetak')
                ->icon('heroicon-o-printer')
                ->url(fn($record) => route('transactions.print', $record))
                ->openUrlInNewTab(),
        ];

        if ($this->record->consignment && $this->record->consignment->store) {
            $store = $this->record->consignment->store;

            if ($store->email) {
                $actions[] = Actions\Action::make('email')
                    ->label('Email')
                    ->icon('heroicon-o-envelope')
                    ->url(fn() => 'mailto:' . $store->email . '?subject=Transaksi ' . $this->record->code);
            }

            if ($store->phone) {
                $actions[] = Actions\Action::make('whatsapp')
                    ->label('WhatsApp')
                    ->icon('heroicon-o-chat-bubble-left-right')
                    ->url(fn() => 'https://wa.me/' . $store->phone . '?text=Halo%20' . urlencode($store->name) . ',%0A%0ABerikut%20rincian%20transaksi%20Anda:%0AKode:%20' . $this->record->code . '%0ATanggal:%20' . $this->record->transaction_date->format('d/m/Y') . '%0AStatus:%20' . $this->record->status . '%0A%0ATerima%20kasih%20telah%20bertransaksi%20dengan%20kami.');
            }
        }

        return $actions;
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
                                        Components\TextEntry::make('transaction_date')
                                            ->label('Tanggal Transaksi')
                                            ->dateTime('d M Y H:i'),
                                    ]),
                                    Components\Group::make([
                                        Components\TextEntry::make('total_sold')
                                            ->label('Total Terjual')
                                            ->badge()
                                            ->color('success')
                                            ->size('lg'),
                                        Components\TextEntry::make('total_amount')
                                            ->label('Total Nilai')
                                            ->numeric(
                                                decimalPlaces: 0,
                                                decimalSeparator: '.',
                                                thousandsSeparator: '.',
                                            )
                                            ->prefix('Rp')
                                            ->size('lg')
                                            ->weight(FontWeight::Bold),
                                    ]),
                                ]),
                        ]),

                        Components\Section::make('Detail Konsinyasi')
                            ->schema([
                                Components\TextEntry::make('consignment.code')
                                    ->label('Kode Konsinyasi')
                                    ->url(fn($record) => route('filament.admin.resources.konsinyasi.view', $record->consignment_id)),
                                Components\TextEntry::make('consignment.store.name')
                                    ->label('Toko')
                                    ->url(fn($record) => route('filament.admin.resources.stores.edit', $record->consignment->store_id)),
                                Components\TextEntry::make('items_count')
                                    ->label('Jumlah Item')
                                    ->state(fn($record) => $record->items()->count())
                                    ->badge(),
                            ])
                            ->columns(3),

                        Components\Section::make('Daftar Item Transaksi')
                            ->schema([
                                Components\RepeatableEntry::make('items')
                                    ->schema([
                                        Components\TextEntry::make('name')
                                            ->label('Nama Produk')
                                            ->weight(FontWeight::Medium)
                                            ->state(function (ProductItem $record) {
                                                return $record->name;
                                            }),
                                        Components\TextEntry::make('price')
                                            ->label('Harga Satuan')
                                            ->numeric(
                                                decimalPlaces: 0,
                                                decimalSeparator: '.',
                                                thousandsSeparator: '.',
                                            )
                                            ->prefix('Rp')
                                            ->state(function (ProductItem $record) {
                                                return $record->price;
                                            }),
                                        Components\TextEntry::make('sales')
                                            ->label('Terjual')
                                            ->badge()
                                            ->color('success')
                                            ->state(function (ProductItem $record) {
                                                return $record->sales > 0 ? $record->sales : '-';
                                            }),
                                        Components\TextEntry::make('return')
                                            ->label('Dikembalikan')
                                            ->badge()
                                            ->color('warning')
                                            ->state(function (ProductItem $record) {
                                                return $record->return > 0 ? $record->return : '-';
                                            }),
                                        Components\TextEntry::make('subtotal')
                                            ->label('Subtotal')
                                            ->numeric(
                                                decimalPlaces: 0,
                                                decimalSeparator: '.',
                                                thousandsSeparator: '.',
                                            )
                                            ->prefix('Rp')
                                            ->state(function (ProductItem $record) {
                                                return $record->sales  * $record->price;
                                            }),
                                    ])
                                    ->columns(5)
                                    ->grid(1)
                                    ->contained(false)
                                    ->columnSpanFull(),
                            ])
                            ->collapsible()
                            ->collapsed(fn($record) => $record->items->count() > 3),

                        Components\Section::make('Foto Bukti')
                            ->schema([
                                Components\ImageEntry::make('sold_items_photo_path')
                                    ->label('Barang Terjual')
                                    ->visible(fn($record) => $record->sold_items_photo_path)
                                    ->columnSpan(1),
                                Components\ImageEntry::make('returned_items_photo_path')
                                    ->label('Barang Dikembalikan')
                                    ->visible(fn($record) => $record->returned_items_photo_path)
                                    ->columnSpan(1),
                            ])
                            ->columns(2)
                            ->visible(fn($record) => $record->sold_items_photo_path || $record->returned_items_photo_path),

                        Components\Section::make('Catatan')
                            ->schema([
                                Components\TextEntry::make('notes')
                                    ->label('')
                                    ->columnSpanFull()
                                    ->markdown()
                                    ->hidden(fn($record) => !$record->notes),
                            ])
                            ->hidden(fn($record) => !$record->notes),
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
