<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class TransactionReportController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $rows = DB::select(<<<'SQL'
            SELECT
                c.country AS Country,
                c.Saccos AS Saccos,
                a.Deposit AS Deposit,
                b.Withdrawal AS Withdrawal,
                (a.Deposit - b.Withdrawal) AS Net
            FROM (
                SELECT SUM(t.amount) AS Deposit, s.country AS country
                FROM transactions t
                INNER JOIN individuals i ON t.individual_id = i.id
                INNER JOIN saccos s ON i.sacco_id = s.id
                WHERE t.type = 'deposit'
                GROUP BY s.country
            ) a
            INNER JOIN (
                SELECT SUM(t.amount) AS Withdrawal, s.country AS country
                FROM transactions t
                INNER JOIN individuals i ON t.individual_id = i.id
                INNER JOIN saccos s ON i.sacco_id = s.id
                WHERE t.type = 'withdrawal'
                GROUP BY s.country
            ) b ON a.country = b.country
            INNER JOIN (
                SELECT COUNT(id) AS Saccos, country
                FROM saccos
                GROUP BY country
            ) c ON a.country = c.country
            ORDER BY c.country
            SQL);

        return response()->json([
            'rows' => $rows,
            'total_withdrawals' => array_sum(array_column($rows, 'Withdrawal')),
            'total_deposits' => array_sum(array_column($rows, 'Deposit')),
            'total_saccos' => array_sum(array_column($rows, 'Saccos')),
            'total_netgains' => array_sum(array_column($rows, 'Net')),
        ]);
    }
}
