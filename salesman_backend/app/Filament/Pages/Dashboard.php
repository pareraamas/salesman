<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\ConsignmentStats;
use App\Filament\Widgets\RecentConsignments;
use App\Filament\Widgets\RecentTransactions;
use App\Filament\Widgets\StoresOverview;
use Filament\Pages\Dashboard as BaseDashboard;

class Dashboard extends BaseDashboard
{
    protected static ?string $navigationIcon = 'heroicon-o-home';
    
    protected static ?string $navigationLabel = 'Dashboard';
    
    protected static ?int $navigationSort = -2;
    
    protected function getHeaderWidgets(): array
    {
        return [
            StoresOverview::class,
            ConsignmentStats::class,
        ];
    }
    
    protected function getFooterWidgets(): array
    {
        return [
            RecentConsignments::class,
            RecentTransactions::class,
        ];
    }
    
    public function getColumns(): int | string | array
    {
        return 1;
    }
    
    public function getTitle(): string
    {
        return 'Dashboard';
    }
}
