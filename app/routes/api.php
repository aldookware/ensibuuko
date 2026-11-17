<?php

use App\Http\Controllers\TransactionReportController;
use Illuminate\Support\Facades\Route;

Route::get('/reports/transactions', TransactionReportController::class);
