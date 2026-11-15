<?php

namespace Tests\Feature;

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class TransactionReportTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        Schema::create('saccos', function (Blueprint $table): void {
            $table->integer('id')->primary();
            $table->string('country');
        });

        Schema::create('individuals', function (Blueprint $table): void {
            $table->integer('id')->primary();
            $table->integer('sacco_id');
        });

        Schema::create('transactions', function (Blueprint $table): void {
            $table->integer('id')->primary();
            $table->integer('individual_id');
            $table->integer('amount');
            $table->string('type');
        });
    }

    public function test_it_returns_legacy_transaction_rows_and_totals(): void
    {
        DB::table('saccos')->insert([
            ['id' => 1, 'country' => 'Kenya'],
            ['id' => 2, 'country' => 'Uganda'],
            ['id' => 3, 'country' => 'Uganda'],
            ['id' => 4, 'country' => 'Rwanda'],
        ]);

        DB::table('individuals')->insert([
            ['id' => 1, 'sacco_id' => 1],
            ['id' => 2, 'sacco_id' => 2],
            ['id' => 3, 'sacco_id' => 3],
            ['id' => 4, 'sacco_id' => 4],
        ]);

        DB::table('transactions')->insert([
            ['id' => 1, 'individual_id' => 1, 'amount' => 200, 'type' => 'deposit'],
            ['id' => 2, 'individual_id' => 1, 'amount' => 50, 'type' => 'withdrawal'],
            ['id' => 3, 'individual_id' => 2, 'amount' => 100, 'type' => 'deposit'],
            ['id' => 4, 'individual_id' => 3, 'amount' => 50, 'type' => 'deposit'],
            ['id' => 5, 'individual_id' => 2, 'amount' => 40, 'type' => 'withdrawal'],
            ['id' => 6, 'individual_id' => 4, 'amount' => 999, 'type' => 'deposit'],
        ]);

        $response = $this->getJson('/api/reports/transactions');

        $response
            ->assertOk()
            ->assertExactJson([
                'rows' => [
                    [
                        'Country' => 'Kenya',
                        'Saccos' => 1,
                        'Deposit' => 200,
                        'Withdrawal' => 50,
                        'Net' => 150,
                    ],
                    [
                        'Country' => 'Uganda',
                        'Saccos' => 2,
                        'Deposit' => 150,
                        'Withdrawal' => 40,
                        'Net' => 110,
                    ],
                ],
                'total_withdrawals' => 90,
                'total_deposits' => 350,
                'total_saccos' => 3,
                'total_netgains' => 260,
            ]);
    }
}
