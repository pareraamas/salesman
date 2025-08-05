<?php

namespace App\Filament\Widgets;

use App\Models\Consignment;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class ConsignmentStats extends BaseWidget
{
    protected function getStats(): array
    {
        $total = Consignment::count();
        $active = Consignment::where('status', 'active')->count();
        $sold = Consignment::where('status', 'sold')->count();
        $returned = Consignment::where('status', 'returned')->count();

        return [
            Stat::make('Total Konsinyasi', $total)
                ->description('Jumlah seluruh konsinyasi')
                ->descriptionIcon('heroicon-o-document-chart-bar')
                ->color('primary')
                ->url(route('filament.admin.resources.konsinyasi.index')),

            Stat::make('Aktif', $active)
                ->description('Konsinyasi yang masih aktif')
                ->descriptionIcon('heroicon-o-arrow-path')
                ->color('success')
                ->chart([5, 10, 12, 8, 15, 12, 8])
                ->url(route('filament.admin.resources.konsinyasi.index', ['tableFilters[status][value]' => 'active'])),

            Stat::make('Terjual', $sold)
                ->description('Konsinyasi yang sudah terjual')
                ->descriptionIcon('heroicon-o-banknotes')
                ->color('primary')
                ->chart([2, 3, 4, 5, 6, 7, 8])
                ->url(route('filament.admin.resources.konsinyasi.index', ['tableFilters[status][value]' => 'sold'])),

            Stat::make('Dikembalikan', $returned)
                ->description('Konsinyasi yang dikembalikan')
                ->descriptionIcon('heroicon-o-arrow-uturn-left')
                ->color('warning')
                ->chart([8, 7, 6, 5, 4, 3, 2])
                ->url(route('filament.admin.resources.konsinyasi.index', ['tableFilters[status][value]' => 'returned'])),
        ];
    }

    // public static function canView(): bool
    // {
    //     return auth()->user()->can('viewAny', Consignment::class);
    // }
}
