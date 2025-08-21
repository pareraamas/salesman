<?php

namespace App\Filament\Resources\StoreResource\Pages;

use App\Filament\Resources\StoreResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists\Components;
use Filament\Infolists\Infolist;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Components\Section as InfoSection;

class ViewStore extends ViewRecord
{
    protected static string $resource = StoreResource::class;

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
                Components\Section::make('Informasi Toko')
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
                                            ->label('Nama Toko')
                                            ->size(TextEntry\TextEntrySize::Large)
                                            ->weight('font-bold'),
                                        Components\TextEntry::make('owner_name')
                                            ->label('Pemilik')
                                            ->icon('heroicon-m-user'),
                                        Components\TextEntry::make('phone')
                                            ->label('Telepon')
                                            ->icon('heroicon-m-phone'),
                                    ])->columnSpan(1),
                                ]),
                        ]),
                        InfoSection::make('Detail')
                            ->schema([
                                Components\TextEntry::make('address')
                                    ->label('Alamat')
                                    ->columnSpanFull()
                                    ->markdown(),
                                Components\TextEntry::make('latitude')
                                    ->label('Koordinat')
                                    ->formatStateUsing(fn($record) => $record->latitude . ', ' . $record->longitude)
                                    ->icon('heroicon-m-map-pin'),
                            ]),
                    ]),
            ]);
    }
}
