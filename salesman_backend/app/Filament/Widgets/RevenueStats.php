<?php

namespace App\Filament\Widgets;

use App\Models\ProductItem;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Number;

class RevenueStats extends BaseWidget
{
    protected function getStats(): array
    {
        $totalRevenue = ProductItem::where('sales', '>', 0)
            ->sum(DB::raw('sales * price'));
            
        $monthlyRevenue = ProductItem::where('sales', '>', 0)
            ->whereMonth('updated_at', now()->month)
            ->sum(DB::raw('sales * price'));
            
        $dailyRevenue = ProductItem::where('sales', '>', 0)
            ->whereDate('updated_at', today())
            ->sum(DB::raw('sales * price'));

        return [
            Stat::make('Total Pendapatan', 'Rp ' . number_format($totalRevenue, 0, ',', '.'))
                ->description('Total pendapatan dari penjualan')
                ->descriptionIcon('heroicon-o-currency-dollar')
                ->color('success'),
                
            Stat::make('Pendapatan Bulan Ini', 'Rp ' . number_format($monthlyRevenue, 0, ',', '.'))
                ->description('Pendapatan pada ' . now()->translatedFormat('F Y'))
                ->descriptionIcon('heroicon-o-calendar')
                ->color('primary'),
                
            Stat::make('Pendapatan Hari Ini', 'Rp ' . number_format($dailyRevenue, 0, ',', '.'))
                ->description('Pendapatan pada ' . today()->translatedFormat('d F Y'))
                ->descriptionIcon('heroicon-o-sun')
                ->color('info'),
        ];
    }
}
