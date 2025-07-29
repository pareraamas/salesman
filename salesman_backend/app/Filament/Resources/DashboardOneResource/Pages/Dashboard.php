<?php

namespace App\Filament\Resources\DashboardOneResource\Pages;

use App\Filament\Resources\DashboardOneResource;
use Filament\Resources\Pages\Page;

class Dashboard extends Page
{
    protected static string $resource = DashboardOneResource::class;

    protected static string $view = 'filament.resources.dashboard-one-resource.pages.dashboard';
}
