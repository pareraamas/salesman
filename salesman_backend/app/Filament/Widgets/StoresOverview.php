<?php

namespace App\Filament\Widgets;

use App\Models\Store;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StoresOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $totalStores = Store::count();
        $activeStores = Store::has('activeConsignments')->count();
        $inactiveStores = $totalStores - $activeStores;

        return [
            Stat::make('Total Toko', $totalStores)
                ->description('Jumlah seluruh toko yang terdaftar')
                ->descriptionIcon('heroicon-o-building-storefront')
                ->color('primary')
                ->chart([7, 3, 4, 5, 6, 3, 5, 14])
                ->url(route('filament.admin.resources.stores.index')),

            Stat::make('Toko Aktif', $activeStores)
                ->description('Toko dengan konsinyasi aktif')
                ->descriptionIcon('heroicon-o-check-circle')
                ->color('success')
                ->chart([5, 3, 10, 15, 8, 7, 15, 5])
                ->url(route('filament.admin.resources.konsinyasi.index', ['tableFilters[status][value]' => 'active'])),

            Stat::make('Toko Non-Aktif', $inactiveStores)
                ->description('Toko tanpa konsinyasi aktif')
                ->descriptionIcon('heroicon-o-x-circle')
                ->color('gray')
                ->chart([17, 3, 10, 5, 8, 3, 15, 5])
                ->url(route('filament.admin.resources.stores.index', ['tableFilters[has_active_consignments][value]' => '0'])),
        ];
    }

    // public static function canView(): bool
    // {
    //     return auth()->user()->can('viewAny', Store::class);
    // }
}
