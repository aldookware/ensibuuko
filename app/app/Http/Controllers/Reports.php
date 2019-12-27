<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

class Reports extends Controller
{
    public function transactions_report(){
        $sql = "select c.country as Country, Saccos, a.Deposit, b.withdrawal as Withdrawal, (a.Deposit - Withdrawal) as Net  from
        (select sum(t.amount) as Deposit, ii.country as country from transactions t
            inner join (select i.id as Id, s.country from individuals i
                inner join saccos s on i.sacco_id = s.id) as ii on t.individual_id = ii.Id
              where t.type = 'deposit' group by country) a,

        (select sum(t.amount) as withdrawal, ii.country as country from transactions t
            inner join (select i.id as Id, s.country from individuals i
                inner join saccos s on i.sacco_id = s.id) as ii on t.individual_id = ii.Id
              where t.type = 'withdrawal' group by country) b,
        (select count(id) as Saccos, country from saccos group by country) c
where a.country=c.country  and c.country = b.country;";

        $rows = DB::select(DB::raw($sql));
        $results = array();
        $total_withdrawals = 0;
        $total_deposits = 0;
        $total_saccos = 0;
        $total_netgains = 0;

        foreach($rows as $row)
        {
            $total_withdrawals += $row->Withdrawal;
            $total_deposits += $row->Deposit;
            $total_saccos  += $row->Saccos;
            $total_netgains += $row->Net;
        }
        $results['rows'] = $rows;
        $results['total_withdrawals'] = $total_withdrawals;
        $results['total_deposits'] = $total_deposits;
        $results['total_saccos'] = $total_saccos;
        $results['total_netgains'] = $total_netgains;
        return response()->json($results, 200);
    }
}
