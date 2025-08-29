<?php

namespace App\Filament\Widgets;

use App\Models\Consignment;
use App\Models\ProductItem;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Number;

class ConsignmentStats extends BaseWidget
{
    protected function getStats(): array
    {
        $total = Consignment::count();
        $active = Consignment::where('status', 'active')->count();
        $done = Consignment::where('status', 'done')->count();
        
        $totalItems = ProductItem::count();
        $soldItems = ProductItem::where('sales', '>', 0)->sum('sales');
        $returnedItems = ProductItem::where('return', '>', 0)->sum('return');

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
                ->url(route('filament.admin.resources.konsinyasi.index', ['tableFilters[status][value]' => 'active'])),

            Stat::make('Selesai', $done)
                ->description('Konsinyasi yang sudah selesai')
                ->descriptionIcon('heroicon-o-check-circle')
                ->color('success')
                ->url(route('filament.admin.resources.konsinyasi.index', ['tableFilters[status][value]' => 'done'])),
                
            Stat::make('Barang Terjual', $soldItems)
                ->description('Total barang terjual')
                ->descriptionIcon('heroicon-o-shopping-bag')
                ->color('primary'),
                
            Stat::make('Barang Dikembalikan', $returnedItems)
                ->description('Total barang dikembalikan')
                ->descriptionIcon('heroicon-o-arrow-uturn-left')
                ->color('warning'),
        ];
    }

    // public static function canView(): bool
    // {
    //     return auth()->user()->can('viewAny', Consignment::class);
    // }
}
