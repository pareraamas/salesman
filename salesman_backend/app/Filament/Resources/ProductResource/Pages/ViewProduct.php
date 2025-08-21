<?php

namespace App\Filament\Resources\ProductResource\Pages;

use App\Filament\Resources\ProductResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists\Components;
use Filament\Infolists\Infolist;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Components\Section;


class ViewProduct extends ViewRecord
{
    protected static string $resource = ProductResource::class;

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
                Components\Section::make('Informasi Produk')
                    ->schema([
                        Components\Split::make([
                            Components\Grid::make(2)
                                ->schema([
                                    Components\Group::make([
                                        Components\ImageEntry::make('photo_path')
                                            ->label('')
                                            ->grow(false)
                                            ->circular()
                                            ->defaultImageUrl(fn($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&color=FFFFFF&background=111827&size=256')
                                            ->columnSpan(1),
                                    ]),
                                    Components\Group::make([
                                        Components\TextEntry::make('name')
                                            ->label('Nama Produk')

                                            ->weight('font-bold'),
                                        Components\TextEntry::make('code')
                                            ->label('Kode Produk')
                                            ->badge()
                                            ->color('gray'),
                                        Components\TextEntry::make('price')
                                            ->label('Harga')
                                            ->money('IDR', locale: 'id')

                                            ->weight('font-bold')
                                            ->color('success'),
                                    ])->columnSpan(1),
                                ]),
                        ]),
                        Section::make('Detail')
                            ->schema([
                                Components\TextEntry::make('description')
                                    ->label('Deskripsi')
                                    ->columnSpanFull()
                                    ->markdown(),
                                Components\TextEntry::make('created_at')
                                    ->label('Dibuat')
                                    ->dateTime('d M Y H:i'),
                                Components\TextEntry::make('updated_at')
                                    ->label('Diperbarui')
                                    ->dateTime('d M Y H:i'),
                            ]),
                    ]),
            ]);
    }
}
