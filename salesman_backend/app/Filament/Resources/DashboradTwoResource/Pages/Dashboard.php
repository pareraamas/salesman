<?php

namespace App\Filament\Resources\DashboradTwoResource\Pages;

use App\Filament\Resources\DashboradTwoResource;
use Filament\Resources\Pages\Page;

class Dashboard extends Page
{
    protected static string $resource = DashboradTwoResource::class;

    protected static string $view = 'filament.resources.dashborad-two-resource.pages.dashboard';
}
